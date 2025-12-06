cmake_minimum_required(VERSION 3.20)
project(fast-streebog-lib LANGUAGES C CXX)

# Option to build shared library (DLL)
option(BUILD_SHARED_LIBS "Build shared library (DLL on Windows)" OFF)

# ASM source files for Windows
set(ASM_SOURCES
    windows/streebog_xor_512.asm
    windows/streebog_add_512.asm
    windows/streebog_s_transform.asm
    windows/streebog_p_transform.asm
    windows/streebog_l_transform.asm
    windows/streebog_key_schedule.asm
    windows/streebog_e_transform.asm
    # windows/streebog_g_n.asm  # TODO: fix asm implementation
)

# ==================== Static Library ====================
add_library(fast-streebog-lib STATIC
    src/fast_streebog.c
)

if (MSVC)
    target_sources(fast-streebog-lib PRIVATE ${ASM_SOURCES})
endif()

target_include_directories(fast-streebog-lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

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
target_compile_definitions(fast-streebog-dll PRIVATE STREEBOG_BUILD_DLL)

if (MSVC)
    target_sources(fast-streebog-dll PRIVATE ${ASM_SOURCES})
endif()

target_include_directories(fast-streebog-dll PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Set output name to fast-streebog (without -dll suffix)
set_target_properties(fast-streebog-dll PROPERTIES
    OUTPUT_NAME "fast-streebog"
    VERSION 1.0.0
    SOVERSION 1
)

if(MSVC)
    target_compile_options(fast-streebog-dll PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/W4>)
else()
    target_compile_options(fast-streebog-dll PRIVATE -Wall -Wextra -fvisibility=hidden)
endif()

# ==================== MASM Configuration for Windows ====================
if(MSVC)
    enable_language(ASM_MASM)
    foreach(asm_file ${ASM_SOURCES})
        set_source_files_properties(${asm_file} PROPERTIES LANGUAGE ASM_MASM)
    endforeach()
    set(CMAKE_ASM_MASM_FLAGS_DEBUG "/Zi")
    target_compile_options(fast-streebog-lib PRIVATE /Zi)
    target_compile_options(fast-streebog-dll PRIVATE /Zi)
endif()

# ==================== Release Distribution (Windows) ====================
set(RELEASE_DIR "${CMAKE_SOURCE_DIR}/streebog_windows")

# Copy DLL, import library and header to release folder after build
add_custom_command(TARGET fast-streebog-dll POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${RELEASE_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:fast-streebog-dll>"
        "${RELEASE_DIR}/"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_LINKER_FILE:fast-streebog-dll>"
        "${RELEASE_DIR}/"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/dist/streebog.h"
        "${RELEASE_DIR}/"
    COMMENT "Copying DLL, import library and header to streebog_windows folder"
)

# ==================== Installation ====================
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