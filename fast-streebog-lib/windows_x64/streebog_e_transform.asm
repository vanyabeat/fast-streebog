.data
ALIGN 16

; Round constants C[0]..C[11] for KeySchedule
C_0:
    DB 0b1h, 008h, 05bh, 0dah, 01eh, 0cah, 0dah, 0e9h, 0ebh, 0cbh, 02fh
    DB 081h, 0c0h, 065h, 07ch, 01fh, 02fh, 06ah, 076h, 043h, 02eh, 045h
    DB 0d0h, 016h, 071h, 04eh, 0b8h, 08dh, 075h, 085h, 0c4h, 0fch, 04bh
    DB 07ch, 0e0h, 091h, 092h, 067h, 069h, 001h, 0a2h, 042h, 02ah, 008h
    DB 0a4h, 060h, 0d3h, 015h, 005h, 076h, 074h, 036h, 0cch, 074h, 04dh
    DB 023h, 0ddh, 080h, 065h, 059h, 0f2h, 0a6h, 045h, 007h

C_1:
    DB 06fh, 0a3h, 0b5h, 08ah, 0a9h, 09dh, 02fh, 01ah, 04fh, 0e3h, 09dh
    DB 046h, 00fh, 070h, 0b5h, 0d7h, 0f3h, 0feh, 0eah, 072h, 00ah, 023h
    DB 02bh, 098h, 061h, 0d5h, 05eh, 00fh, 016h, 0b5h, 001h, 031h, 09ah
    DB 0b5h, 017h, 06bh, 012h, 0d6h, 099h, 058h, 05ch, 0b5h, 061h, 0c2h
    DB 0dbh, 00ah, 0a7h, 0cah, 055h, 0ddh, 0a2h, 01bh, 0d7h, 0cbh, 0cdh
    DB 056h, 0e6h, 079h, 004h, 070h, 021h, 0b1h, 09bh, 0b7h

C_2:
    DB 0f5h, 074h, 0dch, 0ach, 02bh, 0ceh, 02fh, 0c7h, 00ah, 039h, 0fch
    DB 028h, 06ah, 03dh, 084h, 035h, 006h, 0f1h, 05eh, 05fh, 052h, 09ch
    DB 01fh, 08bh, 0f2h, 0eah, 075h, 014h, 0b1h, 029h, 07bh, 07bh, 0d3h
    DB 0e2h, 00fh, 0e4h, 090h, 035h, 09eh, 0b1h, 0c1h, 0c9h, 03ah, 037h
    DB 060h, 062h, 0dbh, 009h, 0c2h, 0b6h, 0f4h, 043h, 086h, 07ah, 0dbh
    DB 031h, 099h, 01eh, 096h, 0f5h, 00ah, 0bah, 00ah, 0b2h

C_3:
    DB 0efh, 01fh, 0dfh, 0b3h, 0e8h, 015h, 066h, 0d2h, 0f9h, 048h, 0e1h
    DB 0a0h, 05dh, 071h, 0e4h, 0ddh, 048h, 08eh, 085h, 07eh, 033h, 05ch
    DB 03ch, 07dh, 09dh, 072h, 01ch, 0adh, 068h, 05eh, 035h, 03fh, 0a9h
    DB 0d7h, 02ch, 082h, 0edh, 003h, 0d6h, 075h, 0d8h, 0b7h, 013h, 033h
    DB 093h, 052h, 003h, 0beh, 034h, 053h, 0eah, 0a1h, 093h, 0e8h, 037h
    DB 0f1h, 022h, 00ch, 0beh, 0bch, 084h, 0e3h, 0d1h, 02eh

C_4:
    DB 04bh, 0eah, 06bh, 0ach, 0adh, 047h, 047h, 099h, 09ah, 03fh, 041h
    DB 00ch, 06ch, 0a9h, 023h, 063h, 07fh, 015h, 01ch, 01fh, 016h, 086h
    DB 010h, 04ah, 035h, 09eh, 035h, 0d7h, 080h, 00fh, 0ffh, 0bdh, 0bfh
    DB 0cdh, 017h, 047h, 025h, 03ah, 0f5h, 0a3h, 0dfh, 0ffh, 000h, 0b7h
    DB 023h, 027h, 01ah, 016h, 07ah, 056h, 0a2h, 07eh, 0a9h, 0eah, 063h
    DB 0f5h, 060h, 017h, 058h, 0fdh, 07ch, 06ch, 0feh, 057h

