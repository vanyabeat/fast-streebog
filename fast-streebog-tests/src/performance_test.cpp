#include "fast_streebog.h"
#include <array>
#include <chrono>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <gtest/gtest.h>
#include <iomanip>
#include <iostream>
#include <random>
#include <sstream>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#endif

class PerformanceTest : public ::testing::Test
{
  protected:
    std::vector<uint8_t> fileData;
    std::string testFilePath;

    void SetUp() override
    {
        // Generate random test data (1 MB)
        const size_t dataSize = 1 * 1024 * 1024;
        fileData.resize(dataSize);

        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<int> dist(0, 255);

        for (size_t i = 0; i < dataSize; ++i)
        {
            fileData[i] = static_cast<uint8_t>(dist(gen));
        }

        // Create temporary file for OpenSSL comparison
        testFilePath = "streebog_test_temp.bin";
        std::ofstream outFile(testFilePath, std::ios::binary);
        if (outFile.is_open())
        {
            outFile.write(reinterpret_cast<const char *>(fileData.data()), fileData.size());
            outFile.close();
        }

        std::cout << "\n[INFO] Generated random test data: " << fileData.size() << " bytes (" << std::fixed
                  << std::setprecision(2) << (fileData.size() / 1024.0 / 1024.0) << " MB)\n";
        std::cout << "[INFO] Temp file: " << testFilePath << "\n";
    }

    void TearDown() override
    {
        // Delete temporary file
        if (!testFilePath.empty())
        {
            std::remove(testFilePath.c_str());
            std::cout << "[INFO] Deleted temp file: " << testFilePath << "\n";
        }
    }

    // Run OpenSSL command and measure time
    double runOpenSSLBenchmark(const std::string &algorithm, int iterations = 3)
    {
        // Check if openssl is available
#ifdef _WIN32
        if (system("where openssl >nul 2>&1") != 0)
#else
        if (system("which openssl >/dev/null 2>&1") != 0)
#endif
        {
            std::cout << "[WARNING] OpenSSL not found in PATH\n";
            return -1.0;
        }

        double totalMs = 0.0;
#ifdef _WIN32
        std::string command = "openssl dgst -" + algorithm + " \"" + testFilePath + "\" >nul 2>&1";
#else
        std::string command = "openssl dgst -" + algorithm + " \"" + testFilePath + "\" >/dev/null 2>&1";
#endif

        for (int i = 0; i < iterations; ++i)
        {
            auto start = std::chrono::high_resolution_clock::now();
            system(command.c_str());
            auto end = std::chrono::high_resolution_clock::now();

            totalMs += std::chrono::duration<double, std::milli>(end - start).count();
        }

        return totalMs / iterations;
    }
};

// One-shot hash performance test (DISABLED - takes too long)
TEST_F(PerformanceTest, Streebog512_OneShot)
{
    if (fileData.empty())
    {
        GTEST_SKIP() << "No test data available";
    }

    const int iterations = 3;
    uint8_t hash[64];

    auto start = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < iterations; ++i)
    {
        streebog_hash_512(fileData.data(), fileData.size(), hash);
    }

    auto end = std::chrono::high_resolution_clock::now();
    double totalMs = std::chrono::duration<double, std::milli>(end - start).count();
    double avgMs = totalMs / iterations;
    double throughputMBs = (fileData.size() * iterations / 1024.0 / 1024.0) / (totalMs / 1000.0);

    // Print hash for verification
    char hashHex[129];
    streebog_bytes_to_hex(hash, 64, hashHex);

    std::cout << "\n============================================\n";
    std::cout << "Streebog-512 One-Shot Performance\n";
    std::cout << "============================================\n";
    std::cout << "Data size:     " << fileData.size() << " bytes\n";
    std::cout << "Iterations:    " << iterations << "\n";
    std::cout << "Total time:    " << std::fixed << std::setprecision(2) << totalMs << " ms\n";
    std::cout << "Avg time:      " << std::fixed << std::setprecision(4) << avgMs << " ms\n";
    std::cout << "Throughput:    " << std::fixed << std::setprecision(2) << throughputMBs << " MB/s\n";
    std::cout << "Hash:          " << hashHex << "\n";
    std::cout << "============================================\n";

    EXPECT_GT(throughputMBs, 0);
}

