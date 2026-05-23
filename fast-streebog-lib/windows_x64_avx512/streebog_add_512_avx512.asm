.CODE
streebog_add_512_avx512 PROC
    push rbx         ; save rbx 
    
    xor rax, rax     ; initialize carry to 0
    mov r9, 56       ; start from the last 8-byte block (512 bits / 8 = 64 bytes, index = 56)           
    
add_loop:
    mov r10, [rcx + r9] ; load 8 bytes from first operand
    mov r11, [rdx + r9] ; load 8 bytes from second operand

    bswap r10        ; convert from little endian to big endian
    bswap r11
    
    add r10, rax     ; add carry from previous block
    setc al          ; store new carry in AL
    movzx rax, al    ; zero-extend AL to RAX
    
    add r10, r11     ; add the other operand           
    setc bl          ; store carry from this addition in BL           
    movzx rbx, bl    ; zero-extend BL to RBX
    add rax, rbx     ; combine carries         
    
    bswap r10       ; convert back to little endian     
    mov [r8 + r9], r10 ; store result in destination
    
    sub r9, 8       ; move to the previous 8-byte block
    jge add_loop    ; repeat until all blocks are processed
    
    pop rbx         ; restore rbx
    ret
streebog_add_512_avx512 ENDP
END