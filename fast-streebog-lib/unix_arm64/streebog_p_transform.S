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
PRIVATE_GLOBAL SYMBOL(streebog_p_transform)
.global SYMBOL(streebog_p_transform)

// TAU permutation indices for NEON tbl instruction
// Split into 4 parts of 16 bytes each for tbl2 operations
.align 4
TAU_IDX_0:  // Output bytes 0-15: which input bytes to take
    .byte  0,  8, 16, 24, 32, 40, 48, 56   // from state positions
    .byte  1,  9, 17, 25, 33, 41, 49, 57
TAU_IDX_1:  // Output bytes 16-31
    .byte  2, 10, 18, 26, 34, 42, 50, 58
    .byte  3, 11, 19, 27, 35, 43, 51, 59
TAU_IDX_2:  // Output bytes 32-47
    .byte  4, 12, 20, 28, 36, 44, 52, 60
    .byte  5, 13, 21, 29, 37, 45, 53, 61
TAU_IDX_3:  // Output bytes 48-63
    .byte  6, 14, 22, 30, 38, 46, 54, 62
    .byte  7, 15, 23, 31, 39, 47, 55, 63

// Optimized P-transform using NEON tbl instruction
// void streebog_p_transform(const uint8_t *state, uint8_t *out)
SYMBOL(streebog_p_transform):
    // x0 = state (input), x1 = out (output)
    
    // Load all 64 input bytes into v0-v3 (4 x 16 bytes)
    ld1     {v0.16b, v1.16b, v2.16b, v3.16b}, [x0]
    
    // Load TAU permutation indices
    adrp    x2, TAU_IDX_0@PAGE
    add     x2, x2, TAU_IDX_0@PAGEOFF
    ld1     {v16.16b, v17.16b, v18.16b, v19.16b}, [x2]
    
    // Perform table lookups for each output block
    // tbl with 4 source registers can index into 64 bytes (0-63)
    tbl     v20.16b, {v0.16b, v1.16b, v2.16b, v3.16b}, v16.16b  // out[0-15]
    tbl     v21.16b, {v0.16b, v1.16b, v2.16b, v3.16b}, v17.16b  // out[16-31]
    tbl     v22.16b, {v0.16b, v1.16b, v2.16b, v3.16b}, v18.16b  // out[32-47]
    tbl     v23.16b, {v0.16b, v1.16b, v2.16b, v3.16b}, v19.16b  // out[48-63]
    
    // Store all 64 output bytes
    st1     {v20.16b, v21.16b, v22.16b, v23.16b}, [x1]
    
    ret
