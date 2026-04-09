.DATA
ALIGN 16

SBOX DB 0FCh,0EEh,0DDh,011h,0CFh,06Eh,031h,016h
     DB 0FBh,0C4h,0FAh,0DAh,023h,0C5h,004h,04Dh
     DB 0E9h,077h,0F0h,0DBh,093h,02Eh,099h,0BAh
     DB 017h,036h,0F1h,0BBh,014h,0CDh,05Fh,0C1h
     DB 0F9h,018h,065h,05Ah,0E2h,05Ch,0EFh,021h
     DB 081h,01Ch,03Ch,042h,08Bh,001h,08Eh,04Fh
     DB 005h,084h,002h,0AEh,0E3h,06Ah,08Fh,0A0h
     DB 006h,00Bh,0EDh,098h,07Fh,0D4h,0D3h,01Fh
     DB 0EBh,034h,02Ch,051h,0EAh,0C8h,048h,0ABh
     DB 0F2h,02Ah,068h,0A2h,0FDh,03Ah,0CEh,0CCh
     DB 0B5h,070h,00Eh,056h,008h,00Ch,076h,012h
     DB 0BFh,072h,013h,047h,09Ch,0B7h,05Dh,087h
     DB 015h,0A1h,096h,029h,010h,07Bh,09Ah,0C7h
     DB 0F3h,091h,078h,06Fh,09Dh,09Eh,0B2h,0B1h
     DB 032h,075h,019h,03Dh,0FFh,035h,08Ah,07Eh
     DB 06Dh,054h,0C6h,080h,0C3h,0BDh,00Dh,057h
     DB 0DFh,0F5h,024h,0A9h,03Eh,0A8h,043h,0C9h
     DB 0D7h,079h,0D6h,0F6h,07Ch,022h,0B9h,003h
     DB 0E0h,00Fh,0ECh,0DEh,07Ah,094h,0B0h,0BCh
     DB 0DCh,0E8h,028h,050h,04Eh,033h,00Ah,04Ah
     DB 0A7h,097h,060h,073h,01Eh,000h,062h,044h
     DB 01Ah,0B8h,038h,082h,064h,09Fh,026h,041h
     DB 0ADh,045h,046h,092h,027h,05Eh,055h,02Fh
     DB 08Ch,0A3h,0A5h,07Dh,069h,0D5h,095h,03Bh
     DB 007h,058h,0B3h,040h,086h,0ACh,01Dh,0F7h
     DB 030h,037h,06Bh,0E4h,088h,0D9h,0E7h,089h
     DB 0E1h,01Bh,083h,049h,04Ch,03Fh,0F8h,0FEh
     DB 08Dh,053h,0AAh,090h,0CAh,0D8h,085h,061h
     DB 020h,071h,067h,0A4h,02Dh,02Bh,009h,05Bh
     DB 0CBh,09Bh,025h,0D0h,0BEh,0E5h,06Ch,052h
     DB 059h,0A6h,074h,0D2h,0E6h,0F4h,0B4h,0C0h
     DB 0D1h,066h,0AFh,0C2h,039h,04Bh,063h,0B6h

.CODE

streebog_s_transform_sse2 PROC

    push rbx
    push rsi
    push rdi

    mov rsi, rcx                    ; source pointer = input
    mov rdi, rdx                    ; destination pointer = output 
    lea rbx, SBOX                   ; load address of S-box table

    mov ecx, 64                     ; number of bytes to process

loop_start:
    movzx eax, BYTE PTR [rsi]       ; load byte from input (zero-extend to 32-bit)
    mov al, BYTE PTR [rbx + rax]    ; look up S-box transformation
    mov BYTE PTR [rdi], al          ; store transformed byte

    inc rsi                         ; advance source pointer
    inc rdi                         ; advance destination pointer
    dec ecx                         ; decrement loop counter
    jnz loop_start                  ; continue until 64 bytes processed

    ; restore
    pop rdi
    pop rsi
    pop rbx
    ret

streebog_s_transform_sse2 ENDP

END