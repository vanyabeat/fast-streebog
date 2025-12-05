cmake_minimum_required(VERSION 3.20)
project(fast-json LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

enable_testing()

add_subdirectory(fast-streebog-lib)
add_subdirectory(fast-streebog-tests)