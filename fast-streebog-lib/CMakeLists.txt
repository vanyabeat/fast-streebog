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
    # Windows x64 with MSVC - use MASM
    if(MSVC AND CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(ASM_SOURCES
            windows_x64/streebog_xor_512.asm
            windows_x64/streebog_add_512.asm
            windows_x64/streebog_s_transform.asm
            windows_x64/streebog_p_transform.asm
            windows_x64/streebog_l_transform.asm
            windows_x64/streebog_key_schedule.asm
        )
        set(USE_PLATFORM_ASM ON)
        message(STATUS "Using Windows x64 MASM optimizations")
    # Unix ARM64 (Linux, macOS, BSD) - use GAS (GNU Assembler syntax)
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64|ARM64")
        set(ASM_SOURCES
            unix_arm64/streebog_xor_512.S
            unix_arm64/streebog_add_512.S
            unix_arm64/streebog_s_transform.S
            unix_arm64/streebog_p_transform.S
            unix_arm64/streebog_l_transform.S
            unix_arm64/streebog_key_schedule.S
            unix_arm64/streebog_precalc_tables.S
            unix_arm64/streebog_constants.S
        )
        set(USE_PLATFORM_ASM ON)
        message(STATUS "Using ARM64 NEON optimizations (Unix)")
    else()
        message(STATUS "No ASM optimizations available for this platform, using C implementation")
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
)

if(MSVC)
    target_compile_options(fast-streebog-dll PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/W4>)
else()
    target_compile_options(fast-streebog-dll PRIVATE -Wall -Wextra -fvisibility=hidden)
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