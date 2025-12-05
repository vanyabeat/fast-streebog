#include "fast_streebog.h"
#include <gtest/gtest.h>
#include <vector>

static const uint8_t STREEBOG_SBOX[256] = {
    0xFC, 0xEE, 0xDD, 0x11, 0xCF, 0x6E, 0x31, 0x16, 0xFB, 0xC4, 0xFA, 0xDA, 0x23, 0xC5, 0x04, 0x4D, 0xE9, 0x77, 0xF0,
    0xDB, 0x93, 0x2E, 0x99, 0xBA, 0x17, 0x36, 0xF1, 0xBB, 0x14, 0xCD, 0x5F, 0xC1, 0xF9, 0x18, 0x65, 0x5A, 0xE2, 0x5C,
    0xEF, 0x21, 0x81, 0x1C, 0x3C, 0x42, 0x8B, 0x01, 0x8E, 0x4F, 0x05, 0x84, 0x02, 0xAE, 0xE3, 0x6A, 0x8F, 0xA0, 0x06,
    0x0B, 0xED, 0x98, 0x7F, 0xD4, 0xD3, 0x1F, 0xEB, 0x34, 0x2C, 0x51, 0xEA, 0xC8, 0x48, 0xAB, 0xF2, 0x2A, 0x68, 0xA2,
    0xFD, 0x3A, 0xCE, 0xCC, 0xB5, 0x70, 0x0E, 0x56, 0x08, 0x0C, 0x76, 0x12, 0xBF, 0x72, 0x13, 0x47, 0x9C, 0xB7, 0x5D,
    0x87, 0x15, 0xA1, 0x96, 0x29, 0x10, 0x7B, 0x9A, 0xC7, 0xF3, 0x91, 0x78, 0x6F, 0x9D, 0x9E, 0xB2, 0xB1, 0x32, 0x75,
    0x19, 0x3D, 0xFF, 0x35, 0x8A, 0x7E, 0x6D, 0x54, 0xC6, 0x80, 0xC3, 0xBD, 0x0D, 0x57, 0xDF, 0xF5, 0x24, 0xA9, 0x3E,
    0xA8, 0x43, 0xC9, 0xD7, 0x79, 0xD6, 0xF6, 0x7C, 0x22, 0xB9, 0x03, 0xE0, 0x0F, 0xEC, 0xDE, 0x7A, 0x94, 0xB0, 0xBC,
    0xDC, 0xE8, 0x28, 0x50, 0x4E, 0x33, 0x0A, 0x4A, 0xA7, 0x97, 0x60, 0x73, 0x1E, 0x00, 0x62, 0x44, 0x1A, 0xB8, 0x38,
    0x82, 0x64, 0x9F, 0x26, 0x41, 0xAD, 0x45, 0x46, 0x92, 0x27, 0x5E, 0x55, 0x2F, 0x8C, 0xA3, 0xA5, 0x7D, 0x69, 0xD5,
    0x95, 0x3B, 0x07, 0x58, 0xB3, 0x40, 0x86, 0xAC, 0x1D, 0xF7, 0x30, 0x37, 0x6B, 0xE4, 0x88, 0xD9, 0xE7, 0x89, 0xE1,
    0x1B, 0x83, 0x49, 0x4C, 0x3F, 0xF8, 0xFE, 0x8D, 0x53, 0xAA, 0x90, 0xCA, 0xD8, 0x85, 0x61, 0x20, 0x71, 0x67, 0xA4,
    0x2D, 0x2B, 0x09, 0x5B, 0xCB, 0x9B, 0x25, 0xD0, 0xBE, 0xE5, 0x6C, 0x52, 0x59, 0xA6, 0x74, 0xD2, 0xE6, 0xF4, 0xB4,
    0xC0, 0xD1, 0x66, 0xAF, 0xC2, 0x39, 0x4B, 0x63, 0xB6};

TEST(FastStreebog, TestZero)
{
    std::vector<uint8_t> a(64, 0x00);
    std::vector<uint8_t> b(64, 0x00);
    std::vector<uint8_t> out(64, 0x00);
    std::vector<uint8_t> expected(64, 0x00);

    STREEBOG_NAMESPACE(xor_512)(a.data(), b.data(), out.data());

    EXPECT_EQ(out, expected);
}

TEST(FastStreebog, TestXOR)
{
    std::vector<uint8_t> a(64, 0xFF);
    std::vector<uint8_t> b(64, 0x0F);
    std::vector<uint8_t> out(64, 0x00);
    std::vector<uint8_t> expected(64, 0xF0);

    STREEBOG_NAMESPACE(xor_512)(a.data(), b.data(), out.data());

    EXPECT_EQ(out, expected);
}

TEST(FastStreebog, TestAddAsm)
{
    std::vector<uint8_t> a(64, 0x01);
    std::vector<uint8_t> b(64, 0x02);
    std::vector<uint8_t> out(64, 0x00);
    std::vector<uint8_t> expected(64, 0x03);

    STREEBOG_NAMESPACE(add_512)(a.data(), b.data(), out.data());

    EXPECT_EQ(out, expected);
}

TEST(FastStreebog, TestAddWithCarryAsm)
{
    std::vector<uint8_t> a(64, 0x00);
    std::vector<uint8_t> b(64, 0x00);
    std::vector<uint8_t> out(64, 0x00);
    std::vector<uint8_t> expected(64, 0x00);

    a[63] = 0xFF;

    b[63] = 0x01;

    expected[62] = 0x01;
    expected[63] = 0x00;

    STREEBOG_NAMESPACE(add_512)(a.data(), b.data(), out.data());

    EXPECT_EQ(out, expected);
}

TEST(FastStreebog, TestAddCascadeCarryAsm)
{
    std::vector<uint8_t> a(64, 0xFF);
    std::vector<uint8_t> b(64, 0x00);
    std::vector<uint8_t> out(64, 0x00);
    std::vector<uint8_t> expected(64, 0x00);

    b[63] = 0x01;

    STREEBOG_NAMESPACE(add_512)(a.data(), b.data(), out.data());

    EXPECT_EQ(out, expected);
}

TEST(FastStreebog, TestAddDoubleAsm)
{
    std::vector<uint8_t> a(64, 0x00);
    std::vector<uint8_t> b(64, 0x00);
    std::vector<uint8_t> out(64, 0x00);
    std::vector<uint8_t> expected(64, 0x00);

    a[63] = 0x80;
    b[63] = 0x80;
    expected[62] = 0x01;
    expected[63] = 0x00;

    STREEBOG_NAMESPACE(add_512)(a.data(), b.data(), out.data());

    EXPECT_EQ(out, expected);
}

