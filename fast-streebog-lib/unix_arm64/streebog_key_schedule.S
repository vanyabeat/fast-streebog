// ARM64 implementation of key schedule
// void streebog_key_schedule(const uint8_t *K, int i, uint8_t *out)
//
// Computes round key: out = L(P(S(K XOR C[i])))
// Uses optimized ASM implementations of XOR, S, P, L transforms

// macOS uses underscore prefix for C symbols, Linux does not
#ifdef __APPLE__
    #define SYMBOL(name) _##name
#else
    #define SYMBOL(name) name
#endif

// Macro for loading address (works on both macOS and Linux)
#ifdef __APPLE__
.macro load_address reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
.endm
#else
.macro load_address reg, sym
    adrp    \reg, \sym
    add     \reg, \reg, :lo12:\sym
.endm
#endif

.text
.align 4
.global SYMBOL(streebog_key_schedule)

SYMBOL(streebog_key_schedule):
    // x0 = K (key pointer)
    // w1 = i (round number)
    // x2 = out (output pointer)
    
    // Save registers and allocate stack space
    stp     x29, x30, [sp, #-112]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    
    // Save arguments
    mov     x19, x0                 // x19 = K
    mov     w20, w1                 // w20 = i
    mov     x21, x2                 // x21 = out
    
    // Get address of C constant based on index i
    cmp     w20, #0
    b.eq    .LC_0
    cmp     w20, #1
    b.eq    .LC_1
    cmp     w20, #2
    b.eq    .LC_2
    cmp     w20, #3
    b.eq    .LC_3
    cmp     w20, #4
    b.eq    .LC_4
    cmp     w20, #5
    b.eq    .LC_5
    cmp     w20, #6
    b.eq    .LC_6
    cmp     w20, #7
    b.eq    .LC_7
    cmp     w20, #8
    b.eq    .LC_8
    cmp     w20, #9
    b.eq    .LC_9
    cmp     w20, #10
    b.eq    .LC_10
    // Fall through to C_11
    
.LC_11:
    load_address x3, SYMBOL(STREEBOG_C_11)
    b       .Ldo_xor
.LC_10:
    load_address x3, SYMBOL(STREEBOG_C_10)
    b       .Ldo_xor
.LC_9:
    load_address x3, SYMBOL(STREEBOG_C_9)
    b       .Ldo_xor
.LC_8:
    load_address x3, SYMBOL(STREEBOG_C_8)
    b       .Ldo_xor
.LC_7:
    load_address x3, SYMBOL(STREEBOG_C_7)
    b       .Ldo_xor
.LC_6:
    load_address x3, SYMBOL(STREEBOG_C_6)
    b       .Ldo_xor
.LC_5:
    load_address x3, SYMBOL(STREEBOG_C_5)
    b       .Ldo_xor
.LC_4:
    load_address x3, SYMBOL(STREEBOG_C_4)
    b       .Ldo_xor
.LC_3:
    load_address x3, SYMBOL(STREEBOG_C_3)
    b       .Ldo_xor
.LC_2:
    load_address x3, SYMBOL(STREEBOG_C_2)
    b       .Ldo_xor
.LC_1:
    load_address x3, SYMBOL(STREEBOG_C_1)
    b       .Ldo_xor
.LC_0:
    load_address x3, SYMBOL(STREEBOG_C_0)
    
.Ldo_xor:
    // Step 1: temp = K XOR C[i]
    add     x2, sp, #48             // x2 = temp buffer on stack
    mov     x0, x19                 // x0 = K
    mov     x1, x3                  // x1 = C[i]
    bl      SYMBOL(streebog_xor_512)       // temp = K XOR C[i]
    
    // Step 2: temp = S(temp) - in place
    add     x0, sp, #48             // x0 = temp
    add     x1, sp, #48             // x1 = temp (in-place)
    bl      SYMBOL(streebog_s_transform)   // temp = S(temp)
    
    // Step 3: temp = P(temp) - in place
    add     x0, sp, #48             // x0 = temp
    add     x1, sp, #48             // x1 = temp (in-place)
    bl      SYMBOL(streebog_p_transform)   // temp = P(temp)
    
    // Step 4: out = L(temp)
    add     x0, sp, #48             // x0 = temp
    mov     x1, x21                 // x1 = out
    bl      SYMBOL(streebog_l_transform)   // out = L(temp)
    
    // Restore registers and return
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #112
    ret
