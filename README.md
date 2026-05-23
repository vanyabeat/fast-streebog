# Fast Assembly GOST R 34.11-2012 STREEBOG HASH FUNCTION
 
High-performance implementation of the GOST R 34.11-2012 (Streebog) cryptographic hash function with platform-specific assembly optimizations.

## Overview

Fast Streebog is an optimized library implementing the Russian national standard hash function Streebog (GOST R 34.11-2012). It provides both 256-bit and 512-bit hash outputs.

## Supported Platforms

| Platform | Architecture | ASM Optimizations |
|----------|--------------|-------------------|
| ✅ Windows | x64 | AVX-512, AVX2, SSSE3, SSE2 MASM |
| ✅ macOS | ARM64 (Apple Silicon) | NEON GAS |
| ✅ Linux | ARM64 | NEON GAS |
| ✅ Linux | x64 | AVX2, SSSE3 GAS |
| ✅ All platforms | Any | Pure C fallback |

## Features

- **High Performance**: Core transformations implemented in platform-specific assembly
  - **Windows x64**: AVX-512, AVX2, SSSE3, SSE2 MASM optimizations with runtime dispatch
  - **Linux x64**: AVX2 and SSSE3 GAS optimizations
  - **ARM64 (macOS/Linux)**: NEON SIMD optimizations
- **Dual Output**: Support for both 256-bit and 512-bit hash variants
- **Streaming API**: Process data in chunks with init/update/final pattern
- **One-shot API**: Simple single-call hashing for complete data
- **Hex Output**: Built-in conversion to hexadecimal strings
- **Cross-platform**: Works on Windows, macOS, and Linux

## Performance

### ARM64 (Apple Silicon M1/M2/M3)

Performance comparison on 1 MB data (3 iterations average):

| Implementation | Throughput | Speedup |
|---------------|------------|---------|
| **Fast Streebog (ARM64 NEON ASM)** | **62 MB/s** | **1.44x** |
| Pure C Implementation | 43 MB/s | 1x |

**Key ARM64 optimizations:**
- NEON SIMD `tbl` instruction for P-transform (~10 instructions vs ~260 in C)
- Multi-register `ld1`/`st1`/`eor` for 512-bit XOR operations
- Unrolled S-transform with cached table pointers
- Jump-table based key schedule with inlined XOR

Tested on macOS ARM64 (Apple Silicon).

### Windows x64 (AVX-512)

Performance comparison on 1 MB data (3 iterations average):

| Implementation | Throughput | Speedup |
|---------------|------------|---------|
| **Fast Streebog (AVX-512 ASM)** | **97 MB/s** | **68x** |
| Pure C Implementation (unoptimized) | 1.43 MB/s | 1x |

**Key x64 optimizations:**
- Precalculated Ax[8][256] lookup tables (16 KB) for L-transform
- AVX-512, AVX2, SSSE3, and SSE2 assembly implementations of S, P, L, XOR, ADD, and KeySchedule primitives
- Runtime CPU feature detection and dispatch to the best available implementation
- Optimized L-transform: 8 table lookups instead of up to 64 bit-by-bit operations

Tested on Windows x64 with Visual Studio 2022 (MSVC 19.44).

### Linux x64 (AVX2 / SSSE3)

Linux x64 now uses GAS assembly with AVX2 and SSSE3 optimizations, matching the Windows x64 algorithmic approach with GCC/Clang-compatible syntax.

**Key Linux x64 optimizations:**
- Precalculated Ax[8][256] lookup tables for L-transform
- AVX2 and SSSE3 GAS implementations of S, P, L, XOR, ADD, and KeySchedule
- Compiled with `-x assembler-with-cpp` for full preprocessor support

## Requirements

### Windows x64
- CPU with SSE2 or newer (SSE2 minimum; AVX2/AVX-512 recommended for best performance)
- Visual Studio 2019 or later (for building from source)

### Linux x64
- CPU with SSSE3 or newer (AVX2 recommended)
- CMake 3.20+, GCC or Clang

### macOS/Linux ARM64
- Apple Silicon (M1/M2/M3) or ARMv8-A with NEON
- CMake 3.20+, Clang or GCC

## Installation

### Pre-built Libraries