TEST(FastStreebog, TestSTransform)
{

    auto scalar_s = [](const uint8_t *state, uint8_t *out) {
        for (int i = 0; i < 64; i++)
        {
            out[i] = STREEBOG_SBOX[state[i]];
        }
    };

    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_avx512(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>(i * 4);
    }

    scalar_s(state.data(), out_scalar.data());

    STREEBOG_NAMESPACE(s_transform)(state.data(), out_avx512.data());

    EXPECT_EQ(out_avx512, out_scalar);
}

TEST(FastStreebog, TestSTransformAVX512MasmAllValues)
{

    auto scalar_s = [](const uint8_t *state, uint8_t *out) {
        for (int i = 0; i < 64; i++)
        {
            out[i] = STREEBOG_SBOX[state[i]];
        }
    };

    for (int offset = 0; offset < 4; offset++)
    {
        std::vector<uint8_t> state(64);
        std::vector<uint8_t> out_avx512(64);
        std::vector<uint8_t> out_scalar(64);

        for (int i = 0; i < 64; i++)
        {
            state[i] = static_cast<uint8_t>(offset * 64 + i);
        }

        scalar_s(state.data(), out_scalar.data());
        STREEBOG_NAMESPACE(s_transform)(state.data(), out_avx512.data());

        EXPECT_EQ(out_avx512, out_scalar) << "Failed at offset " << offset;
    }
}

TEST(FastStreebog, TestSTransformInPlace)
{
    auto scalar_s = [](const uint8_t *state, uint8_t *out) {
        for (int i = 0; i < 64; i++)
        {
            out[i] = STREEBOG_SBOX[state[i]];
        }
    };

    std::vector<uint8_t> state(64);
    std::vector<uint8_t> in_place(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 37 + 13) % 256);
        in_place[i] = state[i];
    }

    scalar_s(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(s_transform)(in_place.data(), in_place.data());

    EXPECT_EQ(in_place, out_scalar) << "In-place S-transform failed";
}

static const uint8_t TAU[64] = {0,  8,  16, 24, 32, 40, 48, 56, 1,  9,  17, 25, 33, 41, 49, 57, 2,  10, 18, 26, 34, 42,
                                50, 58, 3,  11, 19, 27, 35, 43, 51, 59, 4,  12, 20, 28, 36, 44, 52, 60, 5,  13, 21, 29,
                                37, 45, 53, 61, 6,  14, 22, 30, 38, 46, 54, 62, 7,  15, 23, 31, 39, 47, 55, 63};

TEST(FastStreebog, TestPTransform)
{

    auto scalar_p = [](const uint8_t *state, uint8_t *out) {
        for (int i = 0; i < 64; i++)
        {
            out[i] = state[TAU[i]];
        }
    };

    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_avx512(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>(i);
    }

    scalar_p(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(p_transform)(state.data(), out_avx512.data());

    EXPECT_EQ(out_avx512, out_scalar);
}

TEST(FastStreebog, TestPTransformRandom)
{
    auto scalar_p = [](const uint8_t *state, uint8_t *out) {
        for (int i = 0; i < 64; i++)
        {
            out[i] = state[TAU[i]];
        }
    };

    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_avx512(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 17 + 31) % 256);
    }

    scalar_p(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(p_transform)(state.data(), out_avx512.data());

    EXPECT_EQ(out_avx512, out_scalar);
}

TEST(FastStreebog, TestPTransformInPlace)
{
    auto scalar_p = [](const uint8_t *state, uint8_t *out) {
        for (int i = 0; i < 64; i++)
        {
            out[i] = state[TAU[i]];
        }
    };

    std::vector<uint8_t> state(64);
    std::vector<uint8_t> in_place(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 17 + 31) % 256);
        in_place[i] = state[i];
    }

    scalar_p(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(p_transform)(in_place.data(), in_place.data());

    EXPECT_EQ(in_place, out_scalar) << "In-place P-transform failed";
}

const uint64_t A[] = {
    0x8e20faa72ba0b470, 0x47107ddd9b505a38, 0xad08b0e0c3282d1c, 0xd8045870ef14980e, 0x6c022c38f90a4c07,
    0x3601161cf205268d, 0x1b8e0b0e798c13c8, 0x83478b07b2468764, 0xa011d380818e8f40, 0x5086e740ce47c920,
    0x2843fd2067adea10, 0x14aff010bdd87508, 0x0ad97808d06cb404, 0x05e23c0468365a02, 0x8c711e02341b2d01,
    0x46b60f011a83988e, 0x90dab52a387ae76f, 0x486dd4151c3dfdb9, 0x24b86a840e90f0d2, 0x125c354207487869,
    0x092e94218d243cba, 0x8a174a9ec8121e5d, 0x4585254f64090fa0, 0xaccc9ca9328a8950, 0x9d4df05d5f661451,
    0xc0a878a0a1330aa6, 0x60543c50de970553, 0x302a1e286fc58ca7, 0x18150f14b9ec46dd, 0x0c84890ad27623e0,
    0x0642ca05693b9f70, 0x0321658cba93c138, 0x86275df09ce8aaa8, 0x439da0784e745554, 0xafc0503c273aa42a,
    0xd960281e9d1d5215, 0xe230140fc0802984, 0x71180a8960409a42, 0xb60c05ca30204d21, 0x5b068c651810a89e,
    0x456c34887a3805b9, 0xac361a443d1c8cd2, 0x561b0d22900e4669, 0x2b838811480723ba, 0x9bcf4486248d9f5d,
    0xc3e9224312c8c1a0, 0xeffa11af0964ee50, 0xf97d86d98a327728, 0xe4fa2054a80b329c, 0x727d102a548b194e,
    0x39b008152acb8227, 0x9258048415eb419d, 0x492c024284fbaec0, 0xaa16012142f35760, 0x550b8e9e21f7a530,
    0xa48b474f9ef5dc18, 0x70a6a56e2440598e, 0x3853dc371220a247, 0x1ca76e95091051ad, 0x0edd37c48a08a6d8,
    0x07e095624504536c, 0x8d70c431ac02a736, 0xc83862965601dd1b, 0x641c314b2b8ee083};

