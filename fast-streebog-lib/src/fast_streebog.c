#include "fast_streebog.h"
#include "streebog_impl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Library version - injected by CMake from VERSION file
#ifndef STREEBOG_VERSION
#define STREEBOG_VERSION "unknown"
#endif

STREEBOG_API const char *STREEBOG_NAMESPACE(version)(void)
{
    return STREEBOG_VERSION;
}

// ==================== Low-level functions (C implementations for non-MSVC) ====================
#ifndef _MSC_VER

void STREEBOG_NAMESPACE(xor_512)(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    streebog_xor_512_c(a, b, out);
}

void STREEBOG_NAMESPACE(add_512)(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    streebog_add_512_c(a, b, out);
}

void STREEBOG_NAMESPACE(s_transform)(const uint8_t *state, uint8_t *out)
{
    streebog_s_transform_c(state, out);
}

void STREEBOG_NAMESPACE(p_transform)(const uint8_t *state, uint8_t *out)
{
    streebog_p_transform_c(state, out);
}

void STREEBOG_NAMESPACE(l_transform)(const uint8_t *state, uint8_t *out)
{
    streebog_l_transform_c(state, out);
}

void STREEBOG_NAMESPACE(key_schedule)(const uint8_t *K, int i, uint8_t *out)
{
    streebog_key_schedule_c(K, i, out);
}

#endif // !_MSC_VER

// E transformation: E(K, m)
// Performs 12 rounds of S->P->L->KeySchedule->XOR
// Always use C implementation - it calls optimized ASM for S/P/L/KeySchedule
void STREEBOG_NAMESPACE(e_transform)(const uint8_t *K, const uint8_t *m, uint8_t *out)
{
    uint8_t state[64];
    uint8_t key[64];

    // state = K ^ m
    STREEBOG_NAMESPACE(xor_512)(K, m, state);

    // Copy K to working key buffer
    memcpy(key, K, 64);

    // 12 rounds
    for (int i = 0; i < 12; i++)
    {
        // state = S(state)
        STREEBOG_NAMESPACE(s_transform)(state, state);

        // state = P(state)
        STREEBOG_NAMESPACE(p_transform)(state, state);

        // state = L(state)
        STREEBOG_NAMESPACE(l_transform)(state, state);

        // K = KeySchedule(K, i)
        STREEBOG_NAMESPACE(key_schedule)(key, i, key);

        // state = state ^ K
        STREEBOG_NAMESPACE(xor_512)(state, key, state);
    }

    // Return state as result
    memcpy(out, state, 64);
}

// G_n compression function: g(N, h, m)
// K = L(P(S(h ^ N)))
// t = E(K, m)
// return t ^ h ^ m
// Always use C implementation - it calls optimized ASM for primitives
void STREEBOG_NAMESPACE(g_n)(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out)
{
    uint8_t K[64];
    uint8_t t[64];

    // K = h ^ N
    STREEBOG_NAMESPACE(xor_512)(h, N, K);

    // K = S(K)
    STREEBOG_NAMESPACE(s_transform)(K, K);

    // K = P(K)
    STREEBOG_NAMESPACE(p_transform)(K, K);

    // K = L(K)
    STREEBOG_NAMESPACE(l_transform)(K, K);

    // t = E(K, m)
    STREEBOG_NAMESPACE(e_transform)(K, m, t);

    // t = t ^ h
    STREEBOG_NAMESPACE(xor_512)(t, h, t);

    // out = t ^ m
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
    // N_512 = 512 as 64-byte big-endian
    static const uint8_t N_512[64] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

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

    // Total message length
    size_t total_len = ctx->msg_len;

    // Reverse the entire message buffer in-place (one pass)
    // This converts from natural byte order to GOST little-endian
    if (total_len > 1)
    {
        size_t left = 0;
        size_t right = total_len - 1;
        while (left < right)
        {
            uint8_t tmp = ctx->msg_buf[left];
            ctx->msg_buf[left] = ctx->msg_buf[right];
            ctx->msg_buf[right] = tmp;
            left++;
            right--;
        }
    }

    // Now process blocks sequentially (data is already reversed)
    size_t pos = 0;
    while (pos + 64 <= total_len)
    {
        process_block(ctx, ctx->msg_buf + pos);
        pos += 64;
    }

    // Remaining bytes
    size_t remainder = total_len - pos;

    // Pad the message: 0...0 || 1 || M
    // Message length in bits
    size_t msg_bits = remainder * 8;

    // Create padded block
    memset(padded, 0, 64);
    if (remainder > 0)
    {
        // Copy remainder into right side of padded (already reversed)
        memcpy(padded + (64 - remainder), ctx->msg_buf + pos, remainder);
    }
    // Set the '1' bit after padding zeros
    padded[64 - remainder - 1] = 0x01;

    // h = g(N, h, padded)
    STREEBOG_NAMESPACE(g_n)(ctx->N, ctx->h, padded, ctx->h);

    // N = (N + |M|) mod 2^512, where |M| is message length in bits
    // Convert msg_bits to big-endian 64-byte representation
    len_bytes[63] = (uint8_t)(msg_bits & 0xFF);
    len_bytes[62] = (uint8_t)((msg_bits >> 8) & 0xFF);
    len_bytes[61] = (uint8_t)((msg_bits >> 16) & 0xFF);
    len_bytes[60] = (uint8_t)((msg_bits >> 24) & 0xFF);
    len_bytes[59] = (uint8_t)((msg_bits >> 32) & 0xFF);
    len_bytes[58] = (uint8_t)((msg_bits >> 40) & 0xFF);
    len_bytes[57] = (uint8_t)((msg_bits >> 48) & 0xFF);
    len_bytes[56] = (uint8_t)((msg_bits >> 56) & 0xFF);

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
