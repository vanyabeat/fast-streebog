.DATA
ALIGN 16

; transition 0
tran00 DB 00h,08h,80h,80h,80h,80h,80h,80h,01h,09h,80h,80h,80h,80h,80h,80h
tran01 DB 80h,80h,00h,08h,80h,80h,80h,80h,80h,80h,01h,09h,80h,80h,80h,80h
tran02 DB 80h,80h,80h,80h,00h,08h,80h,80h,80h,80h,80h,80h,01h,09h,80h,80h
tran03 DB 80h,80h,80h,80h,80h,80h,00h,08h,80h,80h,80h,80h,80h,80h,01h,09h

; transition 1
tran10 DB 02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh,80h,80h,80h,80h,80h,80h
tran11 DB 80h,80h,02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh,80h,80h,80h,80h
tran12 DB 80h,80h,80h,80h,02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh,80h,80h
tran13 DB 80h,80h,80h,80h,80h,80h,02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh

; transition 2
tran20 DB 04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh,80h,80h,80h,80h,80h,80h
tran21 DB 80h,80h,04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh,80h,80h,80h,80h
tran22 DB 80h,80h,80h,80h,04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh,80h,80h
tran23 DB 80h,80h,80h,80h,80h,80h,04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh

; transition 3
tran30 DB 06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh,80h,80h,80h,80h,80h,80h
tran31 DB 80h,80h,06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh,80h,80h,80h,80h
tran32 DB 80h,80h,80h,80h,06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh,80h,80h
tran33 DB 80h,80h,80h,80h,80h,80h,06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh

.CODE

streebog_p_transform_avx2 PROC
    ; rcx = input
    ; rdx = output

    ; Load 128-bit chunks of the input block into XMM registers
    vmovdqu xmm0, XMMWORD PTR [rcx +  0]
    vmovdqu xmm1, XMMWORD PTR [rcx + 16]
    vmovdqu xmm2, XMMWORD PTR [rcx + 32]
    vmovdqu xmm3, XMMWORD PTR [rcx + 48]

    ; Apply transition 0
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran00]    ; shuffle bytes according to tran00 

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran01]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran02]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran03]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 0], xmm4

    ; Apply transition 1
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran10]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran11]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran12]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran13]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 16], xmm4

    ; Apply transition 2
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran20]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran21]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran22]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran23]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 32], xmm4

    ; Apply transition 3
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran30]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran31]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran32]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran33]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 48], xmm4

    vzeroupper  ; Clear upper parts of YMM registers to avoid AVX-SSE transition penalties
    ret
streebog_p_transform_avx2 ENDP

END