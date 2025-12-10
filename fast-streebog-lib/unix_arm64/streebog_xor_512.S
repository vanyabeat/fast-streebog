// ARM64 NEON implementation of XOR 512-bit operation
// void streebog_xor_512(const uint8_t *a, const uint8_t *b, uint8_t *out)
//
// Uses NEON vector instructions for parallel XOR operations
// Processes 512 bits (64 bytes) in 4 iterations of 16 bytes each

.text
.align 4
.global _streebog_xor_512

_streebog_xor_512:
    // x0 = a (input pointer 1)
    // x1 = b (input pointer 2)
    // x2 = out (output pointer)
    
    // Load and XOR 16 bytes at a time (4 iterations for 64 bytes)
    // Using quad-word (128-bit) NEON registers
    
    // Iteration 1: bytes 0-15
    ld1     {v0.16b}, [x0], #16     // Load 16 bytes from a, post-increment
    ld1     {v1.16b}, [x1], #16     // Load 16 bytes from b, post-increment
    eor     v0.16b, v0.16b, v1.16b  // XOR v0 and v1
    st1     {v0.16b}, [x2], #16     // Store result, post-increment
    
    // Iteration 2: bytes 16-31
    ld1     {v2.16b}, [x0], #16
    ld1     {v3.16b}, [x1], #16
    eor     v2.16b, v2.16b, v3.16b
    st1     {v2.16b}, [x2], #16
    
    // Iteration 3: bytes 32-47
    ld1     {v4.16b}, [x0], #16
    ld1     {v5.16b}, [x1], #16
    eor     v4.16b, v4.16b, v5.16b
    st1     {v4.16b}, [x2], #16
    
    // Iteration 4: bytes 48-63
    ld1     {v6.16b}, [x0], #16
    ld1     {v7.16b}, [x1], #16
    eor     v6.16b, v6.16b, v7.16b
    st1     {v6.16b}, [x2], #16
    
    ret
