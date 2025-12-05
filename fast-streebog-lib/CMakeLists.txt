cmake_minimum_required(VERSION 3.20)
project(fast-streebog-lib LANGUAGES C CXX)

# Создаём статическую библиотеку
add_library(fast-streebog-lib STATIC
    src/fast_streebog.c
)

if (MSVC)
    target_sources(fast-streebog-lib PRIVATE
        windows/streebog_xor_512.asm
        windows/streebog_add_512.asm
        windows/streebog_s_transform.asm
        windows/streebog_p_transform.asm
        windows/streebog_l_transform.asm
        windows/streebog_key_schedule.asm
    )
endif()

# Публичные заголовочные файлы
target_include_directories(fast-streebog-lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Настройки компиляции для Windows (только для C/C++ файлов)
if(MSVC)
    target_compile_options(fast-streebog-lib PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/W4>)
else()
    target_compile_options(fast-streebog-lib PRIVATE -Wall -Wextra)
endif()

if(MSVC)
    enable_language(ASM_MASM)
    set_source_files_properties(windows/streebog_xor_512.asm PROPERTIES LANGUAGE ASM_MASM)
    set_source_files_properties(windows/streebog_add_512.asm PROPERTIES LANGUAGE ASM_MASM)
    set_source_files_properties(windows/streebog_s_transform.asm PROPERTIES LANGUAGE ASM_MASM)
    set_source_files_properties(windows/streebog_p_transform.asm PROPERTIES LANGUAGE ASM_MASM)
    set_source_files_properties(windows/streebog_l_transform.asm PROPERTIES LANGUAGE ASM_MASM)
    set_source_files_properties(windows/streebog_key_schedule.asm PROPERTIES LANGUAGE ASM_MASM)
    # Включаем отладочную информацию для ассемблера
    set(CMAKE_ASM_MASM_FLAGS_DEBUG "/Zi")
    target_compile_options(fast-streebog-lib PRIVATE /Zi)
endif()