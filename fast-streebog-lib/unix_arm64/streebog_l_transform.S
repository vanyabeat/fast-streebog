// macOS uses underscore prefix for C symbols, Linux does not
#ifdef __APPLE__
    #define SYMBOL(name) _##name
    #define PRIVATE_GLOBAL .private_extern
    .macro load_table_address reg, table
        adrp    \reg, \table@PAGE
        add     \reg, \reg, \table@PAGEOFF
    .endm
#else
    #define SYMBOL(name) name
    #define PRIVATE_GLOBAL .hidden
    .macro load_table_address reg, table
        adrp    \reg, \table
        add     \reg, \reg, :lo12:\table
    .endm
#endif

.text
.align 4
PRIVATE_GLOBAL SYMBOL(streebog_l_transform)
.global SYMBOL(streebog_l_transform)

// Optimized L-transform using precalculated lookup tables
// void streebog_l_transform(const uint8_t *state, uint8_t *out)
SYMBOL(streebog_l_transform):
    // x0 = state (input), x1 = out (output)
    
    // Save callee-saved registers (we need x19-x27 for table pointers)
    stp     x29, x30, [sp, #-80]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]
    
    // Load all 8 table base addresses ONCE before the loop
    load_table_address x19, SYMBOL(Ax_COL0)
    load_table_address x20, SYMBOL(Ax_COL1)
    load_table_address x21, SYMBOL(Ax_COL2)
    load_table_address x22, SYMBOL(Ax_COL3)
    load_table_address x23, SYMBOL(Ax_COL4)
    load_table_address x24, SYMBOL(Ax_COL5)
    load_table_address x25, SYMBOL(Ax_COL6)
    load_table_address x26, SYMBOL(Ax_COL7)
    
    // Process 8 blocks (unrolled for better performance)
    // Block 0
    ldr     x2, [x0, #0]            // Load 8 bytes at once
    
    and     x3, x2, #0xFF           // byte 0
    ldr     x9, [x19, x3, lsl #3]   // result = Ax_COL0[byte0]
    
    ubfx    x3, x2, #8, #8          // byte 1
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    
    ubfx    x3, x2, #16, #8         // byte 2
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    
    ubfx    x3, x2, #24, #8         // byte 3
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    
    ubfx    x3, x2, #32, #8         // byte 4
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    
    ubfx    x3, x2, #40, #8         // byte 5
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    
    ubfx    x3, x2, #48, #8         // byte 6
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    
    lsr     x3, x2, #56             // byte 7
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    
    rev     x9, x9
    str     x9, [x1, #0]
    
    // Block 1
    ldr     x2, [x0, #8]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #8]
    
    // Block 2
    ldr     x2, [x0, #16]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #16]
    
    // Block 3
    ldr     x2, [x0, #24]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #24]
    
    // Block 4
    ldr     x2, [x0, #32]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #32]
    
    // Block 5
    ldr     x2, [x0, #40]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #40]
    
    // Block 6
    ldr     x2, [x0, #48]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #48]
    
    // Block 7
    ldr     x2, [x0, #56]
    and     x3, x2, #0xFF
    ldr     x9, [x19, x3, lsl #3]
    ubfx    x3, x2, #8, #8
    ldr     x10, [x20, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #16, #8
    ldr     x10, [x21, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #24, #8
    ldr     x10, [x22, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #32, #8
    ldr     x10, [x23, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #40, #8
    ldr     x10, [x24, x3, lsl #3]
    eor     x9, x9, x10
    ubfx    x3, x2, #48, #8
    ldr     x10, [x25, x3, lsl #3]
    eor     x9, x9, x10
    lsr     x3, x2, #56
    ldr     x10, [x26, x3, lsl #3]
    eor     x9, x9, x10
    rev     x9, x9
    str     x9, [x1, #56]
    
    // Restore callee-saved registers
    ldp     x25, x26, [sp, #64]
    ldp     x23, x24, [sp, #48]
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #80
    ret
