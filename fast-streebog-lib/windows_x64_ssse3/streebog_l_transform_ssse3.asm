.data
ALIGN 16

INCLUDE streebog_precalc_tables_ssse3.asm

.code

streebog_l_transform_ssse3 PROC
    ; rcx = input pointer
    ; rdx = output pointer
    
    ; save registers
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    
    mov rsi, rcx    ; rsi = input pointer
    mov rdi, rdx    ; rdi = output pointer
    
    ; 8 blocks of 8 bytes each
    xor r12, r12    ; block counter (0-7)
    
process_block:

    ; load 8 bytes from input 
    movzx rax, BYTE PTR [rsi + r12*8 + 0] ; byte 0
    movzx rbx, BYTE PTR [rsi + r12*8 + 1] ; byte 1
    movzx rcx, BYTE PTR [rsi + r12*8 + 2] ; byte 2
    movzx r8,  BYTE PTR [rsi + r12*8 + 3] ; byte 3
    movzx r9,  BYTE PTR [rsi + r12*8 + 4] ; byte 4
    movzx r10, BYTE PTR [rsi + r12*8 + 5] ; byte 5
    movzx r11, BYTE PTR [rsi + r12*8 + 6] ; byte 6
    movzx r13, BYTE PTR [rsi + r12*8 + 7] ; byte 7
    
    ; start XORing columns, first load
    lea r14, [Ax_COL0]
    mov r15, QWORD PTR [r14 + rax*8]    ; r15 = Ax[0][byte0] 
    
    lea r14, [Ax_COL1]
    xor r15, QWORD PTR [r14 + rbx*8]    ; r15 ^= Ax[1][byte1]
    
    lea r14, [Ax_COL2]
    xor r15, QWORD PTR [r14 + rcx*8]    ; r15 ^= Ax[2][byte2]
    
    lea r14, [Ax_COL3]
    xor r15, QWORD PTR [r14 + r8*8]     ; r15 ^= Ax[3][byte3]
    
    lea r14, [Ax_COL4]
    xor r15, QWORD PTR [r14 + r9*8]     ; r15 ^= Ax[4][byte4]
    
    lea r14, [Ax_COL5]
    xor r15, QWORD PTR [r14 + r10*8]    ; r15 ^= Ax[5][byte5]
    
    lea r14, [Ax_COL6]
    xor r15, QWORD PTR [r14 + r11*8]    ; r15 ^= Ax[6][byte6]
    
    lea r14, [Ax_COL7]
    xor r15, QWORD PTR [r14 + r13*8]    ; r15 ^= Ax[7][byte7]
    
    ; convert to big-endian and store
    bswap r15
    mov QWORD PTR [rdi + r12*8], r15
    
    ; next block
    inc r12
    cmp r12, 8
    jl process_block
    
    ; restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
streebog_l_transform_ssse3 ENDP

END