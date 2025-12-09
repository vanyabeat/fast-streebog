#ifndef FAST_STREEBOG_H
#define FAST_STREEBOG_H

#include "fast_macros.h"
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

    // ==================== Low-level ASM functions (internal) ====================

    void STREEBOG_NAMESPACE(xor_512)(const uint8_t *a, const uint8_t *b, uint8_t *out);

    void STREEBOG_NAMESPACE(add_512)(const uint8_t *a, const uint8_t *b, uint8_t *out);

    void STREEBOG_NAMESPACE(s_transform)(const uint8_t *state, uint8_t *out);

    void STREEBOG_NAMESPACE(p_transform)(const uint8_t *state, uint8_t *out);

    void STREEBOG_NAMESPACE(l_transform)(const uint8_t *state, uint8_t *out);

    void STREEBOG_NAMESPACE(key_schedule)(const uint8_t *K, int i, uint8_t *out);

    // ==================== Higher-level C functions (internal) ====================

    // E transformation: E(K, m) - main encryption function
    // K - key (64 bytes), m - message block (64 bytes), out - result (64 bytes)
    void STREEBOG_NAMESPACE(e_transform)(const uint8_t *K, const uint8_t *m, uint8_t *out);

    // G_n compression function: g(N, h, m)
    // N - counter (64 bytes), h - hash state (64 bytes), m - message block (64
    // bytes) out - new hash state (64 bytes)
    void STREEBOG_NAMESPACE(g_n)(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out);

    // ==================== Hash context and streaming API ====================

    // Hash context structure
    typedef struct
    {
        uint8_t h[64];     // Current hash state
        uint8_t N[64];     // Message length counter (in bits, mod 2^512)
        uint8_t Sigma[64]; // Checksum of all processed blocks
        uint8_t *msg_buf;  // Dynamic buffer for full message (for chunked streaming)
        size_t msg_len;    // Total message length
        size_t msg_cap;    // Buffer capacity
        int out_len;       // Output length: 256 or 512 bits
    } streebog_ctx;

    // Initialize context for 512-bit hash
    STREEBOG_API void STREEBOG_NAMESPACE(init_512)(streebog_ctx *ctx);

    // Initialize context for 256-bit hash
    STREEBOG_API void STREEBOG_NAMESPACE(init_256)(streebog_ctx *ctx);

    // Update hash with data (can be called multiple times)
    STREEBOG_API void STREEBOG_NAMESPACE(update)(streebog_ctx *ctx, const uint8_t *data, size_t len);

    // Finalize and get hash result
    // out must be 64 bytes for 512-bit hash, 32 bytes for 256-bit hash
    STREEBOG_API void STREEBOG_NAMESPACE(final)(streebog_ctx *ctx, uint8_t *out);

    // ==================== Simple one-shot API ====================

    // Compute 512-bit hash in one call
    // out must be 64 bytes
    STREEBOG_API void STREEBOG_NAMESPACE(hash_512)(const uint8_t *data, size_t len, uint8_t *out);

    // Compute 256-bit hash in one call
    // out must be 32 bytes
    STREEBOG_API void STREEBOG_NAMESPACE(hash_256)(const uint8_t *data, size_t len, uint8_t *out);

    // ==================== Hex string API ====================

    // Compute 512-bit hash and return as hex string
    // out must be at least 129 bytes (128 hex chars + null terminator)
    STREEBOG_API void STREEBOG_NAMESPACE(hash_512_hex)(const uint8_t *data, size_t len, char *out);

    // Compute 256-bit hash and return as hex string
    // out must be at least 65 bytes (64 hex chars + null terminator)
    STREEBOG_API void STREEBOG_NAMESPACE(hash_256_hex)(const uint8_t *data, size_t len, char *out);

    // Convert raw hash bytes to hex string
    // hash_len is in bytes (64 for 512-bit, 32 for 256-bit)
    // out must be at least (hash_len * 2 + 1) bytes
    STREEBOG_API void STREEBOG_NAMESPACE(bytes_to_hex)(const uint8_t *hash, size_t hash_len, char *out);

    // Get library version string (e.g., "1.0.0")
    STREEBOG_API const char *STREEBOG_NAMESPACE(version)(void);

    // ==================== File hashing API ====================

    // Hash file and compute both 256-bit and 512-bit hashes in one pass
    // Optimized for FFI usage - single function call eliminates FFI overhead
    // filepath - path to file (UTF-8 encoded)
    // hash_256 - output for 256-bit hash (32 bytes), can be NULL
    // hash_512 - output for 512-bit hash (64 bytes), can be NULL
    // progress_callback - optional progress callback, can be NULL
    // user_data - user data passed to progress callback
    // Returns: 0 on success, -1 on file open error, -2 on read error, -3 if both outputs are NULL
    STREEBOG_API int STREEBOG_NAMESPACE(hash_file_dual)(const char *filepath, uint8_t *hash_256, uint8_t *hash_512,
                                                        void (*progress_callback)(size_t bytes_processed,
                                                                                  size_t total_size, void *user_data),
                                                        void *user_data);

#ifdef __cplusplus
}
#endif

#endif // FAST_STREEBOG_H