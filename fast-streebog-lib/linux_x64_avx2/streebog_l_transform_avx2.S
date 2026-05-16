.intel_syntax noprefix

    .section .text
    .align 16
    .globl streebog_l_transform_avx2
    .type  streebog_l_transform_avx2, @function

streebog_l_transform_avx2:

    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp                 # 6 pushes = 48 bytes
    sub     rsp, 8              # align to 16

    mov     rbp, rdi            # input
    # rsi = output (already in place)

    prefetcht0 [rbp]
    prefetcht0 [rbp + 32]

    lea     rax, [rip + Ax_T]

    # Row 0
    movzx   r8,  BYTE PTR [rbp + 0]
    movzx   r9,  BYTE PTR [rbp + 1]
    movzx   r10, BYTE PTR [rbp + 2]
    movzx   r11, BYTE PTR [rbp + 3]
    movzx   r12, BYTE PTR [rbp + 4]
    movzx   r13, BYTE PTR [rbp + 5]
    movzx   r14, BYTE PTR [rbp + 6]
    movzx   r15, BYTE PTR [rbp + 7]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 0], rbx

    # Row 1
    movzx   r8,  BYTE PTR [rbp + 8]
    movzx   r9,  BYTE PTR [rbp + 9]
    movzx   r10, BYTE PTR [rbp + 10]
    movzx   r11, BYTE PTR [rbp + 11]
    movzx   r12, BYTE PTR [rbp + 12]
    movzx   r13, BYTE PTR [rbp + 13]
    movzx   r14, BYTE PTR [rbp + 14]
    movzx   r15, BYTE PTR [rbp + 15]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 8], rbx

    # Row 2
    movzx   r8,  BYTE PTR [rbp + 16]
    movzx   r9,  BYTE PTR [rbp + 17]
    movzx   r10, BYTE PTR [rbp + 18]
    movzx   r11, BYTE PTR [rbp + 19]
    movzx   r12, BYTE PTR [rbp + 20]
    movzx   r13, BYTE PTR [rbp + 21]
    movzx   r14, BYTE PTR [rbp + 22]
    movzx   r15, BYTE PTR [rbp + 23]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 16], rbx

    # Row 3
    movzx   r8,  BYTE PTR [rbp + 24]
    movzx   r9,  BYTE PTR [rbp + 25]
    movzx   r10, BYTE PTR [rbp + 26]
    movzx   r11, BYTE PTR [rbp + 27]
    movzx   r12, BYTE PTR [rbp + 28]
    movzx   r13, BYTE PTR [rbp + 29]
    movzx   r14, BYTE PTR [rbp + 30]
    movzx   r15, BYTE PTR [rbp + 31]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 24], rbx

    # Row 4
    movzx   r8,  BYTE PTR [rbp + 32]
    movzx   r9,  BYTE PTR [rbp + 33]
    movzx   r10, BYTE PTR [rbp + 34]
    movzx   r11, BYTE PTR [rbp + 35]
    movzx   r12, BYTE PTR [rbp + 36]
    movzx   r13, BYTE PTR [rbp + 37]
    movzx   r14, BYTE PTR [rbp + 38]
    movzx   r15, BYTE PTR [rbp + 39]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 32], rbx

    # Row 5
    movzx   r8,  BYTE PTR [rbp + 40]
    movzx   r9,  BYTE PTR [rbp + 41]
    movzx   r10, BYTE PTR [rbp + 42]
    movzx   r11, BYTE PTR [rbp + 43]
    movzx   r12, BYTE PTR [rbp + 44]
    movzx   r13, BYTE PTR [rbp + 45]
    movzx   r14, BYTE PTR [rbp + 46]
    movzx   r15, BYTE PTR [rbp + 47]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 40], rbx

    # Row 6
    movzx   r8,  BYTE PTR [rbp + 48]
    movzx   r9,  BYTE PTR [rbp + 49]
    movzx   r10, BYTE PTR [rbp + 50]
    movzx   r11, BYTE PTR [rbp + 51]
    movzx   r12, BYTE PTR [rbp + 52]
    movzx   r13, BYTE PTR [rbp + 53]
    movzx   r14, BYTE PTR [rbp + 54]
    movzx   r15, BYTE PTR [rbp + 55]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 48], rbx

    # Row 7
    movzx   r8,  BYTE PTR [rbp + 56]
    movzx   r9,  BYTE PTR [rbp + 57]
    movzx   r10, BYTE PTR [rbp + 58]
    movzx   r11, BYTE PTR [rbp + 59]
    movzx   r12, BYTE PTR [rbp + 60]
    movzx   r13, BYTE PTR [rbp + 61]
    movzx   r14, BYTE PTR [rbp + 62]
    movzx   r15, BYTE PTR [rbp + 63]
    shl     r8,  6
    shl     r9,  6
    shl     r10, 6
    shl     r11, 6
    shl     r12, 6
    shl     r13, 6
    shl     r14, 6
    shl     r15, 6
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rsi + 56], rbx

    vzeroupper

    add     rsp, 8
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

    .size streebog_l_transform_avx2, . - streebog_l_transform_avx2
    .section .note.GNU-stack,"",@progbits