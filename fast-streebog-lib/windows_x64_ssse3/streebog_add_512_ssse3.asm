.CODE

streebog_add_512_ssse3 PROC
    push    rbx

    xor     eax, eax        ; carry = 0
    mov     r9,  56

add_loop:
    mov     r10, [rcx + r9]
    mov     r11, [rdx + r9]

    bswap   r10
    bswap   r11

    add     r10, rax        ; + carry
    setc    al
    movzx   rax, al         ; carry from first add

    add     r10, r11
    setc    bl
    movzx   rbx, bl
    add     rax, rbx        ; add two carry values together 

    bswap   r10
    mov     [r8 + r9], r10

    sub     r9, 8
    jge     add_loop

    pop     rbx
    ret
streebog_add_512_ssse3 ENDP

END