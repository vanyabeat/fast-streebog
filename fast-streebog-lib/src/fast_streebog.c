#include "fast_streebog.h"
#include "streebog_cpu.h"
#include "streebog_impl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _MSC_VER
#include <intrin.h>
#endif

// Fully vectorized fused compression path (whole 512-bit state in one ZMM)
// Requires AVX-512 VBMI + GFNI; currently enabled for MSVC x64 builds
#if defined(_MSC_VER) && defined(_M_X64) && !defined(_M_ARM64EC)
#define STREEBOG_HAVE_AVX512_GFNI 1
#include <immintrin.h>
#endif

// Declares ISA-specific ASM implementations used by the dispatcher
#define DECLARE_ASM_VARIANT(suffix)                                                                                    \
    extern void streebog_xor_512_##suffix(const uint8_t *, const uint8_t *, uint8_t *);                                \
    extern void streebog_add_512_##suffix(const uint8_t *, const uint8_t *, uint8_t *);                                \
    extern void streebog_s_transform_##suffix(const uint8_t *, uint8_t *);                                             \
    extern void streebog_p_transform_##suffix(const uint8_t *, uint8_t *);                                             \
    extern void streebog_l_transform_##suffix(const uint8_t *, uint8_t *);                                             \
    extern void streebog_key_schedule_##suffix(const uint8_t *, int, uint8_t *);

// External ASM function declarations
#ifdef STREEBOG_USE_ASM

#if defined(_MSC_VER)
DECLARE_ASM_VARIANT(avx512);
DECLARE_ASM_VARIANT(avx2);
DECLARE_ASM_VARIANT(ssse3);
DECLARE_ASM_VARIANT(sse2);

#elif defined(__GNUC__) && (defined(__x86_64__) || defined(__amd64__))
DECLARE_ASM_VARIANT(avx2);
DECLARE_ASM_VARIANT(ssse3);

