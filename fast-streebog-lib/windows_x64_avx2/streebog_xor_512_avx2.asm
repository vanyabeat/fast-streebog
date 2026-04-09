.CODE

; rcx = a, rdx = b, r8 = out
streebog_xor_512_avx2 PROC

    vmovdqu ymm0, YMMWORD PTR [rcx]
    vmovdqu ymm1, YMMWORD PTR [rcx + 32]

    vpxor ymm0, ymm0, YMMWORD PTR [rdx]
    vpxor ymm1, ymm1, YMMWORD PTR [rdx + 32]

    vmovdqu YMMWORD PTR [r8], ymm0 
    vmovdqu YMMWORD PTR [r8 + 32], ymm1

    vzeroupper
    ret

streebog_xor_512_avx2 ENDP

END