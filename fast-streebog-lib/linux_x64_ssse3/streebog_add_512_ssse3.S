.intel_syntax noprefix


    .section .text
    .align 16
    .globl streebog_add_512_ssse3
    .type  streebog_add_512_ssse3, @function

streebog_add_512_ssse3:

    push    rbx

    xor     eax, eax        # carry = 0
    mov     r9,  56

add_loop:
    mov     r10, [rdi + r9]  # a[i]
    mov     r11, [rsi + r9]  # b[i]

    bswap   r10
    bswap   r11

    add     r10, rax        # + carry
    setc    al
    movzx   rax, al         # carry from first add

    add     r10, r11
    setc    bl
    movzx   rbx, bl
    add     rax, rbx        # combine carry values

    bswap   r10
    mov     [rdx + r9], r10  # out[i]

    sub     r9, 8
    jge     add_loop

    pop     rbx
    ret

    .size streebog_add_512_ssse3, . - streebog_add_512_ssse3
    .section .note.GNU-stack,"",@progbits