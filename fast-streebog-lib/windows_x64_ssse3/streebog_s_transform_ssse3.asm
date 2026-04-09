.DATA
ALIGN 16

; S-box tables
SBOX_ROW_0   DB 0FCh, 0EEh, 0DDh, 011h, 0CFh, 06Eh, 031h, 016h
             DB 0FBh, 0C4h, 0FAh, 0DAh, 023h, 0C5h, 004h, 04Dh

SBOX_ROW_1   DB 0E9h, 077h, 0F0h, 0DBh, 093h, 02Eh, 099h, 0BAh
             DB 017h, 036h, 0F1h, 0BBh, 014h, 0CDh, 05Fh, 0C1h

SBOX_ROW_2   DB 0F9h, 018h, 065h, 05Ah, 0E2h, 05Ch, 0EFh, 021h
             DB 081h, 01Ch, 03Ch, 042h, 08Bh, 001h, 08Eh, 04Fh

SBOX_ROW_3   DB 005h, 084h, 002h, 0AEh, 0E3h, 06Ah, 08Fh, 0A0h
             DB 006h, 00Bh, 0EDh, 098h, 07Fh, 0D4h, 0D3h, 01Fh

SBOX_ROW_4   DB 0EBh, 034h, 02Ch, 051h, 0EAh, 0C8h, 048h, 0ABh
             DB 0F2h, 02Ah, 068h, 0A2h, 0FDh, 03Ah, 0CEh, 0CCh

SBOX_ROW_5   DB 0B5h, 070h, 00Eh, 056h, 008h, 00Ch, 076h, 012h
             DB 0BFh, 072h, 013h, 047h, 09Ch, 0B7h, 05Dh, 087h

SBOX_ROW_6   DB 015h, 0A1h, 096h, 029h, 010h, 07Bh, 09Ah, 0C7h
             DB 0F3h, 091h, 078h, 06Fh, 09Dh, 09Eh, 0B2h, 0B1h

SBOX_ROW_7   DB 032h, 075h, 019h, 03Dh, 0FFh, 035h, 08Ah, 07Eh
             DB 06Dh, 054h, 0C6h, 080h, 0C3h, 0BDh, 00Dh, 057h

SBOX_ROW_8   DB 0DFh, 0F5h, 024h, 0A9h, 03Eh, 0A8h, 043h, 0C9h
             DB 0D7h, 079h, 0D6h, 0F6h, 07Ch, 022h, 0B9h, 003h

SBOX_ROW_9   DB 0E0h, 00Fh, 0ECh, 0DEh, 07Ah, 094h, 0B0h, 0BCh
             DB 0DCh, 0E8h, 028h, 050h, 04Eh, 033h, 00Ah, 04Ah

SBOX_ROW_A   DB 0A7h, 097h, 060h, 073h, 01Eh, 000h, 062h, 044h
             DB 01Ah, 0B8h, 038h, 082h, 064h, 09Fh, 026h, 041h

SBOX_ROW_B   DB 0ADh, 045h, 046h, 092h, 027h, 05Eh, 055h, 02Fh
             DB 08Ch, 0A3h, 0A5h, 07Dh, 069h, 0D5h, 095h, 03Bh

SBOX_ROW_C   DB 007h, 058h, 0B3h, 040h, 086h, 0ACh, 01Dh, 0F7h
             DB 030h, 037h, 06Bh, 0E4h, 088h, 0D9h, 0E7h, 089h

SBOX_ROW_D   DB 0E1h, 01Bh, 083h, 049h, 04Ch, 03Fh, 0F8h, 0FEh
             DB 08Dh, 053h, 0AAh, 090h, 0CAh, 0D8h, 085h, 061h

SBOX_ROW_E   DB 020h, 071h, 067h, 0A4h, 02Dh, 02Bh, 009h, 05Bh
             DB 0CBh, 09Bh, 025h, 0D0h, 0BEh, 0E5h, 06Ch, 052h

SBOX_ROW_F   DB 059h, 0A6h, 074h, 0D2h, 0E6h, 0F4h, 0B4h, 0C0h
             DB 0D1h, 066h, 0AFh, 0C2h, 039h, 04Bh, 063h, 0B6h

; Mask for low nibble (0x0F)
MASK_0F      DB 16 DUP(00Fh)

; Extraction tables for higher nibble comparison
EXT_00       DB 16 DUP(000h)
EXT_01       DB 16 DUP(001h)
EXT_02       DB 16 DUP(002h)
EXT_03       DB 16 DUP(003h)
EXT_04       DB 16 DUP(004h)
EXT_05       DB 16 DUP(005h)
EXT_06       DB 16 DUP(006h)
EXT_07       DB 16 DUP(007h)
EXT_08       DB 16 DUP(008h)
EXT_09       DB 16 DUP(009h)
EXT_0A       DB 16 DUP(00Ah)
EXT_0B       DB 16 DUP(00Bh)
EXT_0C       DB 16 DUP(00Ch)
EXT_0D       DB 16 DUP(00Dh)
EXT_0E       DB 16 DUP(00Eh)
EXT_0F       DB 16 DUP(00Fh)

.CODE