// Streaming/chunked hash performance test
TEST_F(PerformanceTest, Streebog512_Chunked)
{
    if (fileData.empty())
    {
        GTEST_SKIP() << "No test data available";
    }

    const int iterations = 3;
    const std::array<size_t, 5> chunkSizes = {64, 256, 1024, 4096, 16384};

    std::cout << "\n============================================\n";
    std::cout << "Streebog-512 Chunked Performance\n";
    std::cout << "============================================\n";
    std::cout << "Data size:     " << fileData.size() << " bytes\n";
    std::cout << "Iterations:    " << iterations << "\n";
    std::cout << "--------------------------------------------\n";
    std::cout << std::setw(12) << "Chunk Size" << std::setw(15) << "Avg Time (ms)" << std::setw(18)
              << "Throughput (MB/s)" << "\n";
    std::cout << "--------------------------------------------\n";

    for (size_t chunkSize : chunkSizes)
    {
        uint8_t hash[64];

        auto start = std::chrono::high_resolution_clock::now();

        for (int i = 0; i < iterations; ++i)
        {
            streebog_ctx ctx;
            streebog_init_512(&ctx);

            size_t offset = 0;
            while (offset < fileData.size())
            {
                size_t remaining = fileData.size() - offset;
                size_t toProcess = (remaining < chunkSize) ? remaining : chunkSize;
                streebog_update(&ctx, fileData.data() + offset, toProcess);
                offset += toProcess;
            }

            streebog_final(&ctx, hash);
        }

        auto end = std::chrono::high_resolution_clock::now();
        double totalMs = std::chrono::duration<double, std::milli>(end - start).count();
        double avgMs = totalMs / iterations;
        double throughputMBs = (fileData.size() * iterations / 1024.0 / 1024.0) / (totalMs / 1000.0);

        std::cout << std::setw(12) << chunkSize << std::setw(15) << std::fixed << std::setprecision(4) << avgMs
                  << std::setw(18) << std::fixed << std::setprecision(2) << throughputMBs << "\n";
    }

    std::cout << "============================================\n";

    SUCCEED();
}

// Comparison with OpenSSL SHA3-512
TEST_F(PerformanceTest, CompareWithOpenSSL)
{
    if (fileData.empty())
    {
        GTEST_SKIP() << "No test data available";
    }

    const int iterations = 3;
    uint8_t hash[64];
    char hashHex[129];

    // Streebog-512 benchmark
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < iterations; ++i)
    {
        streebog_hash_512(fileData.data(), fileData.size(), hash);
    }
    auto end = std::chrono::high_resolution_clock::now();
    double streebogMs = std::chrono::duration<double, std::milli>(end - start).count() / iterations;
    double streebogThroughput = (fileData.size() / 1024.0 / 1024.0) / (streebogMs / 1000.0);

    streebog_bytes_to_hex(hash, 64, hashHex);

    std::cout << "\n============================================\n";
    std::cout << "Performance Comparison\n";
    std::cout << "============================================\n";
    std::cout << "Data size:     " << fileData.size() << " bytes\n";
    std::cout << "Iterations:    " << iterations << "\n";
    std::cout << "--------------------------------------------\n";

    std::cout << "\nStreebog-512 (this library):\n";
    std::cout << "  Avg time:    " << std::fixed << std::setprecision(4) << streebogMs << " ms\n";
    std::cout << "  Throughput:  " << std::fixed << std::setprecision(2) << streebogThroughput << " MB/s\n";
    std::cout << "  Hash:        " << hashHex << "\n";

    // OpenSSL SHA3-512 benchmark (for comparison - different algorithm but similar security level)
    double opensslSha3Ms = runOpenSSLBenchmark("sha3-512", iterations);
    if (opensslSha3Ms > 0)
    {
        double opensslThroughput = (fileData.size() / 1024.0 / 1024.0) / (opensslSha3Ms / 1000.0);
        std::cout << "\nOpenSSL SHA3-512 (via process):\n";
        std::cout << "  Avg time:    " << std::fixed << std::setprecision(4) << opensslSha3Ms << " ms\n";
        std::cout << "  Throughput:  " << std::fixed << std::setprecision(2) << opensslThroughput << " MB/s\n";
        std::cout << "  Note: Includes process spawn overhead\n";

        if (streebogMs < opensslSha3Ms)
        {
            std::cout << "\n  >> Streebog is " << std::fixed << std::setprecision(1) << (opensslSha3Ms / streebogMs)
                      << "x faster\n";
        }
    }

    // OpenSSL SHA-512 benchmark
    double opensslSha512Ms = runOpenSSLBenchmark("sha512", iterations);
    if (opensslSha512Ms > 0)
    {
        double opensslThroughput = (fileData.size() / 1024.0 / 1024.0) / (opensslSha512Ms / 1000.0);
        std::cout << "\nOpenSSL SHA-512 (via process):\n";
        std::cout << "  Avg time:    " << std::fixed << std::setprecision(4) << opensslSha512Ms << " ms\n";
        std::cout << "  Throughput:  " << std::fixed << std::setprecision(2) << opensslThroughput << " MB/s\n";
        std::cout << "  Note: Includes process spawn overhead\n";
    }

    std::cout << "\n============================================\n";
    std::cout << "Note: OpenSSL times include process spawn overhead.\n";
    std::cout << "For fair comparison, use OpenSSL as a library.\n";
    std::cout << "============================================\n";

    SUCCEED();
}

