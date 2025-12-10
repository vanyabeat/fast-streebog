.CODE

streebog_xor_512 PROC
    vmovdqu64 zmm0, [rcx]      
    vmovdqu64 zmm1, [rdx]      
    vpxorq zmm2, zmm0, zmm1    
    vmovdqu64 [r8], zmm2       
    ret
streebog_xor_512 ENDP

END