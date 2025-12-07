; ============================================================================
; G_n compression function: g(N, h, m) -> out
; Optimized version that keeps data in registers, inlines S/P transforms
; and only uses stack for L-transform (which requires byte-level access)
;
; Input (Windows x64 calling convention):
;   rcx = pointer to N (64 bytes counter)
;   rdx = pointer to h (64 bytes hash state)  
;   r8  = pointer to m (64 bytes message block)
;   r9  = pointer to out (64 bytes output)
;
; Algorithm:
;   K = L(P(S(h ^ N)))
;   t = E(K, m)
;   out = t ^ h ^ m
;
; Register allocation:
;   zmm29 = h (saved for final XOR)
;   zmm30 = K (working key)
;   zmm31 = m (saved for E-transform and final XOR)
;   zmm0  = state (working register)
;   zmm20-25 = S-box tables and constants
;   zmm26-28 = comparison constants for S-transform
; ============================================================================

EXTERN streebog_e_transform:PROC

.data
ALIGN 16

; S-box tables
GN_SBOX_0_63   DB 0FCh, 0EEh, 0DDh, 011h, 0CFh, 06Eh, 031h, 016h, 0FBh, 0C4h, 0FAh, 0DAh, 023h, 0C5h, 004h, 04Dh
               DB 0E9h, 077h, 0F0h, 0DBh, 093h, 02Eh, 099h, 0BAh, 017h, 036h, 0F1h, 0BBh, 014h, 0CDh, 05Fh, 0C1h
               DB 0F9h, 018h, 065h, 05Ah, 0E2h, 05Ch, 0EFh, 021h, 081h, 01Ch, 03Ch, 042h, 08Bh, 001h, 08Eh, 04Fh
               DB 005h, 084h, 002h, 0AEh, 0E3h, 06Ah, 08Fh, 0A0h, 006h, 00Bh, 0EDh, 098h, 07Fh, 0D4h, 0D3h, 01Fh

GN_SBOX_64_127 DB 0EBh, 034h, 02Ch, 051h, 0EAh, 0C8h, 048h, 0ABh, 0F2h, 02Ah, 068h, 0A2h, 0FDh, 03Ah, 0CEh, 0CCh
               DB 0B5h, 070h, 00Eh, 056h, 008h, 00Ch, 076h, 012h, 0BFh, 072h, 013h, 047h, 09Ch, 0B7h, 05Dh, 087h
               DB 015h, 0A1h, 096h, 029h, 010h, 07Bh, 09Ah, 0C7h, 0F3h, 091h, 078h, 06Fh, 09Dh, 09Eh, 0B2h, 0B1h
               DB 032h, 075h, 019h, 03Dh, 0FFh, 035h, 08Ah, 07Eh, 06Dh, 054h, 0C6h, 080h, 0C3h, 0BDh, 00Dh, 057h

GN_SBOX_128_191 DB 0DFh, 0F5h, 024h, 0A9h, 03Eh, 0A8h, 043h, 0C9h, 0D7h, 079h, 0D6h, 0F6h, 07Ch, 022h, 0B9h, 003h
                DB 0E0h, 00Fh, 0ECh, 0DEh, 07Ah, 094h, 0B0h, 0BCh, 0DCh, 0E8h, 028h, 050h, 04Eh, 033h, 00Ah, 04Ah
                DB 0A7h, 097h, 060h, 073h, 01Eh, 000h, 062h, 044h, 01Ah, 0B8h, 038h, 082h, 064h, 09Fh, 026h, 041h
                DB 0ADh, 045h, 046h, 092h, 027h, 05Eh, 055h, 02Fh, 08Ch, 0A3h, 0A5h, 07Dh, 069h, 0D5h, 095h, 03Bh

