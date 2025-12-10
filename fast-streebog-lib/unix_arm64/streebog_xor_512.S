// ARM64 NEON implementation of XOR 512-bit operation
// void streebog_xor_512(const uint8_t *a, const uint8_t *b, uint8_t *out)
//
// Optimized: loads all 64 bytes in single instructions using multi-register ld1/st1

// macOS uses underscore prefix for C symbols, Linux does not
#ifdef __APPLE__
    #define SYMBOL(name) _##name
#else
    #define SYMBOL(name) name
#endif

.text
.align 4
.global SYMBOL(streebog_xor_512)

SYMBOL(streebog_xor_512):
    // x0 = a, x1 = b, x2 = out
    
    // Load all 64 bytes (512 bits) from both inputs in 2 instructions each
    ld1     {v0.16b, v1.16b, v2.16b, v3.16b}, [x0]   // Load 64 bytes from a
    ld1     {v4.16b, v5.16b, v6.16b, v7.16b}, [x1]   // Load 64 bytes from b
    
    // XOR all 4 pairs in parallel (CPU can execute these out-of-order)
    eor     v0.16b, v0.16b, v4.16b
    eor     v1.16b, v1.16b, v5.16b
    eor     v2.16b, v2.16b, v6.16b
    eor     v3.16b, v3.16b, v7.16b
    
    // Store all 64 bytes in single instruction
    st1     {v0.16b, v1.16b, v2.16b, v3.16b}, [x2]
    
    ret