C_5:
    DB 0aeh, 04fh, 0aeh, 0aeh, 01dh, 03ah, 0d3h, 0d9h, 06fh, 0a4h, 0c3h
    DB 03bh, 07ah, 030h, 039h, 0c0h, 02dh, 066h, 0c4h, 0f9h, 051h, 042h
    DB 0a4h, 06ch, 018h, 07fh, 09ah, 0b4h, 09ah, 0f0h, 08eh, 0c6h, 0cfh
    DB 0fah, 0a6h, 0b7h, 01ch, 09ah, 0b7h, 0b4h, 00ah, 0f2h, 01fh, 066h
    DB 0c2h, 0beh, 0c6h, 0b6h, 0bfh, 071h, 0c5h, 072h, 036h, 090h, 04fh
    DB 035h, 0fah, 068h, 040h, 07ah, 046h, 064h, 07dh, 06eh

C_6:
    DB 0f4h, 0c7h, 00eh, 016h, 0eeh, 0aah, 0c5h, 0ech, 051h, 0ach, 086h
    DB 0feh, 0bfh, 024h, 009h, 054h, 039h, 09eh, 0c6h, 0c7h, 0e6h, 0bfh
    DB 087h, 0c9h, 0d3h, 047h, 03eh, 033h, 019h, 07ah, 093h, 0c9h, 009h
    DB 092h, 0abh, 0c5h, 02dh, 082h, 02ch, 037h, 006h, 047h, 069h, 083h
    DB 028h, 04ah, 005h, 004h, 035h, 017h, 045h, 04ch, 0a2h, 03ch, 04ah
    DB 0f3h, 088h, 086h, 056h, 04dh, 03ah, 014h, 0d4h, 093h

C_7:
    DB 09bh, 01fh, 05bh, 042h, 04dh, 093h, 0c9h, 0a7h, 003h, 0e7h, 0aah
    DB 002h, 00ch, 06eh, 041h, 041h, 04eh, 0b7h, 0f8h, 071h, 09ch, 036h
    DB 0deh, 01eh, 089h, 0b4h, 044h, 03bh, 04dh, 0dbh, 0c4h, 09ah, 0f4h
    DB 089h, 02bh, 0cbh, 092h, 09bh, 006h, 090h, 069h, 0d1h, 08dh, 02bh
    DB 0d1h, 0a5h, 0c4h, 02fh, 036h, 0ach, 0c2h, 035h, 059h, 051h, 0a8h
    DB 0d9h, 0a4h, 07fh, 00dh, 0d4h, 0bfh, 002h, 0e7h, 01eh

C_8:
    DB 037h, 08fh, 05ah, 054h, 016h, 031h, 022h, 09bh, 094h, 04ch, 09ah
    DB 0d8h, 0ech, 016h, 05fh, 0deh, 03ah, 07dh, 03ah, 01bh, 025h, 089h
    DB 042h, 024h, 03ch, 0d9h, 055h, 0b7h, 0e0h, 00dh, 009h, 084h, 080h
    DB 00ah, 044h, 00bh, 0dbh, 0b2h, 0ceh, 0b1h, 07bh, 02bh, 08ah, 09ah
    DB 0a6h, 007h, 09ch, 054h, 00eh, 038h, 0dch, 092h, 0cbh, 01fh, 02ah
    DB 060h, 072h, 061h, 044h, 051h, 083h, 023h, 05ah, 0dbh

C_9:
    DB 0abh, 0beh, 0deh, 0a6h, 080h, 005h, 06fh, 052h, 038h, 02ah, 0e5h
    DB 048h, 0b2h, 0e4h, 0f3h, 0f3h, 089h, 041h, 0e7h, 01ch, 0ffh, 08ah
    DB 078h, 0dbh, 01fh, 0ffh, 0e1h, 08ah, 01bh, 033h, 061h, 003h, 09fh
    DB 0e7h, 067h, 002h, 0afh, 069h, 033h, 04bh, 07ah, 01eh, 06ch, 030h
    DB 03bh, 076h, 052h, 0f4h, 036h, 098h, 0fah, 0d1h, 015h, 03bh, 0b6h
    DB 0c3h, 074h, 0b4h, 0c7h, 0fbh, 098h, 045h, 09ch, 0edh

