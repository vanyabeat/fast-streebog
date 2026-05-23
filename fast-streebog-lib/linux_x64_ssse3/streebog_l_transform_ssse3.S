.intel_syntax noprefix
    .section .text
    .align 16
    .globl streebog_l_transform_ssse3
    .type  streebog_l_transform_ssse3, @function

streebog_l_transform_ssse3:

    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp             # 6 pushes = 48 bytes, RSP already aligned
    sub     rsp, 8          # align to 16 + ptr

    mov     rbp, rdi        # save input ptr
    mov     r12, rsi        # save output ptr

    # load all 8 column table base addresses into registers
    lea     r13, [rip + Ax_COL0]
    lea     r14, [rip + Ax_COL1]
    lea     r15, [rip + Ax_COL2]

    xor     ebx, ebx        # block counter = 0

.Lprocess_block:

    # load 8 byte indices for this block
    movzx   rax, BYTE PTR [rbp + rbx*8 + 0]
    mov     rcx, [r13 + rax*8]             # COL0[b0]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 1]
    xor     rcx, [r14 + rax*8]             # ^ COL1[b1]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 2]
    xor     rcx, [r15 + rax*8]             # ^ COL2[b2]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 3]
    lea     rdx, [rip + Ax_COL3]
    xor     rcx, [rdx + rax*8]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 4]
    lea     rdx, [rip + Ax_COL4]
    xor     rcx, [rdx + rax*8]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 5]
    lea     rdx, [rip + Ax_COL5]
    xor     rcx, [rdx + rax*8]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 6]
    lea     rdx, [rip + Ax_COL6]
    xor     rcx, [rdx + rax*8]

    movzx   rax, BYTE PTR [rbp + rbx*8 + 7]
    lea     rdx, [rip + Ax_COL7]
    xor     rcx, [rdx + rax*8]

    bswap   rcx
    mov     [r12 + rbx*8], rcx

    inc     ebx
    cmp     ebx, 8
    jl      .Lprocess_block

    add     rsp, 8
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

    .size streebog_l_transform_ssse3, . - streebog_l_transform_ssse3
    .section .note.GNU-stack,"",@progbits