#elif defined(__aarch64__) || defined(__arm64__)
extern void streebog_xor_512(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_add_512(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_s_transform(const uint8_t *, uint8_t *);
extern void streebog_p_transform(const uint8_t *, uint8_t *);
extern void streebog_l_transform(const uint8_t *, uint8_t *);
extern void streebog_key_schedule(const uint8_t *, int, uint8_t *);
#endif

#endif

// Runtime dispatch table — function pointers resolved once at startup
typedef struct
{
    void (*xor_512)(const uint8_t *, const uint8_t *, uint8_t *);
    void (*add_512)(const uint8_t *, const uint8_t *, uint8_t *);
    void (*s_transform)(const uint8_t *, uint8_t *);
    void (*p_transform)(const uint8_t *, uint8_t *);
    void (*l_transform)(const uint8_t *, uint8_t *);
    void (*key_schedule)(const uint8_t *, int, uint8_t *);
} streebog_impl_t;

static streebog_impl_t g_impl;
static int g_initialized = 0;

// Fused LPS lookup table: AxS[j][b] = Ax[j][SBOX[b]]
// Combines the S-box substitution with the L-transform tables so a full
// S->P->L round is 64 table lookups + XORs on 64-bit words (no byte passes)
static uint64_t g_AxS[8][256];
// Round constants C[i] converted to big-endian 64-bit words
static uint64_t g_C64[12][8];

// g_n compression dispatch: fused scalar C or fully vectorized AVX-512 GFNI
static void streebog_g_n_fused_scalar(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out);
static void (*g_gn)(const uint8_t *, const uint8_t *, const uint8_t *, uint8_t *) = NULL;

#ifdef STREEBOG_HAVE_AVX512_GFNI
static void streebog_g_n_avx512(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out);
// GFNI 8x8 bit-matrix blocks of the L transform: g_LM[j] lane b = block A_bj
// (contribution of input byte j to output byte b), in VGF2P8AFFINEQB encoding
#ifdef _MSC_VER
__declspec(align(64))
#else
__attribute__((aligned(64)))
#endif
static uint64_t g_LM[8][8];
#endif

// Selects the best available implementation at runtime (AVX-512 > AVX2 > SSSE3 > SSE2)
// Falls back to portable C if no ASM path was compiled in (STREEBOG_USE_ASM not defined)
// or if running on an unsupported architecture
static void init_impl(void)
{
    // Build the fused S+L table and word-form round constants (used by the
    // fused g_n / e_transform compression path on all platforms)
    for (int j = 0; j < 8; j++)
    {
        for (int b = 0; b < 256; b++)
        {
            g_AxS[j][b] = STREEBOG_Ax[j][STREEBOG_SBOX[b]];
        }
    }
    for (int i = 0; i < 12; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            g_C64[i][j] = streebog_bytes_to_u64_be(STREEBOG_C[i] + j * 8);
        }
    }

    g_gn = streebog_g_n_fused_scalar;

#ifdef STREEBOG_HAVE_AVX512_GFNI
    if (has_avx512_vbmi_gfni())
    {
        // Derive the 8x8 GF(2) blocks of the L matrix by probing l_mul64:
        // column t of block A_bj = output byte b when input byte j = (1 << t)
        for (int j = 0; j < 8; j++)
        {
            for (int b = 0; b < 8; b++)
            {
                uint8_t col[8];
                for (int t = 0; t < 8; t++)
                {
                    uint64_t x = ((uint64_t)1 << t) << (56 - 8 * j);
                    col[t] = (uint8_t)(streebog_l_mul64(x) >> (56 - 8 * b));
                }
                // VGF2P8AFFINEQB: result bit i = parity(matrix byte [7-i] AND src byte)
                uint64_t M = 0;
                for (int i = 0; i < 8; i++)
                {
                    uint8_t row = 0;
                    for (int t = 0; t < 8; t++)
                    {
                        row |= (uint8_t)(((col[t] >> i) & 1) << t);
                    }
                    M |= (uint64_t)row << (8 * (7 - i));
                }
                g_LM[j][b] = M;
            }
        }
        g_gn = streebog_g_n_avx512;
    }
#endif

    // Zero out the entire structure before populating
    memset(&g_impl, 0, sizeof(g_impl));

#define ASSIGN_IMPL(suffix)                                                                                            \
    do                                                                                                                 \
    {                                                                                                                  \
        g_impl.xor_512 = streebog_xor_512_##suffix;                                                                    \
        g_impl.add_512 = streebog_add_512_##suffix;                                                                    \
        g_impl.s_transform = streebog_s_transform_##suffix;                                                            \
        g_impl.p_transform = streebog_p_transform_##suffix;                                                            \
        g_impl.l_transform = streebog_l_transform_##suffix;                                                            \
        g_impl.key_schedule = streebog_key_schedule_##suffix;                                                          \
    } while (0)

#ifdef STREEBOG_USE_ASM

#if defined(_MSC_VER)
    if (has_avx512())
        ASSIGN_IMPL(avx512);
    else if (has_avx2())
        ASSIGN_IMPL(avx2);
    else if (has_ssse3())
        ASSIGN_IMPL(ssse3);
    else
        ASSIGN_IMPL(sse2);

#elif defined(__GNUC__) && (defined(__x86_64__) || defined(__amd64__))
    if (has_avx2())
        ASSIGN_IMPL(avx2);
    else if (has_ssse3())
        ASSIGN_IMPL(ssse3);

#elif defined(__aarch64__) || defined(__arm64__)
    g_impl.xor_512 = streebog_xor_512;
    g_impl.add_512 = streebog_add_512;
    g_impl.s_transform = streebog_s_transform;
    g_impl.p_transform = streebog_p_transform;
    g_impl.l_transform = streebog_l_transform;
    g_impl.key_schedule = streebog_key_schedule;

#endif

#endif
    // Portable C fallback — used when STREEBOG_USE_ASM is not defined
    // or when running on an architecture with no ASM implementation
    if (!g_impl.xor_512)
    {
        ASSIGN_IMPL(c);
    }

    g_initialized = 1;
}

// Lazy initialization — resolves impl on first use, zero-overhead on subsequent calls
#define ENSURE_IMPL()                                                                                                  \
    do                                                                                                                 \
    {                                                                                                                  \
        if (!g_initialized)                                                                                            \
            init_impl();                                                                                               \
    } while (0)

// GOST R 34.11-2012 requires big-endian byte order for the length counter (sigma)
#ifdef _MSC_VER
#define BSWAP64(x) _byteswap_uint64(x)
#else
#define BSWAP64(x) __builtin_bswap64(x)
#endif

#ifndef STREEBOG_VERSION
#define STREEBOG_VERSION "unknown"
#endif

// Version
STREEBOG_API const char *STREEBOG_NAMESPACE(version)(void)
{
    return STREEBOG_VERSION;
}

// Public API wrappers — dispatch to the selected implementation via g_impl
// Only compiled on MSVC/x86; on AArch64 these are called directly from ASM
#if defined(_MSC_VER) || (defined(__GNUC__) && (defined(__x86_64__) || defined(__amd64__)))
void STREEBOG_NAMESPACE(xor_512)(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.xor_512(a, b, out);
}

void STREEBOG_NAMESPACE(add_512)(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.add_512(a, b, out);
}

void STREEBOG_NAMESPACE(s_transform)(const uint8_t *state, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.s_transform(state, out);
}

void STREEBOG_NAMESPACE(p_transform)(const uint8_t *state, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.p_transform(state, out);
}

void STREEBOG_NAMESPACE(l_transform)(const uint8_t *state, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.l_transform(state, out);
}

void STREEBOG_NAMESPACE(key_schedule)(const uint8_t *K, int i, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.key_schedule(K, i, out);
}
#endif

// ==================== Fused compression path ====================
// The state is kept as eight 64-bit words (big-endian semantics: byte 0 of
// the 64-byte block is the MSB of word 0). A full S->P->L round collapses
// into one pass of table lookups because:
//   L(P(S(x)))[word i] = XOR_j Ax[j][SBOX[x[j*8 + i]]] = XOR_j AxS[j][byte i of W[j]]
// This keeps the whole 12-round compression in registers with no per-round
// function calls or byte-array passes.

static inline uint64_t load_be64(const uint8_t *p)
{
    uint64_t v;
    memcpy(&v, p, 8);
    return BSWAP64(v);
}

static inline void store_be64(uint64_t v, uint8_t *p)
{
    v = BSWAP64(v);
    memcpy(p, &v, 8);
}

// In-place fused S+P+L transform on 8 words
static inline void streebog_lps(uint64_t w[8])
{
    uint64_t r0, r1, r2, r3, r4, r5, r6, r7;

#define LPS_COL(idx, sh)                                                                                               \
    r##idx = g_AxS[0][(w[0] >> (sh)) & 0xFF] ^ g_AxS[1][(w[1] >> (sh)) & 0xFF] ^ g_AxS[2][(w[2] >> (sh)) & 0xFF] ^     \
             g_AxS[3][(w[3] >> (sh)) & 0xFF] ^ g_AxS[4][(w[4] >> (sh)) & 0xFF] ^ g_AxS[5][(w[5] >> (sh)) & 0xFF] ^     \
             g_AxS[6][(w[6] >> (sh)) & 0xFF] ^ g_AxS[7][(w[7] >> (sh)) & 0xFF]

    LPS_COL(0, 56);
    LPS_COL(1, 48);
    LPS_COL(2, 40);
    LPS_COL(3, 32);
    LPS_COL(4, 24);
    LPS_COL(5, 16);
    LPS_COL(6, 8);
    LPS_COL(7, 0);
#undef LPS_COL

    w[0] = r0;
    w[1] = r1;
    w[2] = r2;
    w[3] = r3;
    w[4] = r4;
    w[5] = r5;
    w[6] = r6;
    w[7] = r7;
}

// 12 rounds of E(K, m) on word-form key/state; s holds K ^ m on entry
static inline void streebog_e_rounds(uint64_t k[8], uint64_t s[8])
{
    for (int i = 0; i < 12; i++)
    {
        streebog_lps(s);
        for (int j = 0; j < 8; j++)
        {
            k[j] ^= g_C64[i][j];
        }
        streebog_lps(k);
        for (int j = 0; j < 8; j++)
        {
            s[j] ^= k[j];
        }
    }
}

// E transformation: E(K, m)
// Performs 12 rounds of the fused S->P->L round with the key schedule inline
void streebog_e_transform(const uint8_t *K, const uint8_t *m, uint8_t *out)
{
    uint64_t k[8], s[8];

    ENSURE_IMPL();

    for (int j = 0; j < 8; j++)
    {
        k[j] = load_be64(K + j * 8);
        s[j] = k[j] ^ load_be64(m + j * 8);
    }

    streebog_e_rounds(k, s);

    for (int j = 0; j < 8; j++)
    {
        store_be64(s[j], out + j * 8);
    }
}

// G_n compression function: g(N, h, m)
// K = L(P(S(h ^ N)))
// t = E(K, m)
// return t ^ h ^ m
static void streebog_g_n_fused_scalar(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out)
{
    uint64_t hw[8], mw[8], k[8], s[8];

    for (int j = 0; j < 8; j++)
    {
        hw[j] = load_be64(h + j * 8);
        mw[j] = load_be64(m + j * 8);
        k[j] = hw[j] ^ load_be64(N + j * 8);
    }

    streebog_lps(k);

    for (int j = 0; j < 8; j++)
    {
        s[j] = k[j] ^ mw[j];
    }

    streebog_e_rounds(k, s);

    for (int j = 0; j < 8; j++)
    {
        store_be64(s[j] ^ hw[j] ^ mw[j], out + j * 8);
    }
}

#ifdef STREEBOG_HAVE_AVX512_GFNI
// ==================== AVX-512 VBMI + GFNI fused path ====================
// The whole 512-bit state lives in one ZMM register in memory byte order
// (byte 8w+b = byte b of word w). One LPS round:
//   S: 4x VPERMB over 64-byte S-box slices, selected by bits 6-7 of each byte
//   P+L combined: for each input byte column j, broadcast qword j and apply
//     the per-output-byte 8x8 GF(2) matrix blocks with VGF2P8AFFINEQB;
//     the accumulator ends up transposed, and the final VPERMB transpose
//     (which equals the TAU permutation) restores word order

static __forceinline __m512i streebog_lps512(__m512i v)
{
    const __m512i t0 = _mm512_loadu_si512(STREEBOG_SBOX);
    const __m512i t1 = _mm512_loadu_si512(STREEBOG_SBOX + 64);
    const __m512i t2 = _mm512_loadu_si512(STREEBOG_SBOX + 128);
    const __m512i t3 = _mm512_loadu_si512(STREEBOG_SBOX + 192);

    __m512i r0 = _mm512_permutexvar_epi8(v, t0);
    __m512i r1 = _mm512_permutexvar_epi8(v, t1);
    __m512i r2 = _mm512_permutexvar_epi8(v, t2);
    __m512i r3 = _mm512_permutexvar_epi8(v, t3);

    __mmask64 k6 = _mm512_test_epi8_mask(v, _mm512_set1_epi8(0x40));
    __mmask64 k7 = _mm512_test_epi8_mask(v, _mm512_set1_epi8((char)0x80));

    __m512i s01 = _mm512_mask_blend_epi8(k6, r0, r1);
    __m512i s23 = _mm512_mask_blend_epi8(k6, r2, r3);
    __m512i s = _mm512_mask_blend_epi8(k7, s01, s23);

    __m512i acc = _mm512_setzero_si512();
    for (int j = 0; j < 8; j++)
    {
        __m512i bc = _mm512_permutexvar_epi64(_mm512_set1_epi64(j), s);
        acc = _mm512_xor_si512(acc, _mm512_gf2p8affine_epi64_epi8(bc, _mm512_load_si512(g_LM[j]), 0));
    }

    // TAU is exactly the 8x8 byte transpose needed to un-transpose acc
    return _mm512_permutexvar_epi8(_mm512_loadu_si512(STREEBOG_TAU), acc);
}

static void streebog_g_n_avx512(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out)
{
    __m512i zh = _mm512_loadu_si512(h);
    __m512i zm = _mm512_loadu_si512(m);

    __m512i k = _mm512_xor_si512(zh, _mm512_loadu_si512(N));
    k = streebog_lps512(k);

    __m512i s = _mm512_xor_si512(k, zm);

    for (int i = 0; i < 12; i++)
    {
        s = streebog_lps512(s);
        k = _mm512_xor_si512(k, _mm512_loadu_si512(STREEBOG_C[i]));
        k = streebog_lps512(k);
        s = _mm512_xor_si512(s, k);
    }

    s = _mm512_xor_si512(s, _mm512_xor_si512(zh, zm));
    _mm512_storeu_si512(out, s);
    _mm256_zeroupper();
}
#endif // STREEBOG_HAVE_AVX512_GFNI

void STREEBOG_NAMESPACE(g_n)(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out)
{
    ENSURE_IMPL();
    g_gn(N, h, m, out);
}

// Initialize hash context for 512-bit output
void STREEBOG_NAMESPACE(init_512)(streebog_ctx *ctx)
{
    memset(ctx->h, 0x00, 64);
    memset(ctx->N, 0x00, 64);
    memset(ctx->Sigma, 0x00, 64);
    ctx->msg_buf = NULL;
    ctx->msg_len = 0;
    ctx->msg_cap = 0;
    ctx->out_len = 512;
}

// Initialize hash context for 256-bit output
void STREEBOG_NAMESPACE(init_256)(streebog_ctx *ctx)
{
    memset(ctx->h, 0x01, 64);
    memset(ctx->N, 0x00, 64);
    memset(ctx->Sigma, 0x00, 64);
    ctx->msg_buf = NULL;
    ctx->msg_len = 0;
    ctx->msg_cap = 0;
    ctx->out_len = 256;
}

// Process a full 512-bit block
static void process_block(streebog_ctx *ctx, const uint8_t *block)
{
    // N_512 = 512 as 64-byte big-endian (byte[63] is LSB, 512 = 0x200)
    static const uint8_t N_512[64] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x02, 0};

    // h = g(N, h, m)
    STREEBOG_NAMESPACE(g_n)(ctx->N, ctx->h, block, ctx->h);

    // N = (N + 512) mod 2^512
    STREEBOG_NAMESPACE(add_512)(ctx->N, N_512, ctx->N);

    // Sigma = (Sigma + m) mod 2^512
    STREEBOG_NAMESPACE(add_512)(ctx->Sigma, block, ctx->Sigma);
}

