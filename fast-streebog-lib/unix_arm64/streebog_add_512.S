.text
.align 4
.global _streebog_add_512

_streebog_add_512:
    // x0 = a (input pointer 1)
    // x1 = b (input pointer 2)
    // x2 = out (output pointer)
    
    // Point to the end of arrays (LSB is at byte[63])
    add     x0, x0, #56         // Point to bytes 56-63 (LSB)
    add     x1, x1, #56         // Point to bytes 56-63 (LSB)
    add     x2, x2, #56         // Point to bytes 56-63 (LSB)
    
    // Load 8 bytes in little-endian (will be reversed on ARM64)
    // We need to reverse byte order to process LSB first
    ldr     x3, [x0]
    ldr     x4, [x1]
    
    // Reverse bytes to get proper order for addition
    rev     x3, x3
    rev     x4, x4
    
    // Add with carry propagation (8 iterations of 8 bytes each)
    adds    x3, x3, x4          // Add and set carry flag
    rev     x3, x3              // Reverse back for storage
    str     x3, [x2]            // Store result
    
    // Process remaining 7 groups of 8 bytes
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4          // Add with carry
    rev     x3, x3
    str     x3, [x2]
    
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2]
    
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2]
    
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2]
    
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2]
    
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2]
    
    sub     x0, x0, #8
    sub     x1, x1, #8
    sub     x2, x2, #8
    
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4          // Final add with carry
    rev     x3, x3
    str     x3, [x2]
    
    ret
