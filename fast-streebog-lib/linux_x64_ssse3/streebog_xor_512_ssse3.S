.intel_syntax noprefix

    .section .text
    .align 16
    .globl streebog_xor_512_ssse3
    .type  streebog_xor_512_ssse3, @function

streebog_xor_512_ssse3:

    movdqu xmm0, [rdi]
    movdqu xmm1, [rdi + 16]
    movdqu xmm2, [rdi + 32]
    movdqu xmm3, [rdi + 48]

    pxor xmm0, [rsi]
    pxor xmm1, [rsi + 16]
    pxor xmm2, [rsi + 32]
    pxor xmm3, [rsi + 48]

    movdqu [rdx], xmm0
    movdqu [rdx + 16], xmm1
    movdqu [rdx + 32], xmm2
    movdqu [rdx + 48], xmm3

    ret

    .size streebog_xor_512_ssse3, . - streebog_xor_512_ssse3