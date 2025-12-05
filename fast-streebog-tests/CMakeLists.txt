cmake_minimum_required(VERSION 3.20)
project(fast-streebog-tests LANGUAGES CXX)

include(FetchContent)

FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.17.0
)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(googletest)

add_executable(fast-streebog-tests
    src/algo_test.cpp
)

target_link_libraries(fast-streebog-tests PRIVATE
    GTest::gtest
    GTest::gtest_main
    fast-streebog-lib
)

include(GoogleTest)
gtest_discover_tests(fast-streebog-tests)
