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

SYMBOL(streebog_l_transform):

    // Save frame and callee-saved registers
    stp     x29, x30, [sp, #-80]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]

    // Load addresses of precomputed tables
    load_table_address x19, SYMBOL(Ax_COL0)
    load_table_address x20, SYMBOL(Ax_COL1)
    load_table_address x21, SYMBOL(Ax_COL2)
    load_table_address x22, SYMBOL(Ax_COL3)
    load_table_address x23, SYMBOL(Ax_COL4)
    load_table_address x24, SYMBOL(Ax_COL5)
    load_table_address x25, SYMBOL(Ax_COL6)
    load_table_address x26, SYMBOL(Ax_COL7)

    // Load input 64-bit words from memory (ARM little-endian)
    // We will emulate big-endian arithmetic for GOST
    ldr     x2, [x0, #0]
    ldr     x3, [x0, #8]
    ldr     x4, [x0, #16]
    ldr     x5, [x0, #24]
    ldr     x6, [x0, #32]
    ldr     x7, [x0, #40]
    ldr     x8, [x0, #48]
    ldr     x9, [x0, #56]

    // Initialize output registers with first table lookup (byte 0)
    and     x0, x2, #0xFF
    ldr     x10, [x19, x0, lsl #3]   // block 0, byte 0

    and     x0, x3, #0xFF
    ldr     x11, [x19, x0, lsl #3]   // block 1, byte 0

    and     x0, x4, #0xFF
    ldr     x12, [x19, x0, lsl #3]   // block 2, byte 0

    and     x0, x5, #0xFF
    ldr     x13, [x19, x0, lsl #3]   // block 3, byte 0

    and     x0, x6, #0xFF
    ldr     x14, [x19, x0, lsl #3]   // block 4, byte 0

    and     x0, x7, #0xFF
    ldr     x15, [x19, x0, lsl #3]   // block 5, byte 0

    and     x0, x8, #0xFF
    ldr     x16, [x19, x0, lsl #3]   // block 6, byte 0

    and     x0, x9, #0xFF
    ldr     x17, [x19, x0, lsl #3]  // block 7, byte 0

    // Process bytes 1..6 via table lookup and XOR
    // ubfx extracts byte i, lsl shifts for table index, eor combines
    // byte 1
    ubfx    x0, x2, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x10, x10, x0

    ubfx    x0, x3, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x11, x11, x0

    ubfx    x0, x4, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x12, x12, x0

    ubfx    x0, x5, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x13, x13, x0

    ubfx    x0, x6, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x14, x14, x0

    ubfx    x0, x7, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x15, x15, x0

    ubfx    x0, x8, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x16, x16, x0

    ubfx    x0, x9, #8, #8
    ldr     x0, [x20, x0, lsl #3]
    eor     x17, x17, x0

    // byte 2
    ubfx    x0, x2, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x10, x10, x0

    ubfx    x0, x3, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x11, x11, x0

    ubfx    x0, x4, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x12, x12, x0

    ubfx    x0, x5, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x13, x13, x0

    ubfx    x0, x6, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x14, x14, x0

    ubfx    x0, x7, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x15, x15, x0

    ubfx    x0, x8, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x16, x16, x0

    ubfx    x0, x9, #16, #8
    ldr     x0, [x21, x0, lsl #3]
    eor     x17, x17, x0

    // byte 3
    ubfx    x0, x2, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x10, x10, x0

    ubfx    x0, x3, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x11, x11, x0

    ubfx    x0, x4, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x12, x12, x0

    ubfx    x0, x5, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x13, x13, x0

    ubfx    x0, x6, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x14, x14, x0

    ubfx    x0, x7, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x15, x15, x0

    ubfx    x0, x8, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x16, x16, x0

    ubfx    x0, x9, #24, #8
    ldr     x0, [x22, x0, lsl #3]
    eor     x17, x17, x0

    // byte 4
    ubfx    x0, x2, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x10, x10, x0

    ubfx    x0, x3, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x11, x11, x0

    ubfx    x0, x4, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x12, x12, x0

    ubfx    x0, x5, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x13, x13, x0

    ubfx    x0, x6, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x14, x14, x0

    ubfx    x0, x7, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x15, x15, x0

    ubfx    x0, x8, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x16, x16, x0

    ubfx    x0, x9, #32, #8
    ldr     x0, [x23, x0, lsl #3]
    eor     x17, x17, x0

    // byte 5
    ubfx    x0, x2, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x10, x10, x0

    ubfx    x0, x3, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x11, x11, x0

    ubfx    x0, x4, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x12, x12, x0

    ubfx    x0, x5, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x13, x13, x0

    ubfx    x0, x6, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x14, x14, x0

    ubfx    x0, x7, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x15, x15, x0

    ubfx    x0, x8, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x16, x16, x0

    ubfx    x0, x9, #40, #8
    ldr     x0, [x24, x0, lsl #3]
    eor     x17, x17, x0

    // byte 6
    ubfx    x0, x2, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x10, x10, x0

    ubfx    x0, x3, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x11, x11, x0

    ubfx    x0, x4, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x12, x12, x0

    ubfx    x0, x5, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x13, x13, x0

    ubfx    x0, x6, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x14, x14, x0

    ubfx    x0, x7, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x15, x15, x0

    ubfx    x0, x8, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x16, x16, x0

    ubfx    x0, x9, #48, #8
    ldr     x0, [x25, x0, lsl #3]
    eor     x17, x17, x0

    // byte 7 (most significant), use logical shift right to extract 
    lsr     x0, x2, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x10, x10, x0

    lsr     x0, x3, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x11, x11, x0

    lsr     x0, x4, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x12, x12, x0

    lsr     x0, x5, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x13, x13, x0

    lsr     x0, x6, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x14, x14, x0

    lsr     x0, x7, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x15, x15, x0

    lsr     x0, x8, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x16, x16, x0

    lsr     x0, x9, #56
    ldr     x0, [x26, x0, lsl #3]
    eor     x17, x17, x0

    // Byte-swap registers to emulate big-endian memory storage for GOST
    rev     x10, x10
    rev     x11, x11
    rev     x12, x12
    rev     x13, x13
    rev     x14, x14
    rev     x15, x15
    rev     x16, x16
    rev     x17, x17

    // Store 64-bit words in memory (as big-endian for GOST)
    stp     x10, x11, [x1, #0]
    stp     x12, x13, [x1, #16]
    stp     x14, x15, [x1, #32]
    stp     x16, x17, [x1, #48]

    // Restore callee-saved registers and frame pointer
    ldp     x25, x26, [sp, #64]
    ldp     x23, x24, [sp, #48]
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #80   
    ret