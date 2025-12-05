.data
ALIGN 16

A_MATRIX:
    QWORD 08e20faa72ba0b470h  
    QWORD 047107ddd9b505a38h  
    QWORD 0ad08b0e0c3282d1ch  
    QWORD 0d8045870ef14980eh  
    QWORD 06c022c38f90a4c07h  
    QWORD 03601161cf205268dh  
    QWORD 01b8e0b0e798c13c8h  
    QWORD 083478b07b2468764h  
    QWORD 0a011d380818e8f40h  
    QWORD 05086e740ce47c920h  
    QWORD 02843fd2067adea10h  
    QWORD 014aff010bdd87508h  
    QWORD 00ad97808d06cb404h  
    QWORD 005e23c0468365a02h  
    QWORD 08c711e02341b2d01h  
    QWORD 046b60f011a83988eh  
    QWORD 090dab52a387ae76fh  
    QWORD 0486dd4151c3dfdb9h  
    QWORD 024b86a840e90f0d2h  
    QWORD 0125c354207487869h  
    QWORD 0092e94218d243cbah  
    QWORD 08a174a9ec8121e5dh  
    QWORD 04585254f64090fa0h  
    QWORD 0accc9ca9328a8950h  
    QWORD 09d4df05d5f661451h  
    QWORD 0c0a878a0a1330aa6h  
    QWORD 060543c50de970553h  
    QWORD 0302a1e286fc58ca7h  
    QWORD 018150f14b9ec46ddh  
    QWORD 00c84890ad27623e0h  
    QWORD 00642ca05693b9f70h  
    QWORD 00321658cba93c138h  
    QWORD 086275df09ce8aaa8h  
    QWORD 0439da0784e745554h  
    QWORD 0afc0503c273aa42ah  
    QWORD 0d960281e9d1d5215h  
    QWORD 0e230140fc0802984h  
    QWORD 071180a8960409a42h  
    QWORD 0b60c05ca30204d21h  
    QWORD 05b068c651810a89eh  
    QWORD 0456c34887a3805b9h  
    QWORD 0ac361a443d1c8cd2h  
    QWORD 0561b0d22900e4669h  
    QWORD 02b838811480723bah  
    QWORD 09bcf4486248d9f5dh  
    QWORD 0c3e9224312c8c1a0h  
    QWORD 0effa11af0964ee50h  
    QWORD 0f97d86d98a327728h  
    QWORD 0e4fa2054a80b329ch  
    QWORD 0727d102a548b194eh  
    QWORD 039b008152acb8227h  
    QWORD 09258048415eb419dh  
    QWORD 0492c024284fbaec0h  
    QWORD 0aa16012142f35760h  
    QWORD 0550b8e9e21f7a530h  
    QWORD 0a48b474f9ef5dc18h  
    QWORD 070a6a56e2440598eh  
    QWORD 03853dc371220a247h  
    QWORD 01ca76e95091051adh  
    QWORD 00edd37c48a08a6d8h  
    QWORD 007e095624504536ch  
    QWORD 08d70c431ac02a736h  
    QWORD 0c83862965601dd1bh  
    QWORD 0641c314b2b8ee083h  
.code

streebog_l_transform PROC
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    push rbp
    sub rsp, 64         
    
    mov rsi, rcx        
    mov rdi, rdx        
    
    xor r8, r8          
load_loop:
    mov rax, QWORD PTR [rsi + r8*8]
    bswap rax
    mov QWORD PTR [rsp + r8*8], rax
    inc r8
    cmp r8, 8
    jl load_loop
    
    xor r12, r12        

output_loop:
    
    mov r13, QWORD PTR [rsp + r12*8]
    
    xor r14, r14        
    xor r15, r15        
    
    lea rbp, QWORD PTR [A_MATRIX]
    
bit_loop:
    mov rax, r13
    mov rcx, r15
    shr rax, cl
    test rax, 1
    jz skip_xor
    
    mov rax, 63
    sub rax, r15        
    mov rcx, QWORD PTR [rbp + rax*8]
    xor r14, rcx
    
skip_xor:
    inc r15
    cmp r15, 64
    jl bit_loop
    
    mov rax, r14
    bswap rax
    mov QWORD PTR [rdi + r12*8], rax
    
    inc r12
    cmp r12, 8
    jl output_loop
    
    add rsp, 64
    pop rbp
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