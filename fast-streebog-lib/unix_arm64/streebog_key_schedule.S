// ARM64 optimized implementation of key schedule
// void streebog_key_schedule(const uint8_t *K, int i, uint8_t *out)
//
// Computes round key: out = L(P(S(K XOR C[i])))
// Uses optimized ASM implementations of XOR, S, P, L transforms

// macOS uses underscore prefix for C symbols, Linux does not
#ifdef __APPLE__
    #define SYMBOL(name) _##name
    #define PRIVATE_GLOBAL .private_extern
#else
    #define SYMBOL(name) name
    #define PRIVATE_GLOBAL .hidden
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

// Jump table for C constants (12 pointers × 8 bytes = 96 bytes)
.align 3
C_TABLE:
    .quad 0  // placeholder, will be filled at runtime via load_address

PRIVATE_GLOBAL SYMBOL(streebog_key_schedule)
.global SYMBOL(streebog_key_schedule)

SYMBOL(streebog_key_schedule):
    // x0 = K (key pointer)
    // w1 = i (round number, 0-11)
    // x2 = out (output pointer)
    
    // Save registers and allocate stack space (64 bytes for temp buffer)
    stp     x29, x30, [sp, #-112]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    
    // Save arguments
    mov     x19, x0                 // x19 = K
    mov     w20, w1                 // w20 = i
    mov     x21, x2                 // x21 = out
    
    // Load C[i] address using jump table approach
    // Optimized: use computed branch instead of chain of compares
    cmp     w20, #11
    b.hi    .Ldefault_c11           // If i > 11, use C_11
    
    adr     x4, .Ljump_table
    add     x4, x4, x20, lsl #2     // Each entry is 4 bytes (b instruction)
    br      x4

.align 2
.Ljump_table:
    b       .LC_0
    b       .LC_1
    b       .LC_2
    b       .LC_3
    b       .LC_4
    b       .LC_5
    b       .LC_6
    b       .LC_7
    b       .LC_8
    b       .LC_9
    b       .LC_10
    b       .LC_11

.LC_0:
    load_address x3, SYMBOL(STREEBOG_C_0)
    b       .Ldo_xor
.LC_1:
    load_address x3, SYMBOL(STREEBOG_C_1)
    b       .Ldo_xor
.LC_2:
    load_address x3, SYMBOL(STREEBOG_C_2)
    b       .Ldo_xor
.LC_3:
    load_address x3, SYMBOL(STREEBOG_C_3)
    b       .Ldo_xor
.LC_4:
    load_address x3, SYMBOL(STREEBOG_C_4)
    b       .Ldo_xor
.LC_5:
    load_address x3, SYMBOL(STREEBOG_C_5)
    b       .Ldo_xor
.LC_6:
    load_address x3, SYMBOL(STREEBOG_C_6)
    b       .Ldo_xor
.LC_7:
    load_address x3, SYMBOL(STREEBOG_C_7)
    b       .Ldo_xor
.LC_8:
    load_address x3, SYMBOL(STREEBOG_C_8)
    b       .Ldo_xor
.LC_9:
    load_address x3, SYMBOL(STREEBOG_C_9)
    b       .Ldo_xor
.LC_10:
    load_address x3, SYMBOL(STREEBOG_C_10)
    b       .Ldo_xor
.Ldefault_c11:
.LC_11:
    load_address x3, SYMBOL(STREEBOG_C_11)
    
.Ldo_xor:
    // x19 = K, x3 = C[i], stack+48 = temp buffer
    
    // Step 1: temp = K XOR C[i] - INLINED using NEON for speed
    add     x4, sp, #48             // x4 = temp buffer
    
    // Load K (64 bytes) into v0-v3
    ld1     {v0.16b, v1.16b, v2.16b, v3.16b}, [x19]
    // Load C[i] (64 bytes) into v4-v7
    ld1     {v4.16b, v5.16b, v6.16b, v7.16b}, [x3]
    // XOR
    eor     v0.16b, v0.16b, v4.16b
    eor     v1.16b, v1.16b, v5.16b
    eor     v2.16b, v2.16b, v6.16b
    eor     v3.16b, v3.16b, v7.16b
    // Store temp
    st1     {v0.16b, v1.16b, v2.16b, v3.16b}, [x4]
    
    // Step 2: temp = S(temp)
    mov     x0, x4                  // x0 = temp
    mov     x1, x4                  // x1 = temp (in-place)
    bl      SYMBOL(streebog_s_transform)
    
    // Step 3: temp = P(temp)
    add     x0, sp, #48
    add     x1, sp, #48
    bl      SYMBOL(streebog_p_transform)
    
    // Step 4: out = L(temp)
    add     x0, sp, #48
    mov     x1, x21
    bl      SYMBOL(streebog_l_transform)
    
    // Restore registers and return
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #112
    ret