static uint64_t scalar_l_mul64(uint64_t x)
{
    uint64_t result = 0;
    for (int i = 0; i < 64; i++)
    {
        if (x & (1ULL << (63 - i)))
        {
            result ^= A[i];
        }
    }
    return result;
}

static uint64_t bytes_to_u64_be(const uint8_t *bytes)
{
    return ((uint64_t)bytes[0] << 56) | ((uint64_t)bytes[1] << 48) | ((uint64_t)bytes[2] << 40) |
           ((uint64_t)bytes[3] << 32) | ((uint64_t)bytes[4] << 24) | ((uint64_t)bytes[5] << 16) |
           ((uint64_t)bytes[6] << 8) | ((uint64_t)bytes[7]);
}

static void u64_to_bytes_be(uint64_t val, uint8_t *bytes)
{
    bytes[0] = (uint8_t)(val >> 56);
    bytes[1] = (uint8_t)(val >> 48);
    bytes[2] = (uint8_t)(val >> 40);
    bytes[3] = (uint8_t)(val >> 32);
    bytes[4] = (uint8_t)(val >> 24);
    bytes[5] = (uint8_t)(val >> 16);
    bytes[6] = (uint8_t)(val >> 8);
    bytes[7] = (uint8_t)(val);
}

static void scalar_l_transform(const uint8_t *state, uint8_t *out)
{
    for (int i = 0; i < 8; i++)
    {
        uint64_t block = bytes_to_u64_be(state + i * 8);
        uint64_t result = scalar_l_mul64(block);
        u64_to_bytes_be(result, out + i * 8);
    }
}

TEST(FastStreebog, TestLTransformScalar)
{
    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>(i);
    }

    scalar_l_transform(state.data(), out_scalar.data());

    uint64_t input_block = 0x0001020304050607ULL;
    uint64_t expected = scalar_l_mul64(input_block);
    uint64_t actual = bytes_to_u64_be(out_scalar.data());
    EXPECT_EQ(actual, expected);
}

TEST(FastStreebog, TestLTransformSingleBit)
{

    std::vector<uint8_t> state(64, 0);
    std::vector<uint8_t> out_scalar(64);

    state[0] = 0x80;

    scalar_l_transform(state.data(), out_scalar.data());

    uint64_t result = bytes_to_u64_be(out_scalar.data());
    EXPECT_EQ(result, A[0]);
}

TEST(FastStreebog, TestLTransformRandom)
{
    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 37 + 13) % 256);
    }

    scalar_l_transform(state.data(), out_scalar.data());

    for (int block = 0; block < 8; block++)
    {
        uint64_t input = bytes_to_u64_be(state.data() + block * 8);
        uint64_t expected = scalar_l_mul64(input);
        uint64_t actual = bytes_to_u64_be(out_scalar.data() + block * 8);
        EXPECT_EQ(actual, expected) << "Block " << block << " mismatch";
    }
}

TEST(FastStreebog, TestLTransformAsm)
{
    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_asm(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>(i);
    }

    scalar_l_transform(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(l_transform)(state.data(), out_asm.data());

    EXPECT_EQ(out_asm, out_scalar);
}

TEST(FastStreebog, TestLTransformAsmSingleBit)
{
    std::vector<uint8_t> state(64, 0);
    std::vector<uint8_t> out_asm(64);

    state[0] = 0x80;

    STREEBOG_NAMESPACE(l_transform)(state.data(), out_asm.data());

    uint64_t result = bytes_to_u64_be(out_asm.data());
    EXPECT_EQ(result, A[0]);
}

TEST(FastStreebog, TestLTransformAsmAllBits)
{

    for (int bit = 0; bit < 64; bit++)
    {
        std::vector<uint8_t> state(64, 0);
        std::vector<uint8_t> out_asm(64);

        int byte_idx = bit / 8;
        int bit_in_byte = 7 - (bit % 8);
        state[byte_idx] = static_cast<uint8_t>(1 << bit_in_byte);

        STREEBOG_NAMESPACE(l_transform)(state.data(), out_asm.data());

        uint64_t result = bytes_to_u64_be(out_asm.data());
        EXPECT_EQ(result, A[bit]) << "Bit " << bit << " mismatch";
    }
}

TEST(FastStreebog, TestLTransformAsmRandom)
{
    std::vector<uint8_t> state(64);
    std::vector<uint8_t> out_asm(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 37 + 13) % 256);
    }

    scalar_l_transform(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(l_transform)(state.data(), out_asm.data());

    EXPECT_EQ(out_asm, out_scalar);
}

TEST(FastStreebog, TestLTransformAsmInPlace)
{
    std::vector<uint8_t> state(64);
    std::vector<uint8_t> in_place(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 37 + 13) % 256);
        in_place[i] = state[i];
    }

    scalar_l_transform(state.data(), out_scalar.data());
    STREEBOG_NAMESPACE(l_transform)(in_place.data(), in_place.data());

    EXPECT_EQ(in_place, out_scalar) << "In-place L-transform failed";
}

