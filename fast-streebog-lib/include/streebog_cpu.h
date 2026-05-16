/**
 * @file streebog_cpu.h
 * @brief CPU feature detection for Streebog implementation selection
 * 
 * Provides runtime detection of CPU capabilities (AVX2, SSSE3, AVX-512)
 * used to select optimized SIMD implementations of Streebog transforms.
 *
 * Detection is based on CPUID + XGETBV (on x86/x64 platforms).
 */


#ifdef _MSC_VER
#include <intrin.h>

// CPU feature detection (x86/x64)
// Uses CPUID + XGETBV to verify both CPU support and OS-level SIMD enablement
// before checking AVX/AVX2/AVX-512 feature bits.
static inline int has_avx2(void)
{
    int info[4];
    __cpuid(info, 0);
    if (info[0] < 7) return 0;
    __cpuid(info, 1);
    if (!(info[2] & (1 << 27))) return 0;
    unsigned long long xcr = _xgetbv(0);
    if ((xcr & 0x6) != 0x6) return 0;
    __cpuidex(info, 7, 0);
    return (info[1] & (1 << 5)) != 0;
}

static inline int has_ssse3(void)
{
    int info[4];
    __cpuid(info, 1);
    return (info[2] & (1 << 9)) != 0;
}

static inline int has_avx512(void)
{
    int info[4];
    __cpuid(info, 0);
    if (info[0] < 7) return 0;
    __cpuid(info, 1);
    if (!(info[2] & (1 << 27))) return 0;
    unsigned long long xcr = _xgetbv(0);
    if ((xcr & 0xE6) != 0xE6) return 0;
    __cpuidex(info, 7, 0);
    return (info[1] & (1 << 16)) != 0;
}

// Non-x86 platforms: SIMD feature detection not implemented
// All features default to "not available"
#else
static inline int has_avx2(void)   { return 0; }
static inline int has_ssse3(void)  { return 0; }
static inline int has_avx512(void) { return 0; }
#endif