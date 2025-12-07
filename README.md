# Fast Streebog

High-performance implementation of the GOST R 34.11-2012 (Streebog) |  cryptographic hash function with x64 assembly optimizations.

## Overview

Fast Streebog is a optimized library implementing the Russian national standard hash function Streebog (GOST R 34.11-2012). It provides both 256-bit and 512-bit hash outputs.

> ⚠️ **Note:** Currently this library supports **Windows x64 only** with **AVX-512** instruction set extensions for maximum performance.

## Features

- **High Performance**: Core transformations implemented in x64 MASM assembly with AVX-512 optimizations
- **Dual Output**: Support for both 256-bit and 512-bit hash variants
- **Streaming API**: Process data in chunks with init/update/final pattern
- **One-shot API**: Simple single-call hashing for complete data
- **Hex Output**: Built-in conversion to hexadecimal strings
- **DLL Distribution**: Easy integration via dynamic library

## Performance

Performance comparison on 1 MB data (3 iterations average):

| Implementation | Throughput | Speedup |
|---------------|------------|---------|
| **Fast Streebog (ASM + Lookup Tables)** | **97.31 MB/s** | **68x** |
| Pure C Implementation | 1.43 MB/s | 1x |

**Key optimizations:**
- Precalculated Ax[8][256] lookup tables (16 KB) for L-transform
- AVX-512 assembly implementations of S, P, L, XOR, ADD, and KeySchedule primitives
- Optimized L-transform: 8 table lookups instead of up to 64 bit-by-bit operations
- Hybrid C+ASM architecture with Release build optimizations

Tested on Windows x64 with Visual Studio 2022 (MSVC 19.44).

## Requirements

- Windows x64
- CPU with AVX-512 support (Intel Skylake-X, Ice Lake, or newer; AMD Zen 4 or newer)
- Visual Studio 2019 or later (for building from source)

## Installation

### Pre-built DLL

Download the latest `streebog_windows.zip` from [Releases](https://github.com/vanyabeat/fast-streebog/releases) containing:
- `fast-streebog.dll` - Dynamic library
- `fast-streebog.lib` - Import library for linking
- `streebog.h` - Header file

### Building from Source

```bash
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --target fast-streebog-dll
```

The built files will be in the `streebog_windows/` directory.

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