static const uint8_t C[12][64] = {
    {0xb1, 0x08, 0x5b, 0xda, 0x1e, 0xca, 0xda, 0xe9, 0xeb, 0xcb, 0x2f, 0x81, 0xc0, 0x65, 0x7c, 0x1f,
     0x2f, 0x6a, 0x76, 0x43, 0x2e, 0x45, 0xd0, 0x16, 0x71, 0x4e, 0xb8, 0x8d, 0x75, 0x85, 0xc4, 0xfc,
     0x4b, 0x7c, 0xe0, 0x91, 0x92, 0x67, 0x69, 0x01, 0xa2, 0x42, 0x2a, 0x08, 0xa4, 0x60, 0xd3, 0x15,
     0x05, 0x76, 0x74, 0x36, 0xcc, 0x74, 0x4d, 0x23, 0xdd, 0x80, 0x65, 0x59, 0xf2, 0xa6, 0x45, 0x07},
    {0x6f, 0xa3, 0xb5, 0x8a, 0xa9, 0x9d, 0x2f, 0x1a, 0x4f, 0xe3, 0x9d, 0x46, 0x0f, 0x70, 0xb5, 0xd7,
     0xf3, 0xfe, 0xea, 0x72, 0x0a, 0x23, 0x2b, 0x98, 0x61, 0xd5, 0x5e, 0x0f, 0x16, 0xb5, 0x01, 0x31,
     0x9a, 0xb5, 0x17, 0x6b, 0x12, 0xd6, 0x99, 0x58, 0x5c, 0xb5, 0x61, 0xc2, 0xdb, 0x0a, 0xa7, 0xca,
     0x55, 0xdd, 0xa2, 0x1b, 0xd7, 0xcb, 0xcd, 0x56, 0xe6, 0x79, 0x04, 0x70, 0x21, 0xb1, 0x9b, 0xb7},
    {0xf5, 0x74, 0xdc, 0xac, 0x2b, 0xce, 0x2f, 0xc7, 0x0a, 0x39, 0xfc, 0x28, 0x6a, 0x3d, 0x84, 0x35,
     0x06, 0xf1, 0x5e, 0x5f, 0x52, 0x9c, 0x1f, 0x8b, 0xf2, 0xea, 0x75, 0x14, 0xb1, 0x29, 0x7b, 0x7b,
     0xd3, 0xe2, 0x0f, 0xe4, 0x90, 0x35, 0x9e, 0xb1, 0xc1, 0xc9, 0x3a, 0x37, 0x60, 0x62, 0xdb, 0x09,
     0xc2, 0xb6, 0xf4, 0x43, 0x86, 0x7a, 0xdb, 0x31, 0x99, 0x1e, 0x96, 0xf5, 0x0a, 0xba, 0x0a, 0xb2},
    {0xef, 0x1f, 0xdf, 0xb3, 0xe8, 0x15, 0x66, 0xd2, 0xf9, 0x48, 0xe1, 0xa0, 0x5d, 0x71, 0xe4, 0xdd,
     0x48, 0x8e, 0x85, 0x7e, 0x33, 0x5c, 0x3c, 0x7d, 0x9d, 0x72, 0x1c, 0xad, 0x68, 0x5e, 0x35, 0x3f,
     0xa9, 0xd7, 0x2c, 0x82, 0xed, 0x03, 0xd6, 0x75, 0xd8, 0xb7, 0x13, 0x33, 0x93, 0x52, 0x03, 0xbe,
     0x34, 0x53, 0xea, 0xa1, 0x93, 0xe8, 0x37, 0xf1, 0x22, 0x0c, 0xbe, 0xbc, 0x84, 0xe3, 0xd1, 0x2e},
    {0x4b, 0xea, 0x6b, 0xac, 0xad, 0x47, 0x47, 0x99, 0x9a, 0x3f, 0x41, 0x0c, 0x6c, 0xa9, 0x23, 0x63,
     0x7f, 0x15, 0x1c, 0x1f, 0x16, 0x86, 0x10, 0x4a, 0x35, 0x9e, 0x35, 0xd7, 0x80, 0x0f, 0xff, 0xbd,
     0xbf, 0xcd, 0x17, 0x47, 0x25, 0x3a, 0xf5, 0xa3, 0xdf, 0xff, 0x00, 0xb7, 0x23, 0x27, 0x1a, 0x16,
     0x7a, 0x56, 0xa2, 0x7e, 0xa9, 0xea, 0x63, 0xf5, 0x60, 0x17, 0x58, 0xfd, 0x7c, 0x6c, 0xfe, 0x57},
    {0xae, 0x4f, 0xae, 0xae, 0x1d, 0x3a, 0xd3, 0xd9, 0x6f, 0xa4, 0xc3, 0x3b, 0x7a, 0x30, 0x39, 0xc0,
     0x2d, 0x66, 0xc4, 0xf9, 0x51, 0x42, 0xa4, 0x6c, 0x18, 0x7f, 0x9a, 0xb4, 0x9a, 0xf0, 0x8e, 0xc6,
     0xcf, 0xfa, 0xa6, 0xb7, 0x1c, 0x9a, 0xb7, 0xb4, 0x0a, 0xf2, 0x1f, 0x66, 0xc2, 0xbe, 0xc6, 0xb6,
     0xbf, 0x71, 0xc5, 0x72, 0x36, 0x90, 0x4f, 0x35, 0xfa, 0x68, 0x40, 0x7a, 0x46, 0x64, 0x7d, 0x6e},
    {0xf4, 0xc7, 0x0e, 0x16, 0xee, 0xaa, 0xc5, 0xec, 0x51, 0xac, 0x86, 0xfe, 0xbf, 0x24, 0x09, 0x54,
     0x39, 0x9e, 0xc6, 0xc7, 0xe6, 0xbf, 0x87, 0xc9, 0xd3, 0x47, 0x3e, 0x33, 0x19, 0x7a, 0x93, 0xc9,
     0x09, 0x92, 0xab, 0xc5, 0x2d, 0x82, 0x2c, 0x37, 0x06, 0x47, 0x69, 0x83, 0x28, 0x4a, 0x05, 0x04,
     0x35, 0x17, 0x45, 0x4c, 0xa2, 0x3c, 0x4a, 0xf3, 0x88, 0x86, 0x56, 0x4d, 0x3a, 0x14, 0xd4, 0x93},
    {0x9b, 0x1f, 0x5b, 0x42, 0x4d, 0x93, 0xc9, 0xa7, 0x03, 0xe7, 0xaa, 0x02, 0x0c, 0x6e, 0x41, 0x41,
     0x4e, 0xb7, 0xf8, 0x71, 0x9c, 0x36, 0xde, 0x1e, 0x89, 0xb4, 0x44, 0x3b, 0x4d, 0xdb, 0xc4, 0x9a,
     0xf4, 0x89, 0x2b, 0xcb, 0x92, 0x9b, 0x06, 0x90, 0x69, 0xd1, 0x8d, 0x2b, 0xd1, 0xa5, 0xc4, 0x2f,
     0x36, 0xac, 0xc2, 0x35, 0x59, 0x51, 0xa8, 0xd9, 0xa4, 0x7f, 0x0d, 0xd4, 0xbf, 0x02, 0xe7, 0x1e},
    {0x37, 0x8f, 0x5a, 0x54, 0x16, 0x31, 0x22, 0x9b, 0x94, 0x4c, 0x9a, 0xd8, 0xec, 0x16, 0x5f, 0xde,
     0x3a, 0x7d, 0x3a, 0x1b, 0x25, 0x89, 0x42, 0x24, 0x3c, 0xd9, 0x55, 0xb7, 0xe0, 0x0d, 0x09, 0x84,
     0x80, 0x0a, 0x44, 0x0b, 0xdb, 0xb2, 0xce, 0xb1, 0x7b, 0x2b, 0x8a, 0x9a, 0xa6, 0x07, 0x9c, 0x54,
     0x0e, 0x38, 0xdc, 0x92, 0xcb, 0x1f, 0x2a, 0x60, 0x72, 0x61, 0x44, 0x51, 0x83, 0x23, 0x5a, 0xdb},
    {0xab, 0xbe, 0xde, 0xa6, 0x80, 0x05, 0x6f, 0x52, 0x38, 0x2a, 0xe5, 0x48, 0xb2, 0xe4, 0xf3, 0xf3,
     0x89, 0x41, 0xe7, 0x1c, 0xff, 0x8a, 0x78, 0xdb, 0x1f, 0xff, 0xe1, 0x8a, 0x1b, 0x33, 0x61, 0x03,
     0x9f, 0xe7, 0x67, 0x02, 0xaf, 0x69, 0x33, 0x4b, 0x7a, 0x1e, 0x6c, 0x30, 0x3b, 0x76, 0x52, 0xf4,
     0x36, 0x98, 0xfa, 0xd1, 0x15, 0x3b, 0xb6, 0xc3, 0x74, 0xb4, 0xc7, 0xfb, 0x98, 0x45, 0x9c, 0xed},
    {0x7b, 0xcd, 0x9e, 0xd0, 0xef, 0xc8, 0x89, 0xfb, 0x30, 0x02, 0xc6, 0xcd, 0x63, 0x5a, 0xfe, 0x94,
     0xd8, 0xfa, 0x6b, 0xbb, 0xeb, 0xab, 0x07, 0x61, 0x20, 0x01, 0x80, 0x21, 0x14, 0x84, 0x66, 0x79,
     0x8a, 0x1d, 0x71, 0xef, 0xea, 0x48, 0xb9, 0xca, 0xef, 0xba, 0xcd, 0x1d, 0x7d, 0x47, 0x6e, 0x98,
     0xde, 0xa2, 0x59, 0x4a, 0xc0, 0x6f, 0xd8, 0x5d, 0x6b, 0xca, 0xa4, 0xcd, 0x81, 0xf3, 0x2d, 0x1b},
    {0x37, 0x8e, 0xe7, 0x67, 0xf1, 0x16, 0x31, 0xba, 0xd2, 0x13, 0x80, 0xb0, 0x04, 0x49, 0xb1, 0x7a,
     0xcd, 0xa4, 0x3c, 0x32, 0xbc, 0xdf, 0x1d, 0x77, 0xf8, 0x20, 0x12, 0xd4, 0x30, 0x21, 0x9f, 0x9b,
     0x5d, 0x80, 0xef, 0x9d, 0x18, 0x91, 0xcc, 0x86, 0xe7, 0x1d, 0xa4, 0xaa, 0x88, 0xe1, 0x28, 0x52,
     0xfa, 0xf4, 0x17, 0xd5, 0xd9, 0xb2, 0x1b, 0x99, 0x48, 0xbc, 0x92, 0x4a, 0xf1, 0x1b, 0xd7, 0x20}};