C_10:
    DB 07bh, 0cdh, 09eh, 0d0h, 0efh, 0c8h, 089h, 0fbh, 030h, 002h, 0c6h
    DB 0cdh, 063h, 05ah, 0feh, 094h, 0d8h, 0fah, 06bh, 0bbh, 0ebh, 0abh
    DB 007h, 061h, 020h, 001h, 080h, 021h, 014h, 084h, 066h, 079h, 08ah
    DB 01dh, 071h, 0efh, 0eah, 048h, 0b9h, 0cah, 0efh, 0bah, 0cdh, 01dh
    DB 07dh, 047h, 06eh, 098h, 0deh, 0a2h, 059h, 04ah, 0c0h, 06fh, 0d8h
    DB 05dh, 06bh, 0cah, 0a4h, 0cdh, 081h, 0f3h, 02dh, 01bh

C_11:
    DB 037h, 08eh, 0e7h, 067h, 0f1h, 016h, 031h, 0bah, 0d2h, 013h, 080h
    DB 0b0h, 004h, 049h, 0b1h, 07ah, 0cdh, 0a4h, 03ch, 032h, 0bch, 0dfh
    DB 01dh, 077h, 0f8h, 020h, 012h, 0d4h, 030h, 021h, 09fh, 09bh, 05dh
    DB 080h, 0efh, 09dh, 018h, 091h, 0cch, 086h, 0e7h, 01dh, 0a4h, 0aah
    DB 088h, 0e1h, 028h, 052h, 0fah, 0f4h, 017h, 0d5h, 0d9h, 0b2h, 01bh
    DB 099h, 048h, 0bch, 092h, 04ah, 0f1h, 01bh, 0d7h, 020h

; Table of pointers to round constants
C_TABLE:
    QWORD C_0
    QWORD C_1
    QWORD C_2
    QWORD C_3
    QWORD C_4
    QWORD C_5
    QWORD C_6
    QWORD C_7
    QWORD C_8
    QWORD C_9
    QWORD C_10
    QWORD C_11

; S-box tables for inline S-transform
ALIGN 16
SBOX_0_63   DB 0FCh, 0EEh, 0DDh, 011h, 0CFh, 06Eh, 031h, 016h, 0FBh, 0C4h, 0FAh, 0DAh, 023h, 0C5h, 004h, 04Dh
            DB 0E9h, 077h, 0F0h, 0DBh, 093h, 02Eh, 099h, 0BAh, 017h, 036h, 0F1h, 0BBh, 014h, 0CDh, 05Fh, 0C1h
            DB 0F9h, 018h, 065h, 05Ah, 0E2h, 05Ch, 0EFh, 021h, 081h, 01Ch, 03Ch, 042h, 08Bh, 001h, 08Eh, 04Fh
            DB 005h, 084h, 002h, 0AEh, 0E3h, 06Ah, 08Fh, 0A0h, 006h, 00Bh, 0EDh, 098h, 07Fh, 0D4h, 0D3h, 01Fh

SBOX_64_127 DB 0EBh, 034h, 02Ch, 051h, 0EAh, 0C8h, 048h, 0ABh, 0F2h, 02Ah, 068h, 0A2h, 0FDh, 03Ah, 0CEh, 0CCh
            DB 0B5h, 070h, 00Eh, 056h, 008h, 00Ch, 076h, 012h, 0BFh, 072h, 013h, 047h, 09Ch, 0B7h, 05Dh, 087h
            DB 015h, 0A1h, 096h, 029h, 010h, 07Bh, 09Ah, 0C7h, 0F3h, 091h, 078h, 06Fh, 09Dh, 09Eh, 0B2h, 0B1h
            DB 032h, 075h, 019h, 03Dh, 0FFh, 035h, 08Ah, 07Eh, 06Dh, 054h, 0C6h, 080h, 0C3h, 0BDh, 00Dh, 057h

SBOX_128_191 DB 0DFh, 0F5h, 024h, 0A9h, 03Eh, 0A8h, 043h, 0C9h, 0D7h, 079h, 0D6h, 0F6h, 07Ch, 022h, 0B9h, 003h
             DB 0E0h, 00Fh, 0ECh, 0DEh, 07Ah, 094h, 0B0h, 0BCh, 0DCh, 0E8h, 028h, 050h, 04Eh, 033h, 00Ah, 04Ah
             DB 0A7h, 097h, 060h, 073h, 01Eh, 000h, 062h, 044h, 01Ah, 0B8h, 038h, 082h, 064h, 09Fh, 026h, 041h
             DB 0ADh, 045h, 046h, 092h, 027h, 05Eh, 055h, 02Fh, 08Ch, 0A3h, 0A5h, 07Dh, 069h, 0D5h, 095h, 03Bh

