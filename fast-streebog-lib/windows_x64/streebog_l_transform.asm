; Optimized Streebog L-transform using precalculated lookup tables
; This version uses table lookups instead of bit-by-bit operations
; Expected speedup: 8-35x faster than the original implementation

.data
ALIGN 16

; Include precalculated Ax tables
INCLUDE streebog_precalc_tables.asm

.code

streebog_l_transform PROC
    ; rcx = input pointer (const uint8_t *state)
    ; rdx = output pointer (uint8_t *out)
    
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    
    mov rsi, rcx        ; rsi = input
    mov rdi, rdx        ; rdi = output
    
    ; Process 8 blocks of 8 bytes each
    xor r12, r12        ; r12 = block counter (0-7)
    
process_block:
    ; Load 8 bytes from input block
    movzx rax, BYTE PTR [rsi + r12*8 + 0]   ; byte 0
    movzx rbx, BYTE PTR [rsi + r12*8 + 1]   ; byte 1
    movzx rcx, BYTE PTR [rsi + r12*8 + 2]   ; byte 2
    movzx r8,  BYTE PTR [rsi + r12*8 + 3]   ; byte 3
    movzx r9,  BYTE PTR [rsi + r12*8 + 4]   ; byte 4
    movzx r10, BYTE PTR [rsi + r12*8 + 5]   ; byte 5
    movzx r11, BYTE PTR [rsi + r12*8 + 6]   ; byte 6
    movzx r13, BYTE PTR [rsi + r12*8 + 7]   ; byte 7
    
    ; Lookup in tables: result = Ax[0][byte0] ^ Ax[1][byte1] ^ ... ^ Ax[7][byte7]
    lea r14, [Ax_COL0]
    mov r15, QWORD PTR [r14 + rax*8]        ; r15 = Ax[0][byte0]
    
    lea r14, [Ax_COL1]
    xor r15, QWORD PTR [r14 + rbx*8]        ; r15 ^= Ax[1][byte1]
    
    lea r14, [Ax_COL2]
    xor r15, QWORD PTR [r14 + rcx*8]        ; r15 ^= Ax[2][byte2]
    
    lea r14, [Ax_COL3]
    xor r15, QWORD PTR [r14 + r8*8]         ; r15 ^= Ax[3][byte3]
    
    lea r14, [Ax_COL4]
    xor r15, QWORD PTR [r14 + r9*8]         ; r15 ^= Ax[4][byte4]
    
    lea r14, [Ax_COL5]
    xor r15, QWORD PTR [r14 + r10*8]        ; r15 ^= Ax[5][byte5]
    
    lea r14, [Ax_COL6]
    xor r15, QWORD PTR [r14 + r11*8]        ; r15 ^= Ax[6][byte6]
    
    lea r14, [Ax_COL7]
    xor r15, QWORD PTR [r14 + r13*8]        ; r15 ^= Ax[7][byte7]
    
    ; Convert to big-endian and store
    bswap r15
    mov QWORD PTR [rdi + r12*8], r15
    
    ; Next block
    inc r12
    cmp r12, 8
    jl process_block
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
streebog_l_transform ENDP

END