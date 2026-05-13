.data
ALIGN 16

INCLUDE streebog_precalc_tables_avx2.asm

.code

streebog_l_transform_avx2 PROC

    ; Save registers
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    push    r15

    mov     rsi, rcx ; input
    mov     rdi, rdx ; output = input

    ; Prefetch input block to reduce memory latency
    prefetcht0 [rsi]
    prefetcht0 [rsi + 32]

    ; Load pointer to precomputed L-table
    mov     rax, OFFSET Ax_T

    ; Row 0
    ; Load the 8 bytes of the row into registers
    movzx   r8,  BYTE PTR [rsi + 0]
    movzx   r9,  BYTE PTR [rsi + 1]
    movzx   r10, BYTE PTR [rsi + 2]
    movzx   r11, BYTE PTR [rsi + 3]
    movzx   r12, BYTE PTR [rsi + 4]
    movzx   r13, BYTE PTR [rsi + 5]
    movzx   r14, BYTE PTR [rsi + 6]
    movzx   r15, BYTE PTR [rsi + 7]

    ; Multiply by 64 to convert byte index to table offset
    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    ; XOR 8 table entries to compute L-transform of the row
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx              ; Convert to big-endian for GOST standard
    mov     [rdi + 0], rbx

    ; Row 1
    movzx   r8,  BYTE PTR [rsi + 8]
    movzx   r9,  BYTE PTR [rsi + 9]
    movzx   r10, BYTE PTR [rsi + 10]
    movzx   r11, BYTE PTR [rsi + 11]
    movzx   r12, BYTE PTR [rsi + 12]
    movzx   r13, BYTE PTR [rsi + 13]
    movzx   r14, BYTE PTR [rsi + 14]
    movzx   r15, BYTE PTR [rsi + 15]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 8], rbx

    ; Row 2
    movzx   r8,  BYTE PTR [rsi + 16]
    movzx   r9,  BYTE PTR [rsi + 17]
    movzx   r10, BYTE PTR [rsi + 18]
    movzx   r11, BYTE PTR [rsi + 19]
    movzx   r12, BYTE PTR [rsi + 20]
    movzx   r13, BYTE PTR [rsi + 21]
    movzx   r14, BYTE PTR [rsi + 22]
    movzx   r15, BYTE PTR [rsi + 23]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 16], rbx

    ; Row 3
    movzx   r8,  BYTE PTR [rsi + 24]
    movzx   r9,  BYTE PTR [rsi + 25]
    movzx   r10, BYTE PTR [rsi + 26]
    movzx   r11, BYTE PTR [rsi + 27]
    movzx   r12, BYTE PTR [rsi + 28]
    movzx   r13, BYTE PTR [rsi + 29]
    movzx   r14, BYTE PTR [rsi + 30]
    movzx   r15, BYTE PTR [rsi + 31]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 24], rbx

    ; Row 4
    movzx   r8,  BYTE PTR [rsi + 32]
    movzx   r9,  BYTE PTR [rsi + 33]
    movzx   r10, BYTE PTR [rsi + 34]
    movzx   r11, BYTE PTR [rsi + 35]
    movzx   r12, BYTE PTR [rsi + 36]
    movzx   r13, BYTE PTR [rsi + 37]
    movzx   r14, BYTE PTR [rsi + 38]
    movzx   r15, BYTE PTR [rsi + 39]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 32], rbx

    ; Row 5
    movzx   r8,  BYTE PTR [rsi + 40]
    movzx   r9,  BYTE PTR [rsi + 41]
    movzx   r10, BYTE PTR [rsi + 42]
    movzx   r11, BYTE PTR [rsi + 43]
    movzx   r12, BYTE PTR [rsi + 44]
    movzx   r13, BYTE PTR [rsi + 45]
    movzx   r14, BYTE PTR [rsi + 46]
    movzx   r15, BYTE PTR [rsi + 47]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 40], rbx

    ; Row 6
    movzx   r8,  BYTE PTR [rsi + 48]
    movzx   r9,  BYTE PTR [rsi + 49]
    movzx   r10, BYTE PTR [rsi + 50]
    movzx   r11, BYTE PTR [rsi + 51]
    movzx   r12, BYTE PTR [rsi + 52]
    movzx   r13, BYTE PTR [rsi + 53]
    movzx   r14, BYTE PTR [rsi + 54]
    movzx   r15, BYTE PTR [rsi + 55]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 48], rbx

    ; Row 7
    movzx   r8,  BYTE PTR [rsi + 56]
    movzx   r9,  BYTE PTR [rsi + 57]
    movzx   r10, BYTE PTR [rsi + 58]
    movzx   r11, BYTE PTR [rsi + 59]
    movzx   r12, BYTE PTR [rsi + 60]
    movzx   r13, BYTE PTR [rsi + 61]
    movzx   r14, BYTE PTR [rsi + 62]
    movzx   r15, BYTE PTR [rsi + 63]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 56], rbx


    vzeroupper      ; Clear upper parts of YMM registers 

    ; Restore registers
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    ret
streebog_l_transform_avx2 ENDP

END
