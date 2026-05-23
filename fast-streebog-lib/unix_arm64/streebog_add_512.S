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

    // Load all 64-bit pairs at once 
    ldp     x3, x4, [x0, #48]
    ldp     x5, x6, [x1, #48]

    ldp     x7, x8, [x0, #32]
    ldp     x9, x10, [x1, #32]

    ldp     x11, x12, [x0, #16]
    ldp     x13, x14, [x1, #16]

    ldp     x15, x16, [x0] 
    ldp     x17, x18, [x1] 

    // Perform byte-swap to convert ARM little-endian registers to GOST big-endian
    rev     x3, x3
    rev     x4, x4
    rev     x5, x5
    rev     x6, x6
    rev     x7, x7
    rev     x8, x8
    rev     x9, x9
    rev     x10, x10
    rev     x11, x11
    rev     x12, x12
    rev     x13, x13
    rev     x14, x14
    rev     x15, x15
    rev     x16, x16
    rev     x17, x17
    rev     x18, x18

    // Add corresponding 64-bit words with carry propagation (LSW -> MSW)
    adds    x4, x4, x6
    adcs    x3, x3, x5
    adcs    x8, x8, x10
    adcs    x7, x7, x9
    adcs    x12, x12, x14
    adcs    x11, x11, x13
    adcs    x16, x16, x18
    adcs    x15, x15, x17

    // Byte-swap again to store words in memory as big-endian for GOST
    rev     x3, x3
    rev     x4, x4
    rev     x7, x7
    rev     x8, x8
    rev     x11, x11
    rev     x12, x12
    rev     x15, x15
    rev     x16, x16

    // Store results in pairs to output buffer (memory will look like big-endian words)
    stp     x3, x4, [x2, #48]
    stp     x7, x8, [x2, #32]
    stp     x11, x12, [x2, #16]
    stp     x15, x16, [x2]

    ret