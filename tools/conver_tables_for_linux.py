#!/usr/bin/env python3

import struct

A = [
    0x8e20faa72ba0b470,0x47107ddd9b505a38,0xad08b0e0c3282d1c,0xd8045870ef14980e,
    0x6c022c38f90a4c07,0x3601161cf205268d,0x1b8e0b0e798c13c8,0x83478b07b2468764,
    0xa011d380818e8f40,0x5086e740ce47c920,0x2843fd2067adea10,0x14aff010bdd87508,
    0x0ad97808d06cb404,0x05e23c0468365a02,0x8c711e02341b2d01,0x46b60f011a83988e,
    0x90dab52a387ae76f,0x486dd4151c3dfdb9,0x24b86a840e90f0d2,0x125c354207487869,
    0x092e94218d243cba,0x8a174a9ec8121e5d,0x4585254f64090fa0,0xaccc9ca9328a8950,
    0x9d4df05d5f661451,0xc0a878a0a1330aa6,0x60543c50de970553,0x302a1e286fc58ca7,
    0x18150f14b9ec46dd,0x0c84890ad27623e0,0x0642ca05693b9f70,0x0321658cba93c138,
    0x86275df09ce8aaa8,0x439da0784e745554,0xafc0503c273aa42a,0xd960281e9d1d5215,
    0xe230140fc0802984,0x71180a8960409a42,0xb60c05ca30204d21,0x5b068c651810a89e,
    0x456c34887a3805b9,0xac361a443d1c8cd2,0x561b0d22900e4669,0x2b838811480723ba,
    0x9bcf4486248d9f5d,0xc3e9224312c8c1a0,0xeffa11af0964ee50,0xf97d86d98a327728,
    0xe4fa2054a80b329c,0x727d102a548b194e,0x39b008152acb8227,0x9258048415eb419d,
    0x492c024284fbaec0,0xaa16012142f35760,0x550b8e9e21f7a530,0xa48b474f9ef5dc18,
    0x70a6a56e2440598e,0x3853dc371220a247,0x1ca76e95091051ad,0x0edd37c48a08a6d8,
    0x07e095624504536c,0x8d70c431ac02a736,0xc83862965601dd1b,0x641c314b2b8ee083,
]

def mul(val):
    r = 0
    for i in range(64):
        if val & (1 << (63 - i)):
            r ^= A[i]
    return r

Ax = [[mul(v << (56 - col*8)) for v in range(256)] for col in range(8)]

with open("streebog_precalc_tables_avx2.S", "w") as f:
    f.write(".intel_syntax noprefix\n\n")
    f.write("    .section .rodata\n    .align 16\n\n")
    f.write("    .globl Ax_T\nAx_T:\n\n")
    f.write("    .hidden Ax_T\nAx_T:\n\n")
    for v in range(256):
        f.write(f"# v = 0x{v:02X}\n")
        for col in range(8):
            f.write(f"    .quad 0x{Ax[col][v]:016X}\n")
        f.write("\n")

with open("streebog_precalc_tables_ssse3.S", "w") as f:
    f.write(".intel_syntax noprefix\n\n")
    f.write("    .section .rodata\n    .align 16\n\n")
    for col in range(8):
        f.write(f"    .globl Ax_COL{col}\n.hidden Ax_COL{col}\nAx_COL{col}:\n")
        for v in range(256):
            f.write(f"    .quad 0x{Ax[col][v]:016X}\n")
        f.write("\n")

print("Done")