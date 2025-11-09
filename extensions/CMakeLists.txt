cmake_minimum_required(VERSION 3.16)
project(WindowExtensionTests)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(GTest REQUIRED)
find_package(PkgConfig REQUIRED)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../godot-cpp/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../godot-cpp/gen/include)

# Add the source files we want to test
set(SOURCE_FILES
    window.cpp
    opaque.cpp
    transparent.cpp
    closed_curtain.cpp
)

# Add test files
set(TEST_FILES
    tests/test_window.cpp
    tests/test_shade_states.cpp
    tests/test_curtain_states.cpp
    tests/test_main.cpp
)

# Create test executable
add_executable(window_tests ${SOURCE_FILES} ${TEST_FILES})

# Link with GTest and pthread
target_link_libraries(window_tests 
    GTest::gtest 
    GTest::gtest_main
    pthread
)

# Enable testing
enable_testing()
add_test(NAME WindowExtensionTests COMMAND window_tests)