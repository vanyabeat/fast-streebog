.DATA
ALIGN 16

; Group 0 elements
tran00 DB 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h, 080h, 080h, 080h, 080h, 080h, 080h
tran01 DB 080h, 080h, 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h, 080h, 080h, 080h, 080h
tran02 DB 080h, 080h, 080h, 080h, 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h, 080h, 080h
tran03 DB 080h, 080h, 080h, 080h, 080h, 080h, 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h

; Group 1 elements
tran10 DB 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh, 080h, 080h, 080h, 080h, 080h, 080h
tran11 DB 080h, 080h, 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh, 080h, 080h, 080h, 080h
tran12 DB 080h, 080h, 080h, 080h, 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh, 080h, 080h
tran13 DB 080h, 080h, 080h, 080h, 080h, 080h, 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh

; Group 2 elements
tran20 DB 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh, 080h, 080h, 080h, 080h, 080h, 080h
tran21 DB 080h, 080h, 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh, 080h, 080h, 080h, 080h
tran22 DB 080h, 080h, 080h, 080h, 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh, 080h, 080h
tran23 DB 080h, 080h, 080h, 080h, 080h, 080h, 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh

; Group 3 elements
tran30 DB 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh, 080h, 080h, 080h, 080h, 080h, 080h
tran31 DB 080h, 080h, 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh, 080h, 080h, 080h, 080h
tran32 DB 080h, 080h, 080h, 080h, 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh, 080h, 080h
tran33 DB 080h, 080h, 080h, 080h, 080h, 080h, 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh

.CODE
streebog_p_transform_ssse3 PROC

    ; rcx = input pointer, rdx = output pointer

    ; load 4 16-byte chunks from input
    movdqu xmm0, XMMWORD PTR [rcx +  0]
    movdqu xmm1, XMMWORD PTR [rcx + 16]
    movdqu xmm2, XMMWORD PTR [rcx + 32]
    movdqu xmm3, XMMWORD PTR [rcx + 48]

    ; process bytes 0-15 (group 0)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran00]       ; select bytes from chunk 0
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran01]       ; select bytes from chunk 1
    por xmm4, xmm5                          ; combine
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran02]       ; select bytes from chunk 2
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran03]       ; select bytes from chunk 3 
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx +  0], xmm4     ; store result

    ; bytes 16-31 (group 1)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran10]
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran11]
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran12]
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran13]
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx + 16], xmm4

    ; bytes 32-47 (group 2)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran20]
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran21]
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran22]
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran23]
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx + 32], xmm4

    ; bytes 48-63 (group 3)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran30]
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran31]
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran32]
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran33]
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx + 48], xmm4

    ret
streebog_p_transform_ssse3 ENDP
END