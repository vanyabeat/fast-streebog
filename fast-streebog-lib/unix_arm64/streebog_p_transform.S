.text
.align 4
.global _streebog_p_transform

// TAU permutation table (64 bytes)
.align 4
STREEBOG_TAU:
.byte  0,  8, 16, 24, 32, 40, 48, 56
.byte  1,  9, 17, 25, 33, 41, 49, 57
.byte  2, 10, 18, 26, 34, 42, 50, 58
.byte  3, 11, 19, 27, 35, 43, 51, 59
.byte  4, 12, 20, 28, 36, 44, 52, 60
.byte  5, 13, 21, 29, 37, 45, 53, 61
.byte  6, 14, 22, 30, 38, 46, 54, 62
.byte  7, 15, 23, 31, 39, 47, 55, 63

_streebog_p_transform:
    // x0 = state (input pointer)
    // x1 = out (output pointer)
    
    // Allocate 64 bytes on stack for temporary buffer
    sub     sp, sp, #80         // Allocate 80 bytes (64 + 16 for alignment)
    
    // Save frame pointer
    stp     x29, x30, [sp, #64]
    add     x29, sp, #64
    
    // Get address of TAU table
    adrp    x2, STREEBOG_TAU@PAGE
    add     x2, x2, STREEBOG_TAU@PAGEOFF
    
    // Use sp as temporary output buffer
    mov     x3, sp              // x3 = temp buffer
    mov     x4, #64             // Counter
    mov     x5, x2              // Save TAU pointer
    
.Lperm_loop:
    ldrb    w6, [x2], #1        // Load permutation index from TAU
    ldrb    w7, [x0, w6, uxtw]  // Load byte from state[TAU[i]]
    strb    w7, [x3], #1        // Store to temp buffer
    subs    x4, x4, #1          // Decrement counter
    b.ne    .Lperm_loop         // Loop if not zero
    
    // Copy from temp buffer to output
    mov     x3, sp              // Reset temp buffer pointer
    mov     x4, #64             // Reset counter
    
.Lcopy_loop:
    ldrb    w6, [x3], #1        // Load from temp
    strb    w6, [x1], #1        // Store to output
    subs    x4, x4, #1          // Decrement counter
    b.ne    .Lcopy_loop         // Loop if not zero
    
    // Restore frame pointer and deallocate stack
    ldp     x29, x30, [sp, #64]
    add     sp, sp, #80
    
    ret
