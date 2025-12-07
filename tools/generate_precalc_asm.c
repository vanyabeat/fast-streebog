/**
 * @file generate_precalc_asm.c
 * @brief Generator for precalculated Ax tables in MASM format
 */

#include <stdint.h>
#include <stdio.h>


// Matrix A for L-transform
static const uint64_t STREEBOG_A[64] = {
    0x8e20faa72ba0b470ULL, 0x47107ddd9b505a38ULL, 0xad08b0e0c3282d1cULL, 0xd8045870ef14980eULL, 0x6c022c38f90a4c07ULL,
    0x3601161cf205268dULL, 0x1b8e0b0e798c13c8ULL, 0x83478b07b2468764ULL, 0xa011d380818e8f40ULL, 0x5086e740ce47c920ULL,
    0x2843fd2067adea10ULL, 0x14aff010bdd87508ULL, 0x0ad97808d06cb404ULL, 0x05e23c0468365a02ULL, 0x8c711e02341b2d01ULL,
    0x46b60f011a83988eULL, 0x90dab52a387ae76fULL, 0x486dd4151c3dfdb9ULL, 0x24b86a840e90f0d2ULL, 0x125c354207487869ULL,
    0x092e94218d243cbaULL, 0x8a174a9ec8121e5dULL, 0x4585254f64090fa0ULL, 0xaccc9ca9328a8950ULL, 0x9d4df05d5f661451ULL,
    0xc0a878a0a1330aa6ULL, 0x60543c50de970553ULL, 0x302a1e286fc58ca7ULL, 0x18150f14b9ec46ddULL, 0x0c84890ad27623e0ULL,
    0x0642ca05693b9f70ULL, 0x0321658cba93c138ULL, 0x86275df09ce8aaa8ULL, 0x439da0784e745554ULL, 0xafc0503c273aa42aULL,
    0xd960281e9d1d5215ULL, 0xe230140fc0802984ULL, 0x71180a8960409a42ULL, 0xb60c05ca30204d21ULL, 0x5b068c651810a89eULL,
    0x456c34887a3805b9ULL, 0xac361a443d1c8cd2ULL, 0x561b0d22900e4669ULL, 0x2b838811480723baULL, 0x9bcf4486248d9f5dULL,
    0xc3e9224312c8c1a0ULL, 0xeffa11af0964ee50ULL, 0xf97d86d98a327728ULL, 0xe4fa2054a80b329cULL, 0x727d102a548b194eULL,
    0x39b008152acb8227ULL, 0x9258048415eb419dULL, 0x492c024284fbaec0ULL, 0xaa16012142f35760ULL, 0x550b8e9e21f7a530ULL,
    0xa48b474f9ef5dc18ULL, 0x70a6a56e2440598eULL, 0x3853dc371220a247ULL, 0x1ca76e95091051adULL, 0x0edd37c48a08a6d8ULL,
    0x07e095624504536cULL, 0x8d70c431ac02a736ULL, 0xc83862965601dd1bULL, 0x641c314b2b8ee083ULL};

static uint64_t gf2_64_mul(uint64_t val)
{
    uint64_t result = 0;
    for (int i = 0; i < 64; i++)
    {
        if (val & (1ULL << (63 - i)))
        {
            result ^= STREEBOG_A[i];
        }
    }
    return result;
}

static void generate_Ax_table(uint64_t Ax[8][256])
{
    for (int col = 0; col < 8; col++)
    {
        for (int byte_val = 0; byte_val < 256; byte_val++)
        {
            uint64_t val = ((uint64_t)byte_val) << (56 - col * 8);
            Ax[col][byte_val] = gf2_64_mul(val);
        }
    }
}

int main(int argc, char *argv[])
{
    uint64_t Ax[8][256];

    printf("Generating precalculated Ax tables in MASM format...\n");
    generate_Ax_table(Ax);

    const char *filename = (argc > 1) ? argv[1] : "streebog_precalc.asm";
    FILE *f = fopen(filename, "w");
    if (!f)
    {
        fprintf(stderr, "Error: Cannot create file %s\n", filename);
        return 1;
    }

    fprintf(f, "; Precalculated lookup tables for optimized Streebog L-transform\n");
    fprintf(f, "; This file contains Ax[8][256] lookup table\n");
    fprintf(f, "; Total size: 8 * 256 * 8 bytes = 16 KB\n\n");
    fprintf(f, ".data\n");
    fprintf(f, "ALIGN 16\n\n");

    for (int col = 0; col < 8; col++)
    {
        fprintf(f, "; Column %d (byte offset %d)\n", col, col);
        fprintf(f, "Ax_COL%d:\n", col);

        for (int row = 0; row < 256; row++)
        {
            fprintf(f, "    QWORD 0%016llxh\n", (unsigned long long)Ax[col][row]);
        }
        fprintf(f, "\n");
    }

    fprintf(f, "\n; Export column addresses for easy access\n");
    fprintf(f, "PUBLIC Ax_COLUMNS\n");
    fprintf(f, "Ax_COLUMNS:\n");
    for (int col = 0; col < 8; col++)
    {
        fprintf(f, "    QWORD Ax_COL%d\n", col);
    }

    fclose(f);

    printf("Successfully generated %s\n", filename);
    printf("Table size: %zu bytes (%.1f KB)\n", sizeof(Ax), sizeof(Ax) / 1024.0);

    return 0;
}