// Update hash with data (accumulates data for processing in final)
void STREEBOG_NAMESPACE(update)(streebog_ctx *ctx, const uint8_t *data, size_t len)
{
    if (len == 0)
        return;

    // Grow buffer if needed
    size_t new_len = ctx->msg_len + len;
    if (new_len > ctx->msg_cap)
    {
        size_t new_cap = ctx->msg_cap == 0 ? 256 : ctx->msg_cap;
        while (new_cap < new_len)
        {
            new_cap *= 2;
        }
        uint8_t *new_buf = (uint8_t *)realloc(ctx->msg_buf, new_cap);
        if (!new_buf)
            return; // allocation failed
        ctx->msg_buf = new_buf;
        ctx->msg_cap = new_cap;
    }

    // Append data
    memcpy(ctx->msg_buf + ctx->msg_len, data, len);
    ctx->msg_len += len;
}

// Finalize hash and get result
void STREEBOG_NAMESPACE(final)(streebog_ctx *ctx, uint8_t *out)
{
    uint8_t padded[64];
    uint8_t N_0[64] = {0};
    uint8_t len_bytes[64] = {0};
    uint8_t temp_block[64];

    // Total message length
    size_t total_len = ctx->msg_len;

    // Process full 64-byte blocks from the beginning of the message.
    // In GOST convention byte[0] is the least significant byte, so
    // bytes [0..63] form the "rightmost" (least significant) 512-bit block
    // which must be processed first. Each block is reversed to the internal
    // big-endian format (byte[0] = MSB) before feeding into g_n.
    size_t pos = 0;
    while (pos + 64 <= total_len)
    {
        // Reverse this 64-byte block to internal big-endian format
        for (int i = 0; i < 64; i++)
        {
            temp_block[i] = ctx->msg_buf[pos + 63 - i];
        }
        process_block(ctx, temp_block);
        pos += 64;
    }

    // Remaining bytes (the most significant part of the message)
    size_t remainder = total_len - pos;

    // Message length in bits for the remaining part
    size_t msg_bits = remainder * 8;

    // Create padded block: 0...0 || 1 || M_remainder (in internal big-endian format)
    memset(padded, 0, 64);
    if (remainder > 0)
    {
        // Reverse remainder bytes into the LSB side of padded block
        for (size_t i = 0; i < remainder; i++)
        {
            padded[63 - i] = ctx->msg_buf[pos + i];
        }
    }
    // Set the '1' bit after padding zeros
    padded[64 - remainder - 1] = 0x01;

    // h = g(N, h, padded)
    STREEBOG_NAMESPACE(g_n)(ctx->N, ctx->h, padded, ctx->h);

    // N = (N + |M|) mod 2^512, where |M| is message length in bits
    // Store msg_bits as big-endian 64-bit value at offset 56
    // Using byte swap intrinsic - compiles to single BSWAP instruction
    *(uint64_t *)(len_bytes + 56) = BSWAP64((uint64_t)msg_bits);

    STREEBOG_NAMESPACE(add_512)(ctx->N, len_bytes, ctx->N);

    // Sigma = (Sigma + padded) mod 2^512
    STREEBOG_NAMESPACE(add_512)(ctx->Sigma, padded, ctx->Sigma);

    // h = g(0, h, N)
    STREEBOG_NAMESPACE(g_n)(N_0, ctx->h, ctx->N, ctx->h);

    // h = g(0, h, Sigma)
    STREEBOG_NAMESPACE(g_n)(N_0, ctx->h, ctx->Sigma, ctx->h);

    // Output result - reverse byte order for GOST standard representation
    if (ctx->out_len == 512)
    {
        for (int i = 0; i < 64; i++)
        {
            out[i] = ctx->h[63 - i];
        }
    }
    else
    {
        // For 256-bit, return MSB256(h) which is first 32 bytes of reversed hash
        for (int i = 0; i < 32; i++)
        {
            out[i] = ctx->h[31 - i];
        }
    }

    // Free buffer
    if (ctx->msg_buf)
    {
        free(ctx->msg_buf);
        ctx->msg_buf = NULL;
    }
    ctx->msg_len = 0;
    ctx->msg_cap = 0;
}

