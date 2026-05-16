cmake_minimum_required(VERSION 3.20)
project(fast-streebog-lib LANGUAGES C CXX)

option(FAST_STREEBOG_AS_SUBDIR "Build as subdirectory of another project" OFF)
if(FAST_STREEBOG_AS_SUBDIR)
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/../VERSION" STREEBOG_VERSION)
else()
  file(READ "${CMAKE_SOURCE_DIR}/VERSION" STREEBOG_VERSION)
endif()
string(STRIP "${STREEBOG_VERSION}" STREEBOG_VERSION)
message(STATUS "Building fast-streebog version: ${STREEBOG_VERSION}")

# Option to build shared library (DLL)
option(BUILD_SHARED_LIBS "Build shared library (DLL on Windows)" OFF)

# Option to use ASM optimizations
option(USE_ASM "Use assembly optimizations when available" ON)

# Detect platform and set ASM sources
set(ASM_SOURCES "")
set(USE_PLATFORM_ASM OFF)
if(USE_ASM)
    if(MSVC AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    enable_language(ASM_MASM)

    # AVX-512 
    set(ASM_SOURCES_AVX512
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx512/streebog_xor_512_avx512.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx512/streebog_add_512_avx512.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx512/streebog_s_transform_avx512.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx512/streebog_p_transform_avx512.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx512/streebog_l_transform_avx512.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx512/streebog_key_schedule_avx512.asm
    )

    # AVX2
    set(ASM_SOURCES_AVX2
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx2/streebog_xor_512_avx2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx2/streebog_add_512_avx2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx2/streebog_s_transform_avx2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx2/streebog_p_transform_avx2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx2/streebog_l_transform_avx2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_avx2/streebog_key_schedule_avx2.asm
    )

    set(ASM_SOURCES_SSSE3
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_ssse3/streebog_xor_512_ssse3.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_ssse3/streebog_add_512_ssse3.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_ssse3/streebog_s_transform_ssse3.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_ssse3/streebog_p_transform_ssse3.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_ssse3/streebog_l_transform_ssse3.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_ssse3/streebog_key_schedule_ssse3.asm
    )

    # SSE2
    set(ASM_SOURCES_SSE2
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_sse2/streebog_xor_512_sse2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_sse2/streebog_add_512_sse2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_sse2/streebog_s_transform_sse2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_sse2/streebog_p_transform_sse2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_sse2/streebog_l_transform_sse2.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/windows_x64_sse2/streebog_key_schedule_sse2.asm
    )

    set(ASM_SOURCES
        ${ASM_SOURCES_AVX512}
        ${ASM_SOURCES_AVX2}
        ${ASM_SOURCES_SSSE3}
        ${ASM_SOURCES_SSE2}
    )

    foreach(asm_file ${ASM_SOURCES})
        set_source_files_properties(${asm_file} PROPERTIES LANGUAGE ASM_MASM)
    endforeach()

    set(USE_PLATFORM_ASM ON)
    message(STATUS "Using Windows x64 MASM optimizations (AVX512 + AVX2 + SSSE3 + SSE2)")

    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64|ARM64")
        set(ASM_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_xor_512.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_add_512.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_s_transform.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_p_transform.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_l_transform.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_key_schedule.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_precalc_tables.S
            ${CMAKE_CURRENT_SOURCE_DIR}/unix_arm64/streebog_constants.S
        )
        enable_language(ASM)
        foreach(asm_file ${ASM_SOURCES})
            set_source_files_properties(${ASM_SOURCES} PROPERTIES 
            LANGUAGE ASM
            COMPILE_FLAGS "-x assembler-with-cpp"
        )
        endforeach()
        set(USE_PLATFORM_ASM ON)
        message(STATUS "Using ARM64 NEON optimizations")

    elseif(UNIX AND CMAKE_SIZEOF_VOID_P EQUAL 8)
        enable_language(ASM)
        set(ASM_SOURCES_AVX2
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_xor_512_avx2.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_add_512_avx2.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_s_transform_avx2.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_p_transform_avx2.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_l_transform_avx2.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_key_schedule_avx2.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_avx2/streebog_precalc_tables_avx2.S
        )
        set(ASM_SOURCES_SSSE3
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_xor_512_ssse3.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_add_512_ssse3.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_s_transform_ssse3.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_p_transform_ssse3.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_l_transform_ssse3.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_key_schedule_ssse3.S
            ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64_ssse3/streebog_precalc_tables_ssse3.S
        )
        set(ASM_SOURCES ${ASM_SOURCES_AVX2} ${ASM_SOURCES_SSSE3})

        foreach(asm_file ${ASM_SOURCES})
            set_source_files_properties(${asm_file} PROPERTIES
                LANGUAGE ASM
                COMPILE_FLAGS "-x assembler-with-cpp"
            )
        endforeach()

        set(USE_PLATFORM_ASM ON)
        message(STATUS "Using Linux x64 GAS optimizations (AVX2 + SSSE3)")

    else()
        message(STATUS "No ASM optimizations for this platform, using C fallback")
    endif()
endif()


# ==================== Static Library ==================== 
add_library(fast-streebog-lib STATIC
    src/fast_streebog.c
)

if(USE_PLATFORM_ASM)
    target_sources(fast-streebog-lib PRIVATE ${ASM_SOURCES})
    target_compile_definitions(fast-streebog-lib PRIVATE STREEBOG_USE_ASM)
endif()

target_include_directories(fast-streebog-lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Pass version to source code
target_compile_definitions(fast-streebog-lib PRIVATE STREEBOG_VERSION="${STREEBOG_VERSION}")

if(MSVC)
    target_compile_options(fast-streebog-lib PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/W4>)
else()
    target_compile_options(fast-streebog-lib PRIVATE -Wall -Wextra)
endif()

# ==================== Shared Library (DLL) ====================
add_library(fast-streebog-dll SHARED
    src/fast_streebog.c
)

# Define STREEBOG_BUILD_DLL when building the DLL
target_compile_definitions(fast-streebog-dll PRIVATE 
    STREEBOG_BUILD_DLL
    STREEBOG_VERSION="${STREEBOG_VERSION}"
)

if(USE_PLATFORM_ASM)
    target_sources(fast-streebog-dll PRIVATE ${ASM_SOURCES})
    target_compile_definitions(fast-streebog-dll PRIVATE STREEBOG_USE_ASM)
endif()

target_include_directories(fast-streebog-dll PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Set output name to fast-streebog (without -dll suffix)
set_target_properties(fast-streebog-dll PROPERTIES
    OUTPUT_NAME "fast-streebog"
    VERSION ${STREEBOG_VERSION}
    SOVERSION 1
    C_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
)

if(MSVC)
    target_compile_options(fast-streebog-dll PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/W4>)
endif()

# ==================== ASM Configuration ====================
if(USE_PLATFORM_ASM)
    if(MSVC)
        # Windows: MASM Configuration
        enable_language(ASM_MASM)
        foreach(asm_file ${ASM_SOURCES})
            set_source_files_properties(${asm_file} PROPERTIES LANGUAGE ASM_MASM)
        endforeach()
        set(CMAKE_ASM_MASM_FLAGS_DEBUG "/Zi")
        target_compile_options(fast-streebog-lib PRIVATE /Zi)
        target_compile_options(fast-streebog-dll PRIVATE /Zi)
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64|ARM64")
        # ARM64: GAS (GNU Assembler) Configuration
        enable_language(ASM)
        foreach(asm_file ${ASM_SOURCES})
            set_source_files_properties(${asm_file} PROPERTIES LANGUAGE ASM)
        endforeach()
        # Enable ARM64 optimizations
        target_compile_options(fast-streebog-lib PRIVATE -march=armv8-a+crypto)
        target_compile_options(fast-streebog-dll PRIVATE -march=armv8-a+crypto)
    elseif(UNIX AND CMAKE_SIZEOF_VOID_P EQUAL 8)
        target_compile_options(fast-streebog-lib PRIVATE -O3 -march=native)
        target_compile_options(fast-streebog-dll PRIVATE -O3 -march=native)
    endif()
endif()

# ==================== Release Distribution ====================
# Only create release distribution when building standalone
if(NOT FAST_STREEBOG_AS_SUBDIR)
    set(RELEASE_DIR "${CMAKE_SOURCE_DIR}/streebog_release")

    # Copy DLL, import library, static library and header to release folder after build
    add_custom_command(TARGET fast-streebog-dll POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${RELEASE_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:fast-streebog-dll>"
            "${RELEASE_DIR}/"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_LINKER_FILE:fast-streebog-dll>"
            "${RELEASE_DIR}/"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:fast-streebog-lib>"
            "${RELEASE_DIR}/"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_CURRENT_SOURCE_DIR}/dist/streebog.h"
            "${RELEASE_DIR}/"
        COMMENT "Copying libraries and header to streebog_release folder"
    )
endif()

# Ensure static library is built before DLL post-build commands run
add_dependencies(fast-streebog-dll fast-streebog-lib)

# ==================== Installation ====================
# Only install when building standalone
if(NOT FAST_STREEBOG_AS_SUBDIR)
    include(GNUInstallDirs)

    install(TARGETS fast-streebog-lib fast-streebog-dll
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    install(DIRECTORY include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/fast-streebog
        FILES_MATCHING PATTERN "*.h"
    )
endif()