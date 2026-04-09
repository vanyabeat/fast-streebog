.DATA
ALIGN 16
P_TABLE DB  0,  8, 16, 24, 32, 40, 48, 56
        DB  1,  9, 17, 25, 33, 41, 49, 57
        DB  2, 10, 18, 26, 34, 42, 50, 58
        DB  3, 11, 19, 27, 35, 43, 51, 59
        DB  4, 12, 20, 28, 36, 44, 52, 60
        DB  5, 13, 21, 29, 37, 45, 53, 61
        DB  6, 14, 22, 30, 38, 46, 54, 62
        DB  7, 15, 23, 31, 39, 47, 55, 63

.CODE

streebog_p_transform_sse2 PROC
    push rbx
    push rsi
    push rdi

    sub rsp, 64                         ; allocate 64-byte temporary buffer on stack

    ; Copy input block into temporary buffer to allow in-place transforms
    movdqu xmm0, XMMWORD PTR [rcx]      ; load first 16 bytes
    movdqu xmm1, XMMWORD PTR [rcx+16]   ; next 16 bytes
    movdqu xmm2, XMMWORD PTR [rcx+32]
    movdqu xmm3, XMMWORD PTR [rcx+48]
    movdqu XMMWORD PTR [rsp], xmm0      ; store in temporary buffer 
    movdqu XMMWORD PTR [rsp+16], xmm1
    movdqu XMMWORD PTR [rsp+32], xmm2
    movdqu XMMWORD PTR [rsp+48], xmm3

    ; Setup source and destination pointers
    mov rsi, rsp                        ; rsi = temporary buffer
    mov rdi, rdx                        ; rdi = output buffer
    lea rbx, P_TABLE                    ; rbx = permutation table

    xor r8d, r8d                        ; loop counter i = 0

loop_start:
    movzx eax, BYTE PTR [rbx + r8]      ; load permutation index
    mov dl, BYTE PTR [rsi + rax]        ; get value temp
    mov BYTE PTR [rdi + r8], dl         ; store into output
    inc r8
    cmp r8, 64
    jl loop_start ; loop until 64 bytes done

    add rsp, 64                         ; free temporary buffer

    pop rdi
    pop rsi
    pop rbx
    ret

streebog_p_transform_sse2 ENDP
END