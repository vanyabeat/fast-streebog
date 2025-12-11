/**
 * @file streebog.h
 * @brief Fast Streebog (GOST R 34.11-2012) hash function library
 *
 * This is the distribution header for the fast-streebog DLL.
 *
 * Usage:
 *   1. Include this header in your project
 *   2. Define STREEBOG_USE_DLL before including this header
 *   3. Link against fast-streebog.lib (import library)
 *   4. Place fast-streebog.dll in your application directory
 *
 * Example:
 *   #define STREEBOG_USE_DLL
 *   #include "streebog.h"
 *
 *   char hash_hex[129];
 *   streebog_hash_512_hex((const uint8_t*)"test", 4, hash_hex);
 *   printf("Hash: %s\n", hash_hex);
 *
 * @copyright MIT License
 */

#ifndef STREEBOG_H
#define STREEBOG_H

#include <stddef.h>
#include <stdint.h>

/* DLL/dylib export/import macros */
#ifdef _WIN32
#ifdef STREEBOG_BUILD_DLL
#define STREEBOG_API __declspec(dllexport)
#elif defined(STREEBOG_USE_DLL)
#define STREEBOG_API __declspec(dllimport)
#else
#define STREEBOG_API
#endif
#elif defined(__APPLE__) || defined(__linux__)
#if defined(STREEBOG_BUILD_DLL) || defined(STREEBOG_USE_DLL)
#define STREEBOG_API __attribute__((visibility("default")))
#else
#define STREEBOG_API
#endif
#else
#define STREEBOG_API
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    /* ==================== Hash context for streaming API ==================== */

    /**
     * @brief Hash context structure for streaming operations
     */
    typedef struct
    {
        uint8_t h[64];     /**< Current hash state */
        uint8_t N[64];     /**< Message length counter (in bits, mod 2^512) */
        uint8_t Sigma[64]; /**< Checksum of all processed blocks */
        uint8_t *msg_buf;  /**< Dynamic buffer for message data */
        size_t msg_len;    /**< Total message length */
        size_t msg_cap;    /**< Buffer capacity */
        int out_len;       /**< Output length: 256 or 512 bits */
    } streebog_ctx;

    /* ==================== Streaming API ==================== */

    /**
     * @brief Initialize context for 512-bit hash
     * @param ctx Pointer to hash context
     */
    STREEBOG_API void streebog_init_512(streebog_ctx *ctx);

    /**
     * @brief Initialize context for 256-bit hash
     * @param ctx Pointer to hash context
     */
    STREEBOG_API void streebog_init_256(streebog_ctx *ctx);

    /**
     * @brief Update hash with data (can be called multiple times)
     * @param ctx Pointer to hash context
     * @param data Pointer to input data
     * @param len Length of input data in bytes
     */
    STREEBOG_API void streebog_update(streebog_ctx *ctx, const uint8_t *data, size_t len);

    /**
     * @brief Finalize and get hash result
     * @param ctx Pointer to hash context
     * @param out Output buffer (64 bytes for 512-bit, 32 bytes for 256-bit)
     */
    STREEBOG_API void streebog_final(streebog_ctx *ctx, uint8_t *out);

    /* ==================== One-shot API ==================== */

    /**
     * @brief Compute 512-bit hash in one call
     * @param data Pointer to input data
     * @param len Length of input data in bytes
     * @param out Output buffer (must be 64 bytes)
     */
    STREEBOG_API void streebog_hash_512(const uint8_t *data, size_t len, uint8_t *out);

    /**
     * @brief Compute 256-bit hash in one call
     * @param data Pointer to input data
     * @param len Length of input data in bytes
     * @param out Output buffer (must be 32 bytes)
     */
    STREEBOG_API void streebog_hash_256(const uint8_t *data, size_t len, uint8_t *out);

    /* ==================== Hex string API ==================== */

    /**
     * @brief Compute 512-bit hash and return as hex string
     * @param data Pointer to input data
     * @param len Length of input data in bytes
     * @param out Output buffer (must be at least 129 bytes: 128 hex chars + null)
     */
    STREEBOG_API void streebog_hash_512_hex(const uint8_t *data, size_t len, char *out);

    /**
     * @brief Compute 256-bit hash and return as hex string
     * @param data Pointer to input data
     * @param len Length of input data in bytes
     * @param out Output buffer (must be at least 65 bytes: 64 hex chars + null)
     */
    STREEBOG_API void streebog_hash_256_hex(const uint8_t *data, size_t len, char *out);

    /**
     * @brief Convert raw hash bytes to hex string
     * @param hash Pointer to hash bytes
     * @param hash_len Length of hash in bytes (64 for 512-bit, 32 for 256-bit)
     * @param out Output buffer (must be at least hash_len * 2 + 1 bytes)
     */
    STREEBOG_API void streebog_bytes_to_hex(const uint8_t *hash, size_t hash_len, char *out);

    /**
     * @brief Get library version string
     * @return Version string (e.g., "1.0.0")
     */
    STREEBOG_API const char *streebog_version(void);

    /* ==================== File hashing API ==================== */

    /**
     * @brief Hash file and compute both 256-bit and 512-bit hashes in one pass
     *
     * This function is optimized for FFI usage - it processes the entire file
     * with a single function call, eliminating FFI overhead for large files.
     *
     * @param filepath Path to file to hash (UTF-8 encoded)
     * @param hash_256 Output buffer for 256-bit hash (must be 32 bytes), can be NULL
     * @param hash_512 Output buffer for 512-bit hash (must be 64 bytes), can be NULL
     * @param progress_callback Optional progress callback function, can be NULL
     * @param user_data User data to pass to progress callback
     * @return 0 on success, -1 on file open error, -2 on read error, -3 if both outputs are NULL
     *
     * Example:
     *   uint8_t hash_256[32], hash_512[64];
     *   int result = streebog_hash_file_dual("test.bin", hash_256, hash_512, NULL, NULL);
     *   if (result == 0) {
     *       // Success - both hashes computed
     *   }
     */
    STREEBOG_API int streebog_hash_file_dual(const char *filepath, uint8_t *hash_256, uint8_t *hash_512,
                                             void (*progress_callback)(size_t bytes_processed, size_t total_size,
                                                                       void *user_data),
                                             void *user_data);

#ifdef __cplusplus
}
#endif

#endif /* STREEBOG_H */