static void scalar_s_transform(const uint8_t *state, uint8_t *out)
{
    for (int i = 0; i < 64; i++)
    {
        out[i] = STREEBOG_SBOX[state[i]];
    }
}

static void scalar_p_transform(const uint8_t *state, uint8_t *out)
{
    uint8_t temp[64];
    for (int i = 0; i < 64; i++)
    {
        temp[i] = state[TAU[i]];
    }
    memcpy(out, temp, 64);
}

static void scalar_xor_512(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    for (int i = 0; i < 64; i++)
    {
        out[i] = a[i] ^ b[i];
    }
}

/**
 * @brief Scalar key schedule function for Streebog (for testing)
 *
 * Computes: out = L(P(S(K ^ C[i])))
 *
 * @param K   Input key (64 bytes)
 * @param i   Iteration index (0..11)
 * @param out Output buffer (64 bytes)
 */
static void scalar_key_schedule(const uint8_t *K, int i, uint8_t *out)
{
    uint8_t temp[64];

    scalar_xor_512(K, C[i], temp);

    scalar_s_transform(temp, temp);

    scalar_p_transform(temp, temp);

    scalar_l_transform(temp, out);
}

TEST(FastStreebog, TestKeyScheduleChained)
{
    std::vector<uint8_t> K(64);
    std::vector<uint8_t> temp(64);
    std::vector<uint8_t> out_asm_chained(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        K[i] = static_cast<uint8_t>(i);
    }

    int iter = 0;

    STREEBOG_NAMESPACE(xor_512)(K.data(), C[iter], temp.data());

    STREEBOG_NAMESPACE(s_transform)(temp.data(), temp.data());

    STREEBOG_NAMESPACE(p_transform)(temp.data(), temp.data());

    STREEBOG_NAMESPACE(l_transform)(temp.data(), out_asm_chained.data());

    scalar_key_schedule(K.data(), iter, out_scalar.data());

    EXPECT_EQ(out_asm_chained, out_scalar) << "Chained ASM key schedule mismatch";
}

TEST(FastStreebog, TestKeyScheduleStepByStep)
{
    std::vector<uint8_t> K(64);
    std::vector<uint8_t> asm_temp(64);
    std::vector<uint8_t> scalar_temp(64);

    for (int i = 0; i < 64; i++)
    {
        K[i] = static_cast<uint8_t>(i);
    }

    int iter = 0;

    STREEBOG_NAMESPACE(xor_512)(K.data(), C[iter], asm_temp.data());
    scalar_xor_512(K.data(), C[iter], scalar_temp.data());
    EXPECT_EQ(asm_temp, scalar_temp) << "Step 1 (XOR) mismatch";

    STREEBOG_NAMESPACE(s_transform)(asm_temp.data(), asm_temp.data());
    scalar_s_transform(scalar_temp.data(), scalar_temp.data());
    EXPECT_EQ(asm_temp, scalar_temp) << "Step 2 (S) mismatch";

    STREEBOG_NAMESPACE(p_transform)(asm_temp.data(), asm_temp.data());
    scalar_p_transform(scalar_temp.data(), scalar_temp.data());
    EXPECT_EQ(asm_temp, scalar_temp) << "Step 3 (P) mismatch";

    std::vector<uint8_t> asm_out(64);
    std::vector<uint8_t> scalar_out(64);
    STREEBOG_NAMESPACE(l_transform)(asm_temp.data(), asm_out.data());
    scalar_l_transform(scalar_temp.data(), scalar_out.data());
    EXPECT_EQ(asm_out, scalar_out) << "Step 4 (L) mismatch";
}

