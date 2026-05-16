.intel_syntax noprefix

    .section .text
    .align 16
    .globl streebog_xor_512_avx2
    .type  streebog_xor_512_avx2, @function

streebog_xor_512_avx2:

    vmovdqu ymm0, [rdi]
    vmovdqu ymm1, [rdi + 32]

    vpxor ymm0, ymm0, [rsi]
    vpxor ymm1, ymm1, [rsi + 32]

    vmovdqu [rdx], ymm0
    vmovdqu [rdx + 32], ymm1

    vzeroupper
    ret

    .size streebog_xor_512_avx2, . - streebog_xor_512_avx2
    .section .note.GNU-stack,"",@progbits