// Simple one-shot hash function for 512-bit output
void STREEBOG_NAMESPACE(hash_512)(const uint8_t *data, size_t len, uint8_t *out)
{
    streebog_ctx ctx;
    STREEBOG_NAMESPACE(init_512)(&ctx);
    STREEBOG_NAMESPACE(update)(&ctx, data, len);
    STREEBOG_NAMESPACE(final)(&ctx, out);
}

// Simple one-shot hash function for 256-bit output
void STREEBOG_NAMESPACE(hash_256)(const uint8_t *data, size_t len, uint8_t *out)
{
    streebog_ctx ctx;
    STREEBOG_NAMESPACE(init_256)(&ctx);
    STREEBOG_NAMESPACE(update)(&ctx, data, len);
    STREEBOG_NAMESPACE(final)(&ctx, out);
}

// ==================== Hex string functions ====================

static const char HEX_CHARS[] = "0123456789abcdef";

// Convert raw hash bytes to hex string
void STREEBOG_NAMESPACE(bytes_to_hex)(const uint8_t *hash, size_t hash_len, char *out)
{
    for (size_t i = 0; i < hash_len; i++)
    {
        out[i * 2] = HEX_CHARS[(hash[i] >> 4) & 0x0F];
        out[i * 2 + 1] = HEX_CHARS[hash[i] & 0x0F];
    }
    out[hash_len * 2] = '\0';
}

