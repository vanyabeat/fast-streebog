.text
.align 4
.global _streebog_l_transform

_streebog_l_transform:
    // x0 = state (input pointer)
    // x1 = out (output pointer)
    
    // Save callee-saved registers
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    
    // Process 8 blocks (i = 0..7)
    mov     x3, #0                  // i = 0
    
.Lblock_loop:
    // Calculate block offset: state + i * 8
    add     x4, x0, x3, lsl #3      // x4 = state + (i * 8)
    
    // Load 8 bytes from block
    ldrb    w5, [x4, #0]            // block[0]
    ldrb    w6, [x4, #1]            // block[1]
    ldrb    w7, [x4, #2]            // block[2]
    ldrb    w8, [x4, #3]            // block[3]
    ldrb    w9, [x4, #4]            // block[4]
    ldrb    w10, [x4, #5]           // block[5]
    ldrb    w11, [x4, #6]           // block[6]
    ldrb    w12, [x4, #7]           // block[7]
    
    // Lookup in tables: result = Ax_COL0[byte0] ^ Ax_COL1[byte1] ^ ... ^ Ax_COL7[byte7]
    adrp    x13, _Ax_COL0@PAGE
    add     x13, x13, _Ax_COL0@PAGEOFF
    ldr     x19, [x13, x5, lsl #3]  // result = Ax_COL0[block[0]]
    
    adrp    x13, _Ax_COL1@PAGE
    add     x13, x13, _Ax_COL1@PAGEOFF
    ldr     x20, [x13, x6, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL1[block[1]]
    
    adrp    x13, _Ax_COL2@PAGE
    add     x13, x13, _Ax_COL2@PAGEOFF
    ldr     x20, [x13, x7, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL2[block[2]]
    
    adrp    x13, _Ax_COL3@PAGE
    add     x13, x13, _Ax_COL3@PAGEOFF
    ldr     x20, [x13, x8, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL3[block[3]]
    
    adrp    x13, _Ax_COL4@PAGE
    add     x13, x13, _Ax_COL4@PAGEOFF
    ldr     x20, [x13, x9, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL4[block[4]]
    
    adrp    x13, _Ax_COL5@PAGE
    add     x13, x13, _Ax_COL5@PAGEOFF
    ldr     x20, [x13, x10, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL5[block[5]]
    
    adrp    x13, _Ax_COL6@PAGE
    add     x13, x13, _Ax_COL6@PAGEOFF
    ldr     x20, [x13, x11, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL6[block[6]]
    
    adrp    x13, _Ax_COL7@PAGE
    add     x13, x13, _Ax_COL7@PAGEOFF
    ldr     x20, [x13, x12, lsl #3]
    eor     x19, x19, x20           // result ^= Ax_COL7[block[7]]
    
    // Store result as big-endian (reverse byte order)
    add     x21, x1, x3, lsl #3     // out + (i * 8)
    rev     x19, x19                // Reverse to big-endian
    str     x19, [x21]              // Store 8 bytes
    
    // Increment loop counter
    add     x3, x3, #1
    cmp     x3, #8
    b.lt    .Lblock_loop
    
    // Restore callee-saved registers
    ldp     x23, x24, [sp, #48]
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #64
    ret