TEST(FastStreebog, TestPTransformAfterS)
{
    std::vector<uint8_t> state(64);
    std::vector<uint8_t> asm_result(64);
    std::vector<uint8_t> scalar_result(64);

    for (int i = 0; i < 64; i++)
    {
        state[i] = static_cast<uint8_t>((i * 37 + 13) % 256);
    }

    std::vector<uint8_t> asm_temp(state);
    std::vector<uint8_t> scalar_temp(state);

    STREEBOG_NAMESPACE(s_transform)(asm_temp.data(), asm_temp.data());
    scalar_s_transform(scalar_temp.data(), scalar_temp.data());

    ASSERT_EQ(asm_temp, scalar_temp) << "S-transform results differ";

    STREEBOG_NAMESPACE(p_transform)(asm_temp.data(), asm_result.data());
    scalar_p_transform(scalar_temp.data(), scalar_result.data());

    EXPECT_EQ(asm_result, scalar_result) << "P-transform after S-transform differs";
}

TEST(FastStreebog, TestKeyScheduleAsm)
{
    std::vector<uint8_t> K(64);
    std::vector<uint8_t> out_asm(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        K[i] = static_cast<uint8_t>(i);
    }

    for (int iter = 0; iter < 12; iter++)
    {
        scalar_key_schedule(K.data(), iter, out_scalar.data());
        STREEBOG_NAMESPACE(key_schedule)(K.data(), iter, out_asm.data());

        EXPECT_EQ(out_asm, out_scalar) << "KeySchedule mismatch at iteration " << iter;
    }
}

TEST(FastStreebog, TestKeyScheduleAsmZeroKey)
{
    std::vector<uint8_t> K(64, 0);
    std::vector<uint8_t> out_asm(64);
    std::vector<uint8_t> out_scalar(64);

    for (int iter = 0; iter < 12; iter++)
    {
        scalar_key_schedule(K.data(), iter, out_scalar.data());
        STREEBOG_NAMESPACE(key_schedule)(K.data(), iter, out_asm.data());

        EXPECT_EQ(out_asm, out_scalar) << "KeySchedule (zero key) mismatch at iteration " << iter;
    }
}

TEST(FastStreebog, TestKeyScheduleAsmRandom)
{
    std::vector<uint8_t> K(64);
    std::vector<uint8_t> out_asm(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        K[i] = static_cast<uint8_t>((i * 37 + 13) % 256);
    }

    for (int iter = 0; iter < 12; iter++)
    {
        scalar_key_schedule(K.data(), iter, out_scalar.data());
        STREEBOG_NAMESPACE(key_schedule)(K.data(), iter, out_asm.data());

        EXPECT_EQ(out_asm, out_scalar) << "KeySchedule (random) mismatch at iteration " << iter;
    }
};

static void scalar_e_transform(const uint8_t *K, const uint8_t *m, uint8_t *out)
{
    uint8_t state[64];
    uint8_t key[64];

    scalar_xor_512(K, m, state);

    memcpy(key, K, 64);

    for (int i = 0; i < 12; i++)
    {

        scalar_s_transform(state, state);

        scalar_p_transform(state, state);

        scalar_l_transform(state, state);

        scalar_key_schedule(key, i, key);

        scalar_xor_512(state, key, state);
    }

    memcpy(out, state, 64);
}

TEST(FastStreebog, TestETransform)
{
    std::vector<uint8_t> K(64);
    std::vector<uint8_t> m(64);
    std::vector<uint8_t> out_c(64);
    std::vector<uint8_t> out_scalar(64);

    for (int i = 0; i < 64; i++)
    {
        K[i] = static_cast<uint8_t>(i);
        m[i] = static_cast<uint8_t>(64 + i);
    }

    scalar_e_transform(K.data(), m.data(), out_scalar.data());
    STREEBOG_NAMESPACE(e_transform)(K.data(), m.data(), out_c.data());

    EXPECT_EQ(out_c, out_scalar) << "E transform mismatch";
}

TEST(FastStreebog, TestETransformZero)
{
    std::vector<uint8_t> K(64, 0);
    std::vector<uint8_t> m(64, 0);
    std::vector<uint8_t> out_c(64);
    std::vector<uint8_t> out_scalar(64);

    scalar_e_transform(K.data(), m.data(), out_scalar.data());
    STREEBOG_NAMESPACE(e_transform)(K.data(), m.data(), out_c.data());

    EXPECT_EQ(out_c, out_scalar) << "E transform (zero) mismatch";
}

TEST(FastStreebog, TestETransformRandom)
{
    std::vector<uint8_t> K(64);
    std::vector<uint8_t> m(64);
    std::vector<uint8_t> out_c(64);
    std::vector<uint8_t> out_scalar(64);

    for (int test = 0; test < 10; test++)
    {
        for (int i = 0; i < 64; i++)
        {
            K[i] = static_cast<uint8_t>((i * 17 + test * 31 + 7) % 256);
            m[i] = static_cast<uint8_t>((i * 23 + test * 41 + 13) % 256);
        }

        scalar_e_transform(K.data(), m.data(), out_scalar.data());
        STREEBOG_NAMESPACE(e_transform)(K.data(), m.data(), out_c.data());

        EXPECT_EQ(out_c, out_scalar) << "E transform (random " << test << ") mismatch";
    }
}

TEST(FastStreebog, TestHash512_M1)
{

    const char *M1 = "012345678901234567890123456789012345678901234567890123456789012";
    size_t M1_len = 63;

    const uint8_t expected_512[] = {0x1b, 0x54, 0xd0, 0x1a, 0x4a, 0xf5, 0xb9, 0xd5, 0xcc, 0x3d, 0x86, 0xd6, 0x8d,
                                    0x28, 0x54, 0x62, 0xb1, 0x9a, 0xbc, 0x24, 0x75, 0x22, 0x2f, 0x35, 0xc0, 0x85,
                                    0x12, 0x2b, 0xe4, 0xba, 0x1f, 0xfa, 0x00, 0xad, 0x30, 0xf8, 0x76, 0x7b, 0x3a,
                                    0x82, 0x38, 0x4c, 0x65, 0x74, 0xf0, 0x24, 0xc3, 0x11, 0xe2, 0xa4, 0x81, 0x33,
                                    0x2b, 0x08, 0xef, 0x7f, 0x41, 0x79, 0x78, 0x91, 0xc1, 0x64, 0x6f, 0x48};

    std::vector<uint8_t> hash(64);
    STREEBOG_NAMESPACE(hash_512)((const uint8_t *)M1, M1_len, hash.data());

    std::cout << "Got hash: ";
    for (int i = 0; i < 64; i++)
    {
        printf("%02x", hash[i]);
    }
    std::cout << std::endl;

    std::cout << "Expected: ";
    for (int i = 0; i < 64; i++)
    {
        printf("%02x", expected_512[i]);
    }
    std::cout << std::endl;

    EXPECT_EQ(memcmp(hash.data(), expected_512, 64), 0) << "512-bit hash of M1 mismatch";
}

