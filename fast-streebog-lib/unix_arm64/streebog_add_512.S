// macOS uses underscore prefix for C symbols, Linux does not
#ifdef __APPLE__
    #define SYMBOL(name) _##name
    #define PRIVATE_GLOBAL .private_extern
#else
    #define SYMBOL(name) name
    #define PRIVATE_GLOBAL .hidden
#endif

.text
.align 4
PRIVATE_GLOBAL SYMBOL(streebog_add_512)
.global SYMBOL(streebog_add_512)

// Add two 512-bit big-endian numbers with carry propagation
// void streebog_add_512(const uint8_t *a, const uint8_t *b, uint8_t *out)
SYMBOL(streebog_add_512):
    // x0 = a, x1 = b, x2 = out
    // Use indexed loads to avoid modifying pointers
    // Process from LSB (offset 56) to MSB (offset 0)
    
    // Iteration 0: offset 56 (LSB) - use ADDS to initialize carry
    ldr     x3, [x0, #56]
    ldr     x4, [x1, #56]
    rev     x3, x3
    rev     x4, x4
    adds    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #56]
    
    // Iteration 1: offset 48
    ldr     x3, [x0, #48]
    ldr     x4, [x1, #48]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #48]
    
    // Iteration 2: offset 40
    ldr     x3, [x0, #40]
    ldr     x4, [x1, #40]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #40]
    
    // Iteration 3: offset 32
    ldr     x3, [x0, #32]
    ldr     x4, [x1, #32]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #32]
    
    // Iteration 4: offset 24
    ldr     x3, [x0, #24]
    ldr     x4, [x1, #24]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #24]
    
    // Iteration 5: offset 16
    ldr     x3, [x0, #16]
    ldr     x4, [x1, #16]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #16]
    
    // Iteration 6: offset 8
    ldr     x3, [x0, #8]
    ldr     x4, [x1, #8]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2, #8]
    
    // Iteration 7: offset 0 (MSB)
    ldr     x3, [x0]
    ldr     x4, [x1]
    rev     x3, x3
    rev     x4, x4
    adcs    x3, x3, x4
    rev     x3, x3
    str     x3, [x2]
    
    ret