// Compute 512-bit hash and return as hex string
void STREEBOG_NAMESPACE(hash_512_hex)(const uint8_t *data, size_t len, char *out)
{
    uint8_t hash[64];
    STREEBOG_NAMESPACE(hash_512)(data, len, hash);
    STREEBOG_NAMESPACE(bytes_to_hex)(hash, 64, out);
}

// Compute 256-bit hash and return as hex string
void STREEBOG_NAMESPACE(hash_256_hex)(const uint8_t *data, size_t len, char *out)
{
    uint8_t hash[32];
    STREEBOG_NAMESPACE(hash_256)(data, len, hash);
    STREEBOG_NAMESPACE(bytes_to_hex)(hash, 32, out);
}

// ==================== File hashing API ====================

// Hash file and compute both 256-bit and 512-bit hashes in one pass
// Optimized for FFI usage - single function call eliminates FFI overhead
int STREEBOG_NAMESPACE(hash_file_dual)(const char *filepath, uint8_t *hash_256, uint8_t *hash_512,
                                       void (*progress_callback)(size_t bytes_processed, size_t total_size,
                                                                 void *user_data),
                                       void *user_data)
{
    // Validate parameters
    if (hash_256 == NULL && hash_512 == NULL)
    {
        return -3;
    }

    FILE *file = fopen(filepath, "rb");
    if (file == NULL)
    {
        return -1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    streebog_ctx ctx_256, ctx_512;
    if (hash_256 != NULL)
    {
        STREEBOG_NAMESPACE(init_256)(&ctx_256);
    }
    if (hash_512 != NULL)
    {
        STREEBOG_NAMESPACE(init_512)(&ctx_512);
    }

    uint8_t buffer[65536];
    size_t bytes_read;
    size_t bytes_processed = 0;

    while ((bytes_read = fread(buffer, 1, sizeof(buffer), file)) > 0)
    {
        if (hash_256 != NULL)
        {
            STREEBOG_NAMESPACE(update)(&ctx_256, buffer, bytes_read);
        }
        if (hash_512 != NULL)
        {
            STREEBOG_NAMESPACE(update)(&ctx_512, buffer, bytes_read);
        }

        bytes_processed += bytes_read;

        if (progress_callback != NULL)
        {
            progress_callback(bytes_processed, (size_t)file_size, user_data);
        }
    }

    if (ferror(file))
    {
        fclose(file);
        return -2;
    }

    fclose(file);

    if (hash_256 != NULL)
    {
        STREEBOG_NAMESPACE(final)(&ctx_256, hash_256);
    }
    if (hash_512 != NULL)
    {
        STREEBOG_NAMESPACE(final)(&ctx_512, hash_512);
    }

    return 0;
}