TEST(FastStreebog, TestHash256_Empty)
{
    uint8_t empty = 0;

    const uint8_t expected_256[] = {0x3f, 0x53, 0x9a, 0x21, 0x3e, 0x97, 0xc8, 0x02, 0xcc, 0x22, 0x9d,
                                    0x47, 0x4c, 0x6a, 0xa3, 0x2a, 0x82, 0x5a, 0x36, 0x0b, 0x2a, 0x93,
                                    0x3a, 0x94, 0x9f, 0xd9, 0x25, 0x20, 0x8d, 0x9c, 0xe1, 0xbb};

    std::vector<uint8_t> hash(32);
    STREEBOG_NAMESPACE(hash_256)(&empty, 0, hash.data());

    EXPECT_EQ(memcmp(hash.data(), expected_256, 32), 0) << "256-bit hash of empty string mismatch";
}

TEST(FastStreebog, TestHash512_QuickBrownFox)
{
    std::string msg = "The quick brown fox jumps over the lazy dog";

    const uint8_t expected_512[] = {0xd2, 0xb7, 0x93, 0xa0, 0xbb, 0x6c, 0xb5, 0x90, 0x48, 0x28, 0xb5, 0xb6, 0xdc,
                                    0xfb, 0x44, 0x3b, 0xb8, 0xf3, 0x3e, 0xfc, 0x06, 0xad, 0x09, 0x36, 0x88, 0x78,
                                    0xae, 0x4c, 0xdc, 0x82, 0x45, 0xb9, 0x7e, 0x60, 0x80, 0x24, 0x69, 0xbe, 0xd1,
                                    0xe7, 0xc2, 0x1a, 0x64, 0xff, 0x0b, 0x17, 0x9a, 0x6a, 0x1e, 0x0b, 0xb7, 0x4d,
                                    0x92, 0x96, 0x54, 0x50, 0xa0, 0xad, 0xab, 0x69, 0x16, 0x2c, 0x00, 0xfe};

    std::vector<uint8_t> hash(64);
    STREEBOG_NAMESPACE(hash_512)((const uint8_t *)msg.data(), msg.size(), hash.data());

    EXPECT_EQ(memcmp(hash.data(), expected_512, 64), 0) << "512-bit hash of quick brown fox mismatch";
}

TEST(FastStreebog, TestHash256_QuickBrownFox)
{
    std::string msg = "The quick brown fox jumps over the lazy dog";

    const uint8_t expected_256[] = {0x3e, 0x7d, 0xea, 0x7f, 0x23, 0x84, 0xb6, 0xc5, 0xa3, 0xd0, 0xe2,
                                    0x4a, 0xaa, 0x29, 0xc0, 0x5e, 0x89, 0xdd, 0xd7, 0x62, 0x14, 0x50,
                                    0x30, 0xec, 0x22, 0xc7, 0x1a, 0x6d, 0xb8, 0xb2, 0xc1, 0xf4};

    std::vector<uint8_t> hash(32);
    STREEBOG_NAMESPACE(hash_256)((const uint8_t *)msg.data(), msg.size(), hash.data());

    EXPECT_EQ(memcmp(hash.data(), expected_256, 32), 0) << "256-bit hash of quick brown fox mismatch";
}

TEST(FastStreebog, TestHash512_QuickBrownFoxWithDot)
{
    std::string msg = "The quick brown fox jumps over the lazy dog.";

    const uint8_t expected_512[] = {0xfe, 0x0c, 0x42, 0xf2, 0x67, 0xd9, 0x21, 0xf9, 0x40, 0xfa, 0xa7, 0x2b, 0xd9,
                                    0xfc, 0xf8, 0x4f, 0x9f, 0x1b, 0xd7, 0xe9, 0xd0, 0x55, 0xe9, 0x81, 0x6e, 0x4c,
                                    0x2a, 0xce, 0x1e, 0xc8, 0x3b, 0xe8, 0x2d, 0x29, 0x57, 0xcd, 0x59, 0xb8, 0x6e,
                                    0x12, 0x3d, 0x8f, 0x5a, 0xde, 0xe8, 0x0b, 0x3c, 0xa0, 0x8a, 0x01, 0x75, 0x99,
                                    0xa9, 0xfc, 0x1a, 0x14, 0xd9, 0x40, 0xcf, 0x87, 0xc7, 0x7d, 0xf0, 0x70};

    std::vector<uint8_t> hash(64);
    STREEBOG_NAMESPACE(hash_512)((const uint8_t *)msg.data(), msg.size(), hash.data());

    EXPECT_EQ(memcmp(hash.data(), expected_512, 64), 0) << "512-bit hash of quick brown fox with dot mismatch";
}

TEST(FastStreebog, TestHash256_QuickBrownFoxWithDot)
{
    std::string msg = "The quick brown fox jumps over the lazy dog.";

    const uint8_t expected_256[] = {0x36, 0x81, 0x6a, 0x82, 0x4d, 0xcb, 0xe7, 0xd6, 0x17, 0x1a, 0xa5,
                                    0x85, 0x00, 0x74, 0x1f, 0x2e, 0xa2, 0x75, 0x7a, 0xe2, 0xe1, 0x78,
                                    0x4a, 0xb7, 0x2c, 0x5c, 0x3c, 0x6c, 0x19, 0x8d, 0x71, 0xda};

    std::vector<uint8_t> hash(32);
    STREEBOG_NAMESPACE(hash_256)((const uint8_t *)msg.data(), msg.size(), hash.data());

    EXPECT_EQ(memcmp(hash.data(), expected_256, 32), 0) << "256-bit hash of quick brown fox with dot mismatch";
}

