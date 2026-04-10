.data
ALIGN 16

; Byte swap mask for vpshufb - reverses byte order within each 64-bit qword
; Pattern repeats every 16 bytes to cover all 64 bytes of ZMM register
BSWAP_MASK dq 0001020304050607h, 08090A0B0C0D0E0Fh,\
              0001020304050607h, 08090A0B0C0D0E0Fh,\
              0001020304050607h, 08090A0B0C0D0E0Fh,\
              0001020304050607h, 08090A0B0C0D0E0Fh

; Mask to extract the least significant byte (0xFF) from each 64-bit element
CONST_FF dq 8 DUP (000000000000000FFh)

INCLUDE streebog_precalc_tables_avx512.asm

.code

streebog_l_transform_avx512 PROC
    ; rcx = input, rdx = output

    ; Load entire 64-byte input block as 8 qwords into zmm8
    vmovdqu64 zmm8, ZMMWORD PTR [rcx]

    ; Extract byte 0 from each qword for first lookup table (Column 0)
    vpandq    zmm0, zmm8, ZMMWORD PTR [CONST_FF]   ; byte 0 of all 8 qwords
    vpsrlq    zmm1, zmm8, 8 ; Extract bytes 1..7 by shifting right and masking
    vpandq    zmm1, zmm1, ZMMWORD PTR [CONST_FF]   ; byte 1 of all 8 qwords
    vpsrlq    zmm2, zmm8, 16
    vpandq    zmm2, zmm2, ZMMWORD PTR [CONST_FF]; byte 2 of all 8 qwords
    vpsrlq    zmm3, zmm8, 24
    vpandq    zmm3, zmm3, ZMMWORD PTR [CONST_FF]; byte 3 of all 8 qwords
    vpsrlq    zmm4, zmm8, 32
    vpandq    zmm4, zmm4, ZMMWORD PTR [CONST_FF]; byte 4 of all 8 qwords
    vpsrlq    zmm5, zmm8, 40
    vpandq    zmm5, zmm5, ZMMWORD PTR [CONST_FF]; byte 5 of all 8 qwords
    vpsrlq    zmm6, zmm8, 48
    vpandq    zmm6, zmm6, ZMMWORD PTR [CONST_FF]; byte 6 of all 8 qwords
    vpsrlq    zmm7, zmm8, 56
    vpandq    zmm7, zmm7, ZMMWORD PTR [CONST_FF] ; byte 7 of all 8 qwords

    ; Compute gather offsets (index * 8 for qword-sized elements)
    ; Multiply each byte index by 8 to get byte offset into lookup tables
    vpsllq    zmm0, zmm0, 3
    vpsllq    zmm1, zmm1, 3
    vpsllq    zmm2, zmm2, 3
    vpsllq    zmm3, zmm3, 3
    vpsllq    zmm4, zmm4, 3
    vpsllq    zmm5, zmm5, 3
    vpsllq    zmm6, zmm6, 3
    vpsllq    zmm7, zmm7, 3

    ; Gather from Column 0 table
    mov       rax, OFFSET Ax_COL0
    kxnorw    k1, k0, k0
    vpgatherqq zmm16{k1}, [rax + zmm0]         ; zmm17[i] = Ax_COL1[input_byte1[i]]

    ; Gather from Column 2 table
    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL1
    vpgatherqq zmm17{k1}, [rax + zmm1]

    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL2
    vpgatherqq zmm18{k1}, [rax + zmm2]

    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL3
    vpgatherqq zmm19{k1}, [rax + zmm3]

    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL4
    vpgatherqq zmm20{k1}, [rax + zmm4]

    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL5
    vpgatherqq zmm21{k1}, [rax + zmm5]

    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL6
    vpgatherqq zmm22{k1}, [rax + zmm6]

    kxnorw    k1, k0, k0
    mov       rax, OFFSET Ax_COL7
    vpgatherqq zmm23{k1}, [rax + zmm7]

    ; XOR tree (parallel)
    vpxorq    zmm16, zmm16, zmm17
    vpxorq    zmm18, zmm18, zmm19
    vpxorq    zmm20, zmm20, zmm21
    vpxorq    zmm22, zmm22, zmm23

    vpxorq    zmm16, zmm16, zmm18
    vpxorq    zmm20, zmm20, zmm22

    vpxorq    zmm16, zmm16, zmm20

    ; The lookup tables were generated in Big-Endian byte order, but Streebog
    ; requires Little-Endian representation within each 64-bit word.
    vmovdqu64 zmm25, ZMMWORD PTR [BSWAP_MASK]
    vpshufb   zmm16, zmm16, zmm25

    ; Store the 8 qword results to output buffer
    vmovdqu64 ZMMWORD PTR [rdx], zmm16
    vzeroupper

    ret
streebog_l_transform_avx512 ENDP
END