Download from [Releases](https://github.com/vanyabeat/fast-streebog/releases):
- **Windows**: `streebog_windows.zip` - DLL, import library, and header
- **macOS/Linux**: Build from source (see below)

### Building from Source

#### Windows (Visual Studio)

```bash
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --target fast-streebog-dll
```

#### macOS/Linux (ARM64 with ASM optimizations)

```bash
cmake -B build -DUSE_ASM=ON
cmake --build build --config Release
```

#### Pure C (any platform, no ASM)

```bash
cmake -B build -DUSE_ASM=OFF
cmake --build build --config Release
```

The built files will be in the `streebog_release/` directory.

## Usage

### Quick Start

```c
#define STREEBOG_USE_DLL
#include "streebog.h"
#include <stdio.h>

int main() {
    const char *data = "Hello, Streebog!";
    char hash_hex[129];
    
    // Compute 512-bit hash
    streebog_hash_512_hex((const uint8_t*)data, strlen(data), hash_hex);
    printf("GOST 512: %s\n", hash_hex);
    
    // Compute 256-bit hash
    char hash256_hex[65];
    streebog_hash_256_hex((const uint8_t*)data, strlen(data), hash256_hex);
    printf("GOST 256: %s\n", hash256_hex);
    
    // Check library version
    printf("Version: %s\n", streebog_version());
    
    return 0;
}
```

### Streaming API

For large files or streaming data:

```c
#define STREEBOG_USE_DLL
#include "streebog.h"

void hash_file(FILE *f) {
    streebog_ctx ctx;
    uint8_t buffer[4096];
    uint8_t hash[64];
    char hash_hex[129];
    
    streebog_init_512(&ctx);
    
    size_t bytes_read;
    while ((bytes_read = fread(buffer, 1, sizeof(buffer), f)) > 0) {
        streebog_update(&ctx, buffer, bytes_read);
    }
    
    streebog_final(&ctx, hash);
    streebog_bytes_to_hex(hash, 64, hash_hex);
    
    printf("File hash: %s\n", hash_hex);
}
```

## API Reference

### One-shot Functions

| Function | Description |
|----------|-------------|
| `streebog_hash_512(data, len, out)` | Compute 512-bit hash (64 bytes output) |
| `streebog_hash_256(data, len, out)` | Compute 256-bit hash (32 bytes output) |
| `streebog_hash_512_hex(data, len, out)` | Compute 512-bit hash as hex string (129 bytes output) |
| `streebog_hash_256_hex(data, len, out)` | Compute 256-bit hash as hex string (65 bytes output) |

### Streaming Functions

| Function | Description |
|----------|-------------|
| `streebog_init_512(ctx)` | Initialize context for 512-bit hash |
| `streebog_init_256(ctx)` | Initialize context for 256-bit hash |
| `streebog_update(ctx, data, len)` | Add data to hash computation |
| `streebog_final(ctx, out)` | Finalize and get hash result |

### Utility Functions

| Function | Description |
|----------|-------------|
| `streebog_version()` | Get library version string |
| `streebog_bytes_to_hex(hash, len, out)` | Convert hash bytes to hex string |

## Linking

### Visual Studio

1. Add `streebog.h` to your include path
2. Link against `fast-streebog.lib`
3. Place `fast-streebog.dll` in your application directory
4. Define `STREEBOG_USE_DLL` before including the header

### CMake

```cmake
target_include_directories(your_app PRIVATE path/to/streebog)
target_link_libraries(your_app PRIVATE path/to/fast-streebog.lib)
target_compile_definitions(your_app PRIVATE STREEBOG_USE_DLL)
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## References

- [GOST R 34.11-2012](https://datatracker.ietf.org/doc/html/rfc6986.html) - Official standard document
- [RFC 6986](https://tools.ietf.org/html/rfc6986) - GOST R 34.11-2012: Hash Function

## Architecture

```
fast-streebog/
├── fast-streebog-lib/
│   ├── include/             # Public headers
│   ├── src/                 # C implementation
│   ├── unix_arm64/          # ARM64 NEON assembly (macOS/Linux)
│   ├── linux_x64_avx2/      # Linux x64 AVX2 GAS assembly
│   ├── linux_x64_ssse3/     # Linux x64 SSSE3 GAS assembly
│   ├── windows_x64_avx512/  # Windows x64 AVX-512 MASM assembly
│   ├── windows_x64_avx2/    # Windows x64 AVX2 MASM assembly
│   ├── windows_x64_ssse3/   # Windows x64 SSSE3 MASM assembly
│   └── windows_x64_sse2/    # Windows x64 SSE2 MASM assembly
├── fast-streebog-tests/     # GoogleTest unit tests
└── streebog_release/        # Built artifacts
```