TEST(FastStreebog, TestHash512_Empty)
{
    std::vector<uint8_t> hash(64);
    uint8_t empty = 0;
    STREEBOG_NAMESPACE(hash_512)(&empty, 0, hash.data());

    const uint8_t expected_512[] = {0x8e, 0x94, 0x5d, 0xa2, 0x09, 0xaa, 0x86, 0x9f, 0x04, 0x55, 0x92, 0x85, 0x29,
                                    0xbc, 0xae, 0x46, 0x79, 0xe9, 0x87, 0x3a, 0xb7, 0x07, 0xb5, 0x53, 0x15, 0xf5,
                                    0x6c, 0xeb, 0x98, 0xbe, 0xf0, 0xa7, 0x36, 0x2f, 0x71, 0x55, 0x28, 0x35, 0x6e,
                                    0xe8, 0x3c, 0xda, 0x5f, 0x2a, 0xac, 0x4c, 0x6a, 0xd2, 0xba, 0x3a, 0x71, 0x5c,
                                    0x1b, 0xcd, 0x81, 0xcb, 0x8e, 0x9f, 0x90, 0xbf, 0x4c, 0x1c, 0x1a, 0x8a};

    std::cout << "Got empty 512: ";
    for (int i = 0; i < 64; i++)
    {
        printf("%02x", hash[i]);
    }
    std::cout << std::endl;

    std::cout << "Expected:      ";
    for (int i = 0; i < 64; i++)
    {
        printf("%02x", expected_512[i]);
    }
    std::cout << std::endl;

    EXPECT_EQ(memcmp(hash.data(), expected_512, 64), 0) << "Empty message 512-bit hash mismatch";
}

TEST(FastStreebog, TestStreamingAPI)
{
    std::string M1 = "012345678901234567890123456789012345678901234567890123456789012";

    std::vector<uint8_t> hash_oneshot(64);
    STREEBOG_NAMESPACE(hash_512)((const uint8_t *)M1.data(), M1.size(), hash_oneshot.data());

    std::vector<uint8_t> hash_streaming(64);
    streebog_ctx ctx;
    STREEBOG_NAMESPACE(init_512)(&ctx);
    STREEBOG_NAMESPACE(update)(&ctx, (const uint8_t *)M1.data(), 20);
    STREEBOG_NAMESPACE(update)(&ctx, (const uint8_t *)M1.data() + 20, 30);
    STREEBOG_NAMESPACE(update)(&ctx, (const uint8_t *)M1.data() + 50, 13);
    STREEBOG_NAMESPACE(final)(&ctx, hash_streaming.data());

    EXPECT_EQ(hash_oneshot, hash_streaming) << "Chunked streaming API mismatch";
}

TEST(FastStreebog, TestStreamingAPI_QuickBrownFox)
{
    std::string msg = "The quick brown fox jumps over the lazy dog";

    std::vector<uint8_t> hash_oneshot(64);
    STREEBOG_NAMESPACE(hash_512)((const uint8_t *)msg.data(), msg.size(), hash_oneshot.data());

    std::vector<uint8_t> hash_streaming(64);
    streebog_ctx ctx;
    STREEBOG_NAMESPACE(init_512)(&ctx);
    for (size_t i = 0; i < msg.size(); i++)
    {
        STREEBOG_NAMESPACE(update)(&ctx, (const uint8_t *)&msg[i], 1);
    }
    STREEBOG_NAMESPACE(final)(&ctx, hash_streaming.data());

    EXPECT_EQ(hash_oneshot, hash_streaming) << "Byte-by-byte streaming mismatch";
}

TEST(FastStreebog, TestHash256_TestWOW)
{
    std::string msg = "Test test Test Test WOWOWOWOWOWOWOWOWOW";

    std::vector<uint8_t> hash(32);
    STREEBOG_NAMESPACE(hash_256)((const uint8_t *)msg.data(), msg.size(), hash.data());

    // Expected: ebaf1800aec2524befcf447f2a2438e2bc31616259949365480c7644a7ff648d
    const uint8_t expected_256[] = {0xeb, 0xaf, 0x18, 0x00, 0xae, 0xc2, 0x52, 0x4b, 0xef, 0xcf, 0x44,
                                    0x7f, 0x2a, 0x24, 0x38, 0xe2, 0xbc, 0x31, 0x61, 0x62, 0x59, 0x94,
                                    0x93, 0x65, 0x48, 0x0c, 0x76, 0x44, 0xa7, 0xff, 0x64, 0x8d};

    std::cout << "Got TestWOW 256: ";
    for (int i = 0; i < 32; i++)
    {
        printf("%02x", hash[i]);
    }
    std::cout << std::endl;

    EXPECT_EQ(memcmp(hash.data(), expected_256, 32), 0) << "TestWOW 256-bit hash mismatch";
}

TEST(FastStreebog, TestHash512_TestWOW)
{
    std::string msg = "Test test Test Test WOWOWOWOWOWOWOWOWOW";

    std::vector<uint8_t> hash(64);
    STREEBOG_NAMESPACE(hash_512)((const uint8_t *)msg.data(), msg.size(), hash.data());

    // Expected:
    // a6df435f6258531b759b405437be0f7300e23a8d1eefcdc3abc5da180c4def8ec6ed5a092f9c7363824c17f1ecabc97876af8f3c1a75df948f6ad680e16b4172
    const uint8_t expected_512[] = {0xa6, 0xdf, 0x43, 0x5f, 0x62, 0x58, 0x53, 0x1b, 0x75, 0x9b, 0x40, 0x54, 0x37,
                                    0xbe, 0x0f, 0x73, 0x00, 0xe2, 0x3a, 0x8d, 0x1e, 0xef, 0xcd, 0xc3, 0xab, 0xc5,
                                    0xda, 0x18, 0x0c, 0x4d, 0xef, 0x8e, 0xc6, 0xed, 0x5a, 0x09, 0x2f, 0x9c, 0x73,
                                    0x63, 0x82, 0x4c, 0x17, 0xf1, 0xec, 0xab, 0xc9, 0x78, 0x76, 0xaf, 0x8f, 0x3c,
                                    0x1a, 0x75, 0xdf, 0x94, 0x8f, 0x6a, 0xd6, 0x80, 0xe1, 0x6b, 0x41, 0x72};

    std::cout << "Got TestWOW 512: ";
    for (int i = 0; i < 64; i++)
    {
        printf("%02x", hash[i]);
    }
    std::cout << std::endl;

    EXPECT_EQ(memcmp(hash.data(), expected_512, 64), 0) << "TestWOW 512-bit hash mismatch";
}