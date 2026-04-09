.data

CONST_FF dq 8 DUP (000000000000000FFh)

INCLUDE streebog_precalc_tables_avx512.asm

.code

streebog_l_transform_avx512 PROC

    vmovdqa64 zmm8,  ZMMWORD PTR [rcx]          ; load input block (all bytes at once)
    vmovdqa64 zmm10, ZMMWORD PTR [CONST_FF]     ; load constant 0xFF for masking

    ; process byte 0 of each column
    vpandq    zmm9,  zmm8,  zmm10               ; isolate 0th byte of all 64-bit lanes
    vmovdqa64 zmm0,  ZMMWORD PTR [Ax_COL0]      ; load precomputed multiplication table for column 0
    vpermb    zmm16, zmm9,  zmm0                ; shuffle/multiply using byte indices

    ; process byte 1
    vpsrlq    zmm9,  zmm8,  8                   ; shift right by 1 byte
    vpandq    zmm9,  zmm9,  zmm10               ; mask low byte
    vmovdqa64 zmm1,  ZMMWORD PTR [Ax_COL1]
    vpermb    zmm17, zmm9,  zmm1

    ; process byte 2
    vpsrlq    zmm9,  zmm8,  16
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm2,  ZMMWORD PTR [Ax_COL2]
    vpermb    zmm18, zmm9,  zmm2

    ; process byte 3
    vpsrlq    zmm9,  zmm8,  24
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm3,  ZMMWORD PTR [Ax_COL3]
    vpermb    zmm19, zmm9,  zmm3

    ; process byte 4
    vpsrlq    zmm9,  zmm8,  32
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm4,  ZMMWORD PTR [Ax_COL4]
    vpermb    zmm20, zmm9,  zmm4

   ; process byte 5
    vpsrlq    zmm9,  zmm8,  40
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm5,  ZMMWORD PTR [Ax_COL5]
    vpermb    zmm21, zmm9,  zmm5

    ; process byte 6
    vpsrlq    zmm9,  zmm8,  48
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm6,  ZMMWORD PTR [Ax_COL6]
    vpermb    zmm22, zmm9,  zmm6

    ; process byte 7
    vpsrlq    zmm9,  zmm8,  56
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm7,  ZMMWORD PTR [Ax_COL7]
    vpermb    zmm23, zmm9,  zmm7

    ; XOR all transformed bytes together (parallel)
    vpxorq    zmm16, zmm16, zmm17
    vpxorq    zmm18, zmm18, zmm19
    vpxorq    zmm20, zmm20, zmm21
    vpxorq    zmm22, zmm22, zmm23

    vpxorq    zmm16, zmm16, zmm18
    vpxorq    zmm20, zmm20, zmm22

    vpxorq    zmm24, zmm16, zmm20

    vmovdqa64 ZMMWORD PTR [rdx], zmm24         ; store result to output 
    vzeroupper                                 ; clear upper parts of YMM/ZMM

    ret
streebog_l_transform_avx512 ENDP
END