GN_SBOX_192_255 DB 007h, 058h, 0B3h, 040h, 086h, 0ACh, 01Dh, 0F7h, 030h, 037h, 06Bh, 0E4h, 088h, 0D9h, 0E7h, 089h
                DB 0E1h, 01Bh, 083h, 049h, 04Ch, 03Fh, 0F8h, 0FEh, 08Dh, 053h, 0AAh, 090h, 0CAh, 0D8h, 085h, 061h
                DB 020h, 071h, 067h, 0A4h, 02Dh, 02Bh, 009h, 05Bh, 0CBh, 09Bh, 025h, 0D0h, 0BEh, 0E5h, 06Ch, 052h
                DB 059h, 0A6h, 074h, 0D2h, 0E6h, 0F4h, 0B4h, 0C0h, 0D1h, 066h, 0AFh, 0C2h, 039h, 04Bh, 063h, 0B6h

GN_CONST_3F    DB 64 DUP(03Fh)

; P-transform permutation table (TAU)
GN_TAU     DB  0,  8, 16, 24, 32, 40, 48, 56
           DB  1,  9, 17, 25, 33, 41, 49, 57
           DB  2, 10, 18, 26, 34, 42, 50, 58
           DB  3, 11, 19, 27, 35, 43, 51, 59
           DB  4, 12, 20, 28, 36, 44, 52, 60
           DB  5, 13, 21, 29, 37, 45, 53, 61
           DB  6, 14, 22, 30, 38, 46, 54, 62
           DB  7, 15, 23, 31, 39, 47, 55, 63

; L-transform matrix
GN_A_MATRIX:
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

streebog_g_n PROC
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    push rbp
    sub rsp, 200                ; Stack: 64 (K temp) + 64 (L temp) + 64 (h/m backup) + 8 alignment
    
    ; Save output pointer
    mov r15, r9
    
    ; ========== Load inputs into ZMM registers ==========
    vmovdqu64 zmm28, ZMMWORD PTR [rcx]   ; zmm28 = N
    vmovdqu64 zmm29, ZMMWORD PTR [rdx]   ; zmm29 = h (keep for final XOR)
    vmovdqu64 zmm31, ZMMWORD PTR [r8]    ; zmm31 = m (keep for E and final XOR)
    
    ; ========== K = h ^ N ==========
    vpxorq zmm0, zmm29, zmm28            ; zmm0 = K = h ^ N
    
    ; ========== Load S-box tables and constants ==========
    vmovdqu64 zmm20, ZMMWORD PTR [GN_SBOX_0_63]
    vmovdqu64 zmm21, ZMMWORD PTR [GN_SBOX_64_127]
    vmovdqu64 zmm22, ZMMWORD PTR [GN_SBOX_128_191]
    vmovdqu64 zmm23, ZMMWORD PTR [GN_SBOX_192_255]
    vmovdqu64 zmm24, ZMMWORD PTR [GN_CONST_3F]
    vmovdqu64 zmm25, ZMMWORD PTR [GN_TAU]
    
    ; Prepare comparison constants for S-transform
    mov rax, 4040404040404040h
    vpbroadcastq zmm26, rax
    mov rax, 8080808080808080h
    vpbroadcastq zmm27, rax
    mov rax, 0C0C0C0C0C0C0C0C0h
    vpbroadcastq zmm30, rax              ; zmm30 = 0xC0 broadcast
    
    ; ========== S-transform on K (zmm0) ==========
    vpandq zmm5, zmm0, zmm24             ; zmm5 = low 6 bits (index)
    
    ; Lookup in all 4 S-box ranges
    vpermb zmm6, zmm5, zmm20             ; lookup SBOX_0_63
    vpermb zmm7, zmm5, zmm21             ; lookup SBOX_64_127
    vpermb zmm8, zmm5, zmm22             ; lookup SBOX_128_191
    vpermb zmm9, zmm5, zmm23             ; lookup SBOX_192_255
    
    ; Create masks based on high bits
    vpcmpub k1, zmm0, zmm26, 1           ; k1 = bytes < 0x40
    vpcmpub k2, zmm0, zmm26, 5           ; bytes >= 0x40
    vpcmpub k5, zmm0, zmm27, 1           ; bytes < 0x80
    kandq k2, k2, k5                      ; k2 = 0x40 <= bytes < 0x80
    
    vpcmpub k3, zmm0, zmm27, 5           ; bytes >= 0x80
    vpcmpub k5, zmm0, zmm30, 1           ; bytes < 0xC0
    kandq k3, k3, k5                      ; k3 = 0x80 <= bytes < 0xC0
    
    vpcmpub k4, zmm0, zmm30, 5           ; k4 = bytes >= 0xC0
    
    ; Merge S-box results
    vpxorq zmm0, zmm0, zmm0
    vmovdqu8 zmm0 {k1}, zmm6
    vmovdqu8 zmm0 {k2}, zmm7
    vmovdqu8 zmm0 {k3}, zmm8
    vmovdqu8 zmm0 {k4}, zmm9
    
    ; ========== P-transform on K (zmm0) ==========
    vpermb zmm0, zmm25, zmm0
    
    ; ========== L-transform on K (zmm0) ==========
    ; Store to stack for byte-level access
    vmovdqu64 ZMMWORD PTR [rsp], zmm0
    
    xor r12d, r12d                       ; r12 = output qword index
    lea rbx, QWORD PTR [GN_A_MATRIX]
    
gn_l_output_loop:
    mov rax, QWORD PTR [rsp + r12*8]
    bswap rax
    mov r13, rax                         ; r13 = input qword (byte-swapped)
    
    xor r14, r14                         ; r14 = accumulator
    xor ecx, ecx                         ; ecx = bit index
    
gn_l_bit_loop:
    mov rax, r13
    shr rax, cl
    test rax, 1
    jz gn_l_skip_xor
    
    mov rax, 63
    sub rax, rcx
    mov r10, QWORD PTR [rbx + rax*8]
    xor r14, r10
    
gn_l_skip_xor:
    inc ecx
    cmp ecx, 64
    jl gn_l_bit_loop
    
    mov rax, r14
    bswap rax
    mov QWORD PTR [rsp + 64 + r12*8], rax
    
    inc r12d
    cmp r12d, 8
    jl gn_l_output_loop
    
    ; K = L(P(S(h ^ N))) is now at [rsp + 64]
    ; zmm29 = h, zmm31 = m (still preserved in registers)
    
    ; ========== Save h and m to stack before calling e_transform ==========
    ; (e_transform may clobber zmm29, zmm31)
    vmovdqu64 ZMMWORD PTR [rsp + 128], zmm29   ; save h
    vmovdqu64 ZMMWORD PTR [rsp], zmm31         ; save m (reuse K input area)
    
    ; ========== t = E(K, m) ==========
    ; streebog_e_transform(K, m, t)
    lea rcx, QWORD PTR [rsp + 64]        ; rcx = K
    lea rdx, QWORD PTR [rsp]             ; rdx = m
    lea r8, QWORD PTR [rsp + 64]         ; r8 = t (output, reuse K area)
    call streebog_e_transform
    
    ; ========== Final: out = t ^ h ^ m ==========
    ; Load t from stack
    vmovdqu64 zmm0, ZMMWORD PTR [rsp + 64]    ; zmm0 = t
    vmovdqu64 zmm1, ZMMWORD PTR [rsp + 128]   ; zmm1 = h
    vmovdqu64 zmm2, ZMMWORD PTR [rsp]         ; zmm2 = m
    
    vpxorq zmm0, zmm0, zmm1              ; t ^ h
    vpxorq zmm0, zmm0, zmm2              ; t ^ h ^ m
    
    ; Store result
    vmovdqu64 ZMMWORD PTR [r15], zmm0
    
    add rsp, 200
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
streebog_g_n ENDP

END