// Test 256-bit variant performance (DISABLED - takes too long)
TEST_F(PerformanceTest, Streebog256_OneShot)
{
    if (fileData.empty())
    {
        GTEST_SKIP() << "No test data available";
    }

    const int iterations = 3;
    uint8_t hash[32];

    auto start = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < iterations; ++i)
    {
        streebog_hash_256(fileData.data(), fileData.size(), hash);
    }

    auto end = std::chrono::high_resolution_clock::now();
    double totalMs = std::chrono::duration<double, std::milli>(end - start).count();
    double avgMs = totalMs / iterations;
    double throughputMBs = (fileData.size() * iterations / 1024.0 / 1024.0) / (totalMs / 1000.0);

    char hashHex[65];
    streebog_bytes_to_hex(hash, 32, hashHex);

    std::cout << "\n============================================\n";
    std::cout << "Streebog-256 One-Shot Performance\n";
    std::cout << "============================================\n";
    std::cout << "Data size:     " << fileData.size() << " bytes\n";
    std::cout << "Iterations:    " << iterations << "\n";
    std::cout << "Total time:    " << std::fixed << std::setprecision(2) << totalMs << " ms\n";
    std::cout << "Avg time:      " << std::fixed << std::setprecision(4) << avgMs << " ms\n";
    std::cout << "Throughput:    " << std::fixed << std::setprecision(2) << throughputMBs << " MB/s\n";
    std::cout << "Hash:          " << hashHex << "\n";
    std::cout << "============================================\n";

    EXPECT_GT(throughputMBs, 0);
}

// Large data performance test
TEST_F(PerformanceTest, Streebog512_LargeData)
{
    // Generate 10MB of data
    const size_t dataSize = 10 * 1024 * 1024;
    std::vector<uint8_t> largeData(dataSize);
    for (size_t i = 0; i < dataSize; ++i)
    {
        largeData[i] = static_cast<uint8_t>(i % 256);
    }

    const int iterations = 3;
    uint8_t hash[64];

    auto start = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < iterations; ++i)
    {
        streebog_hash_512(largeData.data(), largeData.size(), hash);
    }

    auto end = std::chrono::high_resolution_clock::now();
    double totalMs = std::chrono::duration<double, std::milli>(end - start).count();
    double avgMs = totalMs / iterations;
    double throughputMBs = (dataSize * iterations / 1024.0 / 1024.0) / (totalMs / 1000.0);

    char hashHex[129];
    streebog_bytes_to_hex(hash, 64, hashHex);

    std::cout << "\n============================================\n";
    std::cout << "Streebog-512 Large Data Performance\n";
    std::cout << "============================================\n";
    std::cout << "Data size:     " << (dataSize / 1024 / 1024) << " MB\n";
    std::cout << "Iterations:    " << iterations << "\n";
    std::cout << "Total time:    " << std::fixed << std::setprecision(2) << totalMs << " ms\n";
    std::cout << "Avg time:      " << std::fixed << std::setprecision(2) << avgMs << " ms\n";
    std::cout << "Throughput:    " << std::fixed << std::setprecision(2) << throughputMBs << " MB/s\n";
    std::cout << "Hash:          " << hashHex << "\n";
    std::cout << "============================================\n";

    EXPECT_GT(throughputMBs, 0);
}

// Version check
TEST_F(PerformanceTest, VersionCheck)
{
    const char *version = streebog_version();
    std::cout << "\n============================================\n";
    std::cout << "Library Version: " << version << "\n";
    std::cout << "============================================\n";

    EXPECT_NE(version, nullptr);
    EXPECT_STRNE(version, "");
}