TWO_ROWS MACRO row_off, ext_off
    ; Block 0 (first 16 bytes)
    movdqa  xmm3,  XMMWORD PTR [r14 + row_off]      ; load S-box row
    pshufb  xmm3,  xmm1                             ; shuffle according to lo-nibble
    movdqa  xmm4,  XMMWORD PTR [r14 + ext_off]      ; load extraction mask
    pcmpeqb xmm4,  xmm2                             ; compare with hi-nibble
    pand    xmm3,  xmm4                             ; mask result to only matching bytes
    por     xmm5,  xmm3                             ; accumulate result

    ; Block 1 (next 16 bytes)
    movdqa  xmm12, XMMWORD PTR [r14 + row_off]
    pshufb  xmm12, xmm9
    movdqa  xmm13, XMMWORD PTR [r14 + ext_off]
    pcmpeqb xmm13, xmm11
    pand    xmm12, xmm13
    por     xmm10, xmm12
ENDM

streebog_s_transform_ssse3 PROC

    push    r14
    push    r15
    sub     rsp, 128                                ; reserve 8*16 bytes for temporary XMM storage

    ; save old XMM registers
    movdqu  [rsp + 0],   xmm6
    movdqu  [rsp + 16],  xmm7
    movdqu  [rsp + 32],  xmm8
    movdqu  [rsp + 48],  xmm9
    movdqu  [rsp + 64],  xmm10
    movdqu  [rsp + 80],  xmm11
    movdqu  [rsp + 96],  xmm12
    movdqu  [rsp + 112], xmm13

    ; pointer to S-box tables
    lea     r14, [SBOX_ROW_0]

    ; load first 32 bytes (block 0 + block 1)
    movdqu  xmm0, XMMWORD PTR [rcx]                 ; load first 16 bytes
    movdqu  xmm8, XMMWORD PTR [rcx + 16]            ; load next 16 bytes

    ; load low nibble mask once
    movdqa  xmm6, XMMWORD PTR [r14 + 256]

    ; extract low nibbles
    movdqa  xmm1, xmm0
    pand    xmm1, xmm6

    movdqa  xmm9, xmm8
    pand    xmm9, xmm6

    ; extract high nibbles
    movdqa  xmm2, xmm0
    psrlw   xmm2, 4
    pand    xmm2, xmm6

    movdqa  xmm11, xmm8
    psrlw   xmm11, 4
    pand    xmm11, xmm6

    ; clear accumulators
    pxor    xmm5,  xmm5
    pxor    xmm10, xmm10

    ; apply TWO_ROWS macro for all S-box rows
    TWO_ROWS   0,  272                      ; ROW_0, EXT_00
    TWO_ROWS  16,  288                      ; ROW_1, EXT_01
    TWO_ROWS  32,  304                      ; ROW_2, EXT_02
    TWO_ROWS  48,  320
    TWO_ROWS  64,  336
    TWO_ROWS  80,  352
    TWO_ROWS  96,  368
    TWO_ROWS 112,  384
    TWO_ROWS 128,  400
    TWO_ROWS 144,  416
    TWO_ROWS 160,  432
    TWO_ROWS 176,  448
    TWO_ROWS 192,  464
    TWO_ROWS 208,  480
    TWO_ROWS 224,  496
    TWO_ROWS 240,  512

    ; store first 32 bytes of result
    movdqu  XMMWORD PTR [rdx], xmm5
    movdqu  XMMWORD PTR [rdx + 16], xmm10

    ; load next 32 bytes (block 2 + block 3)
    movdqu  xmm0, XMMWORD PTR [rcx + 32]
    movdqu  xmm8, XMMWORD PTR [rcx + 48]

    ; repeat low/high nibble extraction 
    movdqa  xmm1, xmm0
    pand    xmm1, xmm6
    movdqa  xmm9, xmm8
    pand    xmm9, xmm6

    movdqa  xmm2, xmm0
    psrlw   xmm2, 4
    pand    xmm2, xmm6
    movdqa  xmm11, xmm8
    psrlw   xmm11, 4
    pand    xmm11, xmm6

    pxor    xmm5,  xmm5
    pxor    xmm10, xmm10

    ; apply macro again
    TWO_ROWS   0,  272
    TWO_ROWS  16,  288
    TWO_ROWS  32,  304
    TWO_ROWS  48,  320
    TWO_ROWS  64,  336
    TWO_ROWS  80,  352
    TWO_ROWS  96,  368
    TWO_ROWS 112,  384
    TWO_ROWS 128,  400
    TWO_ROWS 144,  416
    TWO_ROWS 160,  432
    TWO_ROWS 176,  448
    TWO_ROWS 192,  464
    TWO_ROWS 208,  480
    TWO_ROWS 224,  496
    TWO_ROWS 240,  512

    ; store second 32 bytes of result
    movdqu  XMMWORD PTR [rdx + 32], xmm5
    movdqu  XMMWORD PTR [rdx + 48], xmm10

    ; restore saved XMM registers
    movdqu  xmm6,  [rsp + 0]
    movdqu  xmm7,  [rsp + 16]
    movdqu  xmm8,  [rsp + 32]
    movdqu  xmm9,  [rsp + 48]
    movdqu  xmm10, [rsp + 64]
    movdqu  xmm11, [rsp + 80]
    movdqu  xmm12, [rsp + 96]
    movdqu  xmm13, [rsp + 112]

    add     rsp, 128
    pop     r15
    pop     r14

    ret

streebog_s_transform_ssse3 ENDP

END