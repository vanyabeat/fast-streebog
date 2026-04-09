.DATA
ALIGN 16

; Duplicated for vpshufb
SBOX:
    db 0FCh,0EEh,0DDh,011h,0CFh,06Eh,031h,016h,0FBh,0C4h,0FAh,0DAh,023h,0C5h,004h,04Dh
    db 0FCh,0EEh,0DDh,011h,0CFh,06Eh,031h,016h,0FBh,0C4h,0FAh,0DAh,023h,0C5h,004h,04Dh

    db 0E9h,077h,0F0h,0DBh,093h,02Eh,099h,0BAh,017h,036h,0F1h,0BBh,014h,0CDh,05Fh,0C1h
    db 0E9h,077h,0F0h,0DBh,093h,02Eh,099h,0BAh,017h,036h,0F1h,0BBh,014h,0CDh,05Fh,0C1h

    db 0F9h,018h,065h,05Ah,0E2h,05Ch,0EFh,021h,081h,01Ch,03Ch,042h,08Bh,001h,08Eh,04Fh
    db 0F9h,018h,065h,05Ah,0E2h,05Ch,0EFh,021h,081h,01Ch,03Ch,042h,08Bh,001h,08Eh,04Fh

    db 005h,084h,002h,0AEh,0E3h,06Ah,08Fh,0A0h,006h,00Bh,0EDh,098h,07Fh,0D4h,0D3h,01Fh
    db 005h,084h,002h,0AEh,0E3h,06Ah,08Fh,0A0h,006h,00Bh,0EDh,098h,07Fh,0D4h,0D3h,01Fh

    db 0EBh,034h,02Ch,051h,0EAh,0C8h,048h,0ABh,0F2h,02Ah,068h,0A2h,0FDh,03Ah,0CEh,0CCh
    db 0EBh,034h,02Ch,051h,0EAh,0C8h,048h,0ABh,0F2h,02Ah,068h,0A2h,0FDh,03Ah,0CEh,0CCh

    db 0B5h,070h,00Eh,056h,008h,00Ch,076h,012h,0BFh,072h,013h,047h,09Ch,0B7h,05Dh,087h
    db 0B5h,070h,00Eh,056h,008h,00Ch,076h,012h,0BFh,072h,013h,047h,09Ch,0B7h,05Dh,087h

    db 015h,0A1h,096h,029h,010h,07Bh,09Ah,0C7h,0F3h,091h,078h,06Fh,09Dh,09Eh,0B2h,0B1h
    db 015h,0A1h,096h,029h,010h,07Bh,09Ah,0C7h,0F3h,091h,078h,06Fh,09Dh,09Eh,0B2h,0B1h

    db 032h,075h,019h,03Dh,0FFh,035h,08Ah,07Eh,06Dh,054h,0C6h,080h,0C3h,0BDh,00Dh,057h
    db 032h,075h,019h,03Dh,0FFh,035h,08Ah,07Eh,06Dh,054h,0C6h,080h,0C3h,0BDh,00Dh,057h

    db 0DFh,0F5h,024h,0A9h,03Eh,0A8h,043h,0C9h,0D7h,079h,0D6h,0F6h,07Ch,022h,0B9h,003h
    db 0DFh,0F5h,024h,0A9h,03Eh,0A8h,043h,0C9h,0D7h,079h,0D6h,0F6h,07Ch,022h,0B9h,003h

    db 0E0h,00Fh,0ECh,0DEh,07Ah,094h,0B0h,0BCh,0DCh,0E8h,028h,050h,04Eh,033h,00Ah,04Ah
    db 0E0h,00Fh,0ECh,0DEh,07Ah,094h,0B0h,0BCh,0DCh,0E8h,028h,050h,04Eh,033h,00Ah,04Ah

    db 0A7h,097h,060h,073h,01Eh,000h,062h,044h,01Ah,0B8h,038h,082h,064h,09Fh,026h,041h
    db 0A7h,097h,060h,073h,01Eh,000h,062h,044h,01Ah,0B8h,038h,082h,064h,09Fh,026h,041h

    db 0ADh,045h,046h,092h,027h,05Eh,055h,02Fh,08Ch,0A3h,0A5h,07Dh,069h,0D5h,095h,03Bh
    db 0ADh,045h,046h,092h,027h,05Eh,055h,02Fh,08Ch,0A3h,0A5h,07Dh,069h,0D5h,095h,03Bh

    db 007h,058h,0B3h,040h,086h,0ACh,01Dh,0F7h,030h,037h,06Bh,0E4h,088h,0D9h,0E7h,089h
    db 007h,058h,0B3h,040h,086h,0ACh,01Dh,0F7h,030h,037h,06Bh,0E4h,088h,0D9h,0E7h,089h

    db 0E1h,01Bh,083h,049h,04Ch,03Fh,0F8h,0FEh,08Dh,053h,0AAh,090h,0CAh,0D8h,085h,061h
    db 0E1h,01Bh,083h,049h,04Ch,03Fh,0F8h,0FEh,08Dh,053h,0AAh,090h,0CAh,0D8h,085h,061h

    db 020h,071h,067h,0A4h,02Dh,02Bh,009h,05Bh,0CBh,09Bh,025h,0D0h,0BEh,0E5h,06Ch,052h
    db 020h,071h,067h,0A4h,02Dh,02Bh,009h,05Bh,0CBh,09Bh,025h,0D0h,0BEh,0E5h,06Ch,052h

    db 059h,0A6h,074h,0D2h,0E6h,0F4h,0B4h,0C0h,0D1h,066h,0AFh,0C2h,039h,04Bh,063h,0B6h
    db 059h,0A6h,074h,0D2h,0E6h,0F4h,0B4h,0C0h,0D1h,066h,0AFh,0C2h,039h,04Bh,063h,0B6h

; Mask for lower nibble extraction
MASK_0F db 32 dup(0Fh)

; Extraction constants for upper nibbles
EXT:
    db 32 dup(0),  32 dup(1),  32 dup(2),  32 dup(3)
    db 32 dup(4),  32 dup(5),  32 dup(6),  32 dup(7)
    db 32 dup(8),  32 dup(9),  32 dup(10), 32 dup(11)
    db 32 dup(12), 32 dup(13), 32 dup(14), 32 dup(15)

.CODE

; Registers:
; SBOX_ROW_N = r14 + N*32
; MASK       = r14 + 512
; EXT_N      = r14 + 544 + N*32

; Algorithm: for each byte X we compute SBOX[X] using the low and high nibbles:
; lo = X & 0x0F — index inside the S-box row (used with vpshufb)
; hi = (X >> 4) & 0x0F — row number in the S-box (used with vpcmpeqb)
; the final result is constructed as [hi][lo]

streebog_s_transform_avx2 PROC
    ; rcx = input pointer
    ; rdx = output pointer

    push    r14
    push    r15
    sub     rsp,  8*32 + 40     ; Stack space for YMM register backup

    ; Save YMM registers to stack
    vmovdqu YMMWORD PTR [rsp+40+0*32], ymm6
    vmovdqu YMMWORD PTR [rsp+40+1*32], ymm7
    vmovdqu YMMWORD PTR [rsp+40+2*32], ymm8
    vmovdqu YMMWORD PTR [rsp+40+3*32], ymm10
    vmovdqu YMMWORD PTR [rsp+40+4*32], ymm11
    vmovdqu YMMWORD PTR [rsp+40+5*32], ymm12
    vmovdqu YMMWORD PTR [rsp+40+6*32], ymm13
    vmovdqu YMMWORD PTR [rsp+40+7*32], ymm14

    ; Load SBOX and extraction tables
    lea     r14, [SBOX]
    lea     r15, [EXT]

    ; Input
    mov     r8,  rcx
    mov     r9,  rdx

    ; Load input into ymm0, ymm1
    vmovdqu ymm0, YMMWORD PTR [r8]
    vmovdqu ymm1, YMMWORD PTR [r8+32]

    vmovdqu ymm7, YMMWORD PTR [r14 + 512]  ; Load lower nibble mask 

    ; Extract lower nibbles for first and second 32 bytes
    vpand   ymm2, ymm0, ymm7
    vpand   ymm3, ymm1, ymm7

    ; Extract upper nibbles
    vpsrlw  ymm4, ymm0, 4
    vpsrlw  ymm5, ymm1, 4
    vpand   ymm4, ymm4, ymm7
    vpand   ymm5, ymm5, ymm7

    ; Initialize accumulators to zero
    vpxor   ymm6,  ymm6,  ymm6
    vpxor   ymm8,  ymm8,  ymm8

    ; 16 iterations for 16 SBOX rows
    mov     ecx, 16

@@loop:

    ; Load current SBOX row
    vmovdqu ymm10, YMMWORD PTR [r14]

    ; Select bytes according to lower nibble
    vpshufb ymm11, ymm10, ymm2
    vpshufb ymm12, ymm10, ymm3

    ; Load extraction constants
    vmovdqu ymm13, YMMWORD PTR [r15]

    ; Mask using upper nibble comparison
    vpcmpeqb ymm14, ymm13, ymm4
    vpand    ymm11, ymm11, ymm14
    vpor     ymm6,  ymm6,  ymm11

    vpcmpeqb ymm14, ymm13, ymm5
    vpand    ymm12, ymm12, ymm14
    vpor     ymm8,  ymm8,  ymm12

    add     r14, 32 ; Next SBOX row
    add     r15, 32 ; Next extraction row
    dec     ecx
    jnz     @@loop

    ; Store transformed result
    vmovdqu YMMWORD PTR [r9],    ymm6
    vmovdqu YMMWORD PTR [r9+32], ymm8

    ; Restore YMM registers
    vmovdqu ymm6,  YMMWORD PTR [rsp+40+0*32]
    vmovdqu ymm7,  YMMWORD PTR [rsp+40+1*32]
    vmovdqu ymm8,  YMMWORD PTR [rsp+40+2*32]
    vmovdqu ymm10, YMMWORD PTR [rsp+40+3*32]
    vmovdqu ymm11, YMMWORD PTR [rsp+40+4*32]
    vmovdqu ymm12, YMMWORD PTR [rsp+40+5*32]
    vmovdqu ymm13, YMMWORD PTR [rsp+40+6*32]
    vmovdqu ymm14, YMMWORD PTR [rsp+40+7*32]

    add     rsp, 8*32 + 40
    pop     r15
    pop     r14
    vzeroupper
    ret

streebog_s_transform_avx2 ENDP
END