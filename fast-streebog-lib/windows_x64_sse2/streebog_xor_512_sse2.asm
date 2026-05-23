.CODE

streebog_xor_512_sse2 PROC

    ; rcx = a, rdx = b, r8 = out 
    ; Load 512-bit input a into XMM registers
    movdqu xmm0, XMMWORD PTR [rcx]
    movdqu xmm1, XMMWORD PTR [rcx + 16]
    movdqu xmm2, XMMWORD PTR [rcx + 32]
    movdqu xmm3, XMMWORD PTR [rcx + 48]

    ; XOR with 512-bit input b directly from memory
    pxor xmm0, XMMWORD PTR [rdx]
    pxor xmm1, XMMWORD PTR [rdx + 16]
    pxor xmm2, XMMWORD PTR [rdx + 32]
    pxor xmm3, XMMWORD PTR [rdx + 48]

    ; Store the 512-bit XOR result to output pointer 
    movdqu XMMWORD PTR [r8], xmm0
    movdqu XMMWORD PTR [r8 + 16], xmm1
    movdqu XMMWORD PTR [r8 + 32], xmm2
    movdqu XMMWORD PTR [r8 + 48], xmm3
    ret

streebog_xor_512_sse2 ENDP

END