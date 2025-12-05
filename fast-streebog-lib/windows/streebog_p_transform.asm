.DATA
TAU     DB  0,  8, 16, 24, 32, 40, 48, 56
        DB  1,  9, 17, 25, 33, 41, 49, 57
        DB  2, 10, 18, 26, 34, 42, 50, 58
        DB  3, 11, 19, 27, 35, 43, 51, 59
        DB  4, 12, 20, 28, 36, 44, 52, 60
        DB  5, 13, 21, 29, 37, 45, 53, 61
        DB  6, 14, 22, 30, 38, 46, 54, 62
        DB  7, 15, 23, 31, 39, 47, 55, 63
.CODE
streebog_p_transform PROC
    vmovdqu64 zmm0, ZMMWORD PTR [rcx]   
    vmovdqu64 zmm1, ZMMWORD PTR [TAU]   
    vpermb zmm0, zmm1, zmm0             
    vmovdqu64 ZMMWORD PTR [rdx], zmm0   
    ret
streebog_p_transform ENDP
END