SBOX_192_255 DB 007h, 058h, 0B3h, 040h, 086h, 0ACh, 01Dh, 0F7h, 030h, 037h, 06Bh, 0E4h, 088h, 0D9h, 0E7h, 089h
             DB 0E1h, 01Bh, 083h, 049h, 04Ch, 03Fh, 0F8h, 0FEh, 08Dh, 053h, 0AAh, 090h, 0CAh, 0D8h, 085h, 061h
             DB 020h, 071h, 067h, 0A4h, 02Dh, 02Bh, 009h, 05Bh, 0CBh, 09Bh, 025h, 0D0h, 0BEh, 0E5h, 06Ch, 052h
             DB 059h, 0A6h, 074h, 0D2h, 0E6h, 0F4h, 0B4h, 0C0h, 0D1h, 066h, 0AFh, 0C2h, 039h, 04Bh, 063h, 0B6h

CONST_3F    DB 64 DUP(03Fh)

; P-transform permutation table (TAU)
TAU     DB  0,  8, 16, 24, 32, 40, 48, 56
        DB  1,  9, 17, 25, 33, 41, 49, 57
        DB  2, 10, 18, 26, 34, 42, 50, 58
        DB  3, 11, 19, 27, 35, 43, 51, 59
        DB  4, 12, 20, 28, 36, 44, 52, 60
        DB  5, 13, 21, 29, 37, 45, 53, 61
        DB  6, 14, 22, 30, 38, 46, 54, 62
        DB  7, 15, 23, 31, 39, 47, 55, 63

; L-transform matrix
A_MATRIX:
    QWORD 08e20faa72ba0b470h  
    QWORD 047107ddd9b505a38h  
    QWORD 0ad08b0e0c3282d1ch  
    QWORD 0d8045870ef14980eh  
    QWORD 06c022c38f90a4c07h  
    QWORD 03601161cf205268dh  
    QWORD 01b8e0b0e798c13c8h  
    QWORD 083478b07b2468764h  
    QWORD 0a011d380818e8f40h  
    QWORD 05086e740ce47c920h  
    QWORD 02843fd2067adea10h  
    QWORD 014aff010bdd87508h  
    QWORD 00ad97808d06cb404h  
    QWORD 005e23c0468365a02h  
    QWORD 08c711e02341b2d01h  
    QWORD 046b60f011a83988eh  
    QWORD 090dab52a387ae76fh  
    QWORD 0486dd4151c3dfdb9h  
    QWORD 024b86a840e90f0d2h  
    QWORD 0125c354207487869h  
    QWORD 0092e94218d243cbah  
    QWORD 08a174a9ec8121e5dh  
    QWORD 04585254f64090fa0h  
    QWORD 0accc9ca9328a8950h  
    QWORD 09d4df05d5f661451h  
    QWORD 0c0a878a0a1330aa6h  
    QWORD 060543c50de970553h  
    QWORD 0302a1e286fc58ca7h  
    QWORD 018150f14b9ec46ddh  
    QWORD 00c84890ad27623e0h  
    QWORD 00642ca05693b9f70h  
    QWORD 00321658cba93c138h  
    QWORD 086275df09ce8aaa8h  
    QWORD 0439da0784e745554h  
    QWORD 0afc0503c273aa42ah  
    QWORD 0d960281e9d1d5215h  
    QWORD 0e230140fc0802984h  
    QWORD 071180a8960409a42h  
    QWORD 0b60c05ca30204d21h  
    QWORD 05b068c651810a89eh  
    QWORD 0456c34887a3805b9h  
    QWORD 0ac361a443d1c8cd2h  
    QWORD 0561b0d22900e4669h  
    QWORD 02b838811480723bah  
    QWORD 09bcf4486248d9f5dh  
    QWORD 0c3e9224312c8c1a0h  
    QWORD 0effa11af0964ee50h  
    QWORD 0f97d86d98a327728h  
    QWORD 0e4fa2054a80b329ch  
    QWORD 0727d102a548b194eh  
    QWORD 039b008152acb8227h  
    QWORD 09258048415eb419dh  
    QWORD 0492c024284fbaec0h  
    QWORD 0aa16012142f35760h  
    QWORD 0550b8e9e21f7a530h  
    QWORD 0a48b474f9ef5dc18h  
    QWORD 070a6a56e2440598eh  
    QWORD 03853dc371220a247h  
    QWORD 01ca76e95091051adh  
    QWORD 00edd37c48a08a6d8h  
    QWORD 007e095624504536ch  
    QWORD 08d70c431ac02a736h  
    QWORD 0c83862965601dd1bh  
    QWORD 0641c314b2b8ee083h

.code

; ============================================================================
; E-transform: E(K, m) -> out
; Performs 12 rounds of S->P->L->KeySchedule->XOR
; 
; Input:
;   rcx = pointer to K (64 bytes key)
;   rdx = pointer to m (64 bytes message)
;   r8  = pointer to out (64 bytes output)
;
; This optimized version keeps state and key in ZMM registers,
; eliminating intermediate memcpy operations.
; ============================================================================
streebog_e_transform PROC
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    push rbp
    sub rsp, 128                ; Stack space for L-transform temp + alignment
    
    mov rsi, rcx                ; rsi = K pointer
    mov rdi, rdx                ; rdi = m pointer  
    mov r15, r8                  ; r15 = out pointer
    
    ; Load K and m into ZMM registers
    vmovdqu64 zmm30, ZMMWORD PTR [rsi]   ; zmm30 = K (key)
    vmovdqu64 zmm31, ZMMWORD PTR [rdi]   ; zmm31 = m (message)
    
    ; state = K ^ m
    vpxorq zmm0, zmm30, zmm31            ; zmm0 = state
    
    ; zmm30 now holds the working key
    
    ; Load constants for S-transform into zmm registers
    vmovdqu64 zmm20, ZMMWORD PTR [SBOX_0_63]
    vmovdqu64 zmm21, ZMMWORD PTR [SBOX_64_127]
    vmovdqu64 zmm22, ZMMWORD PTR [SBOX_128_191]
    vmovdqu64 zmm23, ZMMWORD PTR [SBOX_192_255]
    vmovdqu64 zmm24, ZMMWORD PTR [CONST_3F]
    vmovdqu64 zmm25, ZMMWORD PTR [TAU]   ; P-transform permutation
    
    ; Prepare constants for S-transform masking
    mov rax, 4040404040404040h
    vpbroadcastq zmm26, rax              ; zmm26 = 0x40 broadcast
    mov rax, 8080808080808080h
    vpbroadcastq zmm27, rax              ; zmm27 = 0x80 broadcast
    mov rax, 0C0C0C0C0C0C0C0C0h
    vpbroadcastq zmm28, rax              ; zmm28 = 0xC0 broadcast
    
    xor r12d, r12d                       ; r12 = round counter (0..11)
    lea rbx, QWORD PTR [C_TABLE]         ; rbx = pointer to C constants table
    
round_loop:
    ; ========== S-transform on state (zmm0) ==========
    ; Apply S-box substitution
    vpandq zmm5, zmm0, zmm24             ; zmm5 = low 6 bits (index into sbox)
    
    ; Lookup in all 4 S-box ranges
    vpermb zmm6, zmm5, zmm20             ; lookup SBOX_0_63
    vpermb zmm7, zmm5, zmm21             ; lookup SBOX_64_127
    vpermb zmm8, zmm5, zmm22             ; lookup SBOX_128_191
    vpermb zmm9, zmm5, zmm23             ; lookup SBOX_192_255
    
    ; Create masks based on high bits of input bytes
    vpcmpub k1, zmm0, zmm26, 1           ; k1 = bytes < 0x40
    vpcmpub k2, zmm0, zmm26, 5           ; k2 = bytes >= 0x40
    vpcmpub k5, zmm0, zmm27, 1           ; k5 = bytes < 0x80
    kandq k2, k2, k5                      ; k2 = 0x40 <= bytes < 0x80
    
    vpcmpub k3, zmm0, zmm27, 5           ; k3 = bytes >= 0x80
    vpcmpub k5, zmm0, zmm28, 1           ; k5 = bytes < 0xC0
    kandq k3, k3, k5                      ; k3 = 0x80 <= bytes < 0xC0
    
    vpcmpub k4, zmm0, zmm28, 5           ; k4 = bytes >= 0xC0
    
    ; Merge results
    vpxorq zmm0, zmm0, zmm0              ; clear
    vmovdqu8 zmm0 {k1}, zmm6             ; bytes < 0x40 -> from SBOX_0_63
    vmovdqu8 zmm0 {k2}, zmm7             ; bytes in [0x40, 0x80) -> from SBOX_64_127
    vmovdqu8 zmm0 {k3}, zmm8             ; bytes in [0x80, 0xC0) -> from SBOX_128_191
    vmovdqu8 zmm0 {k4}, zmm9             ; bytes >= 0xC0 -> from SBOX_192_255
    
    ; ========== P-transform on state (zmm0) ==========
    vpermb zmm0, zmm25, zmm0             ; Apply TAU permutation
    
    ; ========== L-transform on state (zmm0) ==========
    ; Store state to stack, perform L-transform, load back
    vmovdqu64 ZMMWORD PTR [rsp], zmm0
    
    ; L-transform loop over 8 qwords
    xor r13d, r13d                       ; r13 = output qword index
    
l_output_loop:
    mov rax, QWORD PTR [rsp + r13*8]
    bswap rax
    mov r14, rax                         ; r14 = input qword (byte-swapped)
    
    xor rbp, rbp                         ; rbp = accumulator
    xor ecx, ecx                         ; ecx = bit index
    
    lea r9, QWORD PTR [A_MATRIX]
    
l_bit_loop:
    mov rax, r14
    shr rax, cl
    test rax, 1
    jz l_skip_xor
    
    mov rax, 63
    sub rax, rcx                         ; index = 63 - bit
    mov r10, QWORD PTR [r9 + rax*8]
    xor rbp, r10
    
l_skip_xor:
    inc ecx
    cmp ecx, 64
    jl l_bit_loop
    
    mov rax, rbp
    bswap rax
    mov QWORD PTR [rsp + 64 + r13*8], rax ; Store to temp output area
    
    inc r13d
    cmp r13d, 8
    jl l_output_loop
    
    ; Load L-transformed state back
    vmovdqu64 zmm0, ZMMWORD PTR [rsp + 64]
    
    ; ========== KeySchedule on key (zmm30) ==========
    ; K = K ^ C[i], then S->P->L on K
    
    ; Load C[round]
    movsxd rax, r12d
    mov r9, QWORD PTR [rbx + rax*8]      ; r9 = pointer to C[round]
    vmovdqu64 zmm1, ZMMWORD PTR [r9]     ; zmm1 = C[round]
    
    ; K = K ^ C[round]
    vpxorq zmm30, zmm30, zmm1
    
    ; S-transform on key
    vpandq zmm5, zmm30, zmm24
    vpermb zmm6, zmm5, zmm20
    vpermb zmm7, zmm5, zmm21
    vpermb zmm8, zmm5, zmm22
    vpermb zmm9, zmm5, zmm23
    
    vpcmpub k1, zmm30, zmm26, 1
    vpcmpub k2, zmm30, zmm26, 5
    vpcmpub k5, zmm30, zmm27, 1
    kandq k2, k2, k5
    vpcmpub k3, zmm30, zmm27, 5
    vpcmpub k5, zmm30, zmm28, 1
    kandq k3, k3, k5
    vpcmpub k4, zmm30, zmm28, 5
    
    vpxorq zmm30, zmm30, zmm30
    vmovdqu8 zmm30 {k1}, zmm6
    vmovdqu8 zmm30 {k2}, zmm7
    vmovdqu8 zmm30 {k3}, zmm8
    vmovdqu8 zmm30 {k4}, zmm9
    
    ; P-transform on key
    vpermb zmm30, zmm25, zmm30
    
    ; L-transform on key
    vmovdqu64 ZMMWORD PTR [rsp], zmm30
    
    xor r13d, r13d
    
l_key_output_loop:
    mov rax, QWORD PTR [rsp + r13*8]
    bswap rax
    mov r14, rax
    
    xor rbp, rbp
    xor ecx, ecx
    lea r9, QWORD PTR [A_MATRIX]
    
l_key_bit_loop:
    mov rax, r14
    shr rax, cl
    test rax, 1
    jz l_key_skip_xor
    
    mov rax, 63
    sub rax, rcx
    mov r10, QWORD PTR [r9 + rax*8]
    xor rbp, r10
    
l_key_skip_xor:
    inc ecx
    cmp ecx, 64
    jl l_key_bit_loop
    
    mov rax, rbp
    bswap rax
    mov QWORD PTR [rsp + 64 + r13*8], rax
    
    inc r13d
    cmp r13d, 8
    jl l_key_output_loop
    
    vmovdqu64 zmm30, ZMMWORD PTR [rsp + 64]
    
    ; ========== state = state ^ K ==========
    vpxorq zmm0, zmm0, zmm30
    
    ; Next round
    inc r12d
    cmp r12d, 12
    jl round_loop
    
    ; Store result
    vmovdqu64 ZMMWORD PTR [r15], zmm0
    
    add rsp, 128
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
streebog_e_transform ENDP

END
