.CODE
streebog_add_512 PROC
    push rbx
    
    xor rax, rax              
    mov r9, 56                
    
add_loop:
    mov r10, [rcx + r9]       
    mov r11, [rdx + r9]       
    
    bswap r10
    bswap r11
    
    add r10, rax              
    setc al                   
    movzx rax, al
    
    add r10, r11              
    setc bl                   
    movzx rbx, bl
    add rax, rbx              
    
    bswap r10                 
    mov [r8 + r9], r10        
    
    sub r9, 8                 
    jge add_loop              
    
    pop rbx
    ret
streebog_add_512 ENDP
END