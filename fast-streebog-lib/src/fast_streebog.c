#include "fast_streebog.h"
#include "streebog_impl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "streebog_cpu.h"

#ifdef _MSC_VER
#include <intrin.h>
#endif

// Declares ISA-specific ASM implementations used by the dispatcher
#define DECLARE_ASM_VARIANT(suffix) \
    extern void streebog_xor_512_##suffix(const uint8_t*, const uint8_t*, uint8_t*); \
    extern void streebog_add_512_##suffix(const uint8_t*, const uint8_t*, uint8_t*); \
    extern void streebog_s_transform_##suffix(const uint8_t*, uint8_t*); \
    extern void streebog_p_transform_##suffix(const uint8_t*, uint8_t*); \
    extern void streebog_l_transform_##suffix(const uint8_t*, uint8_t*); \
    extern void streebog_key_schedule_##suffix(const uint8_t*, int, uint8_t*);

// External ASM function declarations
#ifdef STREEBOG_USE_ASM

#if defined(_MSC_VER)
    DECLARE_ASM_VARIANT(avx512);
    DECLARE_ASM_VARIANT(avx2);
    DECLARE_ASM_VARIANT(ssse3);
    DECLARE_ASM_VARIANT(sse2);

#elif defined(__GNUC__) && (defined(__x86_64__) || defined(__amd46__))
    DECLARE_ASM_VARIANT(avx2);
    DECLARE_ASM_VARIANT(ssse3);

#elif defined(__aarch64__) || defined(__arm64__)
extern void streebog_xor_512(const uint8_t*, const uint8_t*, uint8_t*);
extern void streebog_add_512(const uint8_t*, const uint8_t*, uint8_t*);
extern void streebog_s_transform(const uint8_t*, uint8_t*);
extern void streebog_p_transform(const uint8_t*, uint8_t*);
extern void streebog_l_transform(const uint8_t*, uint8_t*);
extern void streebog_key_schedule(const uint8_t*, int, uint8_t*);
#endif

#endif


// Runtime dispatch table — function pointers resolved once at startup
typedef struct {
    void (*xor_512)(const uint8_t*, const uint8_t*, uint8_t*);
    void (*add_512)(const uint8_t*, const uint8_t*, uint8_t*);
    void (*s_transform)(const uint8_t*, uint8_t*);
    void (*p_transform)(const uint8_t*, uint8_t*);
    void (*l_transform)(const uint8_t*, uint8_t*);
    void (*key_schedule)(const uint8_t*, int, uint8_t*);
} streebog_impl_t;

static streebog_impl_t g_impl;
static int g_initialized = 0;

// Selects the best available implementation at runtime (AVX-512 > AVX2 > SSSE3 > SSE2)
// Falls back to portable C if no ASM path was compiled in (STREEBOG_USE_ASM not defined)
// or if running on an unsupported architecture 
static void init_impl(void)
{
    // Zero out the entire structure before populating
    memset(&g_impl, 0, sizeof(g_impl));

#define ASSIGN_IMPL(suffix) \
    do { \
        g_impl.xor_512      = streebog_xor_512_##suffix; \
        g_impl.add_512      = streebog_add_512_##suffix; \
        g_impl.s_transform  = streebog_s_transform_##suffix; \
        g_impl.p_transform  = streebog_p_transform_##suffix; \
        g_impl.l_transform  = streebog_l_transform_##suffix; \
        g_impl.key_schedule = streebog_key_schedule_##suffix; \
    } while(0)

#ifdef STREEBOG_USE_ASM

#if defined(_MSC_VER)
    if      (has_avx512()) ASSIGN_IMPL(avx512);
    else if (has_avx2())   ASSIGN_IMPL(avx2);
    else if (has_ssse3())  ASSIGN_IMPL(ssse3);
    else                    ASSIGN_IMPL(sse2);

 #elif defined(__GNUC__) && (defined(__x86_64__) || defined(__amd64__))
    else if (has_avx2())   ASSIGN_IMPL(avx2);
    else if (has_ssse3())  ASSIGN_IMPL(ssse3);

#elif defined(__aarch64__) || defined(__arm64__)
    g_impl.xor_512      = streebog_xor_512;
    g_impl.add_512      = streebog_add_512;
    g_impl.s_transform  = streebog_s_transform;
    g_impl.p_transform  = streebog_p_transform;
    g_impl.l_transform  = streebog_l_transform;
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
#define ENSURE_IMPL() do { if (!g_initialized) init_impl(); } while(0)

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

// E transformation: E(K, m)
// Performs 12 rounds of S->P->L->KeySchedule->XOR
// Buffers are aligned to 32 bytes to avoid AVX2 penalties on unaligned loads
// Pointer swapping avoids redundant memcpy between pipeline stages
void streebog_e_transform(const uint8_t *K, const uint8_t *m, uint8_t *out)
{
#ifdef _MSC_VER
    __declspec(align(32)) uint8_t state[64];
    __declspec(align(32)) uint8_t key[64];
    __declspec(align(32)) uint8_t tmp[64];
#else
    __attribute__((aligned(32))) uint8_t state[64];
    __attribute__((aligned(32))) uint8_t key[64];
    __attribute__((aligned(32))) uint8_t tmp[64];
#endif

    STREEBOG_NAMESPACE(xor_512)(K, m, state);
    memcpy(key, K, 64);

    for (int i = 0; i < 12; i++)
    {
        STREEBOG_NAMESPACE(s_transform)(state, state);
        STREEBOG_NAMESPACE(p_transform)(state, state);
        STREEBOG_NAMESPACE(l_transform)(state, state);
        STREEBOG_NAMESPACE(key_schedule)(key, i, key);
        STREEBOG_NAMESPACE(xor_512)(state, key, state);
    }

    memcpy(out, state, 64);
}

// G_n compression function: g(N, h, m)
// K = L(P(S(h ^ N)))
// t = E(K, m)
// return t ^ h ^ m
void STREEBOG_NAMESPACE(g_n)(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out)
{
    #ifdef _MSC_VER
        __declspec(align(32)) uint8_t K[64];
        __declspec(align(32)) uint8_t t[64];
    #else
        __attribute__((aligned(32))) uint8_t K[64];
        __attribute__((aligned(32))) uint8_t t[64];
    #endif

    STREEBOG_NAMESPACE(xor_512)(h, N, K);
    STREEBOG_NAMESPACE(s_transform)(K, K);
    STREEBOG_NAMESPACE(p_transform)(K, K);
    STREEBOG_NAMESPACE(l_transform)(K, K);

    STREEBOG_NAMESPACE(e_transform)(K, m, t);

    STREEBOG_NAMESPACE(xor_512)(t, h, t);
    STREEBOG_NAMESPACE(xor_512)(t, m, out);
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