cmake_minimum_required(VERSION 3.16)
project(WindowExtension VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# Platform-specific settings
if(APPLE)
    set(TARGET_PLATFORM "macos")
    set(LIB_EXTENSION "dylib")
elseif(WIN32)
    set(TARGET_PLATFORM "windows")
    set(LIB_EXTENSION "dll")
else()
    set(TARGET_PLATFORM "linux")
    set(LIB_EXTENSION "so")
endif()

# Build godot-cpp first
set(GODOTCPP_BUILD_TYPE ${CMAKE_BUILD_TYPE})
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(GODOTCPP_TARGET "template_debug")
else()
    set(GODOTCPP_TARGET "template_release")
endif()

# Add godot-cpp as subdirectory
add_subdirectory(godot-cpp)

# Our extension source files
set(EXTENSION_SOURCES
    # Core extension framework
    extensions/core/register_types.cpp
    
    # Window controls extension
    extensions/window_controls/window.cpp
    extensions/window_controls/opaque.cpp
    extensions/window_controls/transparent.cpp
    extensions/window_controls/closed_curtain.cpp
    
    # Medical equipment extension
    extensions/medical_equipment/bed.cpp
    extensions/medical_equipment/patient_bed.cpp
    extensions/medical_equipment/surgical_bed.cpp
    extensions/medical_equipment/bed_factory.cpp
    extensions/medical_equipment/godot_bed_factory.cpp
    extensions/medical_equipment/godot_light_strip.cpp
)

# Create the extension library
add_library(${PROJECT_NAME} SHARED ${EXTENSION_SOURCES})

# Set target properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    PREFIX "lib"
    SUFFIX ".${TARGET_PLATFORM}.${GODOTCPP_TARGET}.${LIB_EXTENSION}"
    POSITION_INDEPENDENT_CODE ON
)

# Link with godot-cpp
target_link_libraries(${PROJECT_NAME} godot-cpp)

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    extensions/
    extensions/core/
    extensions/window_controls/
    extensions/medical_equipment/
    godot-cpp/include/
    godot-cpp/gen/include/
)

# Compiler-specific options
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wno-unused-parameter)
endif()

# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin"
)

# Enable parallel compilation on MSVC
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /MP)
endif()

# Print build information
message(STATUS "Building ${PROJECT_NAME} for ${TARGET_PLATFORM}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Godot-cpp target: ${GODOTCPP_TARGET}")
message(STATUS "Output file: lib${PROJECT_NAME}.${TARGET_PLATFORM}.${GODOTCPP_TARGET}.${LIB_EXTENSION}")

# Testing configuration
option(ENABLE_TESTING "Enable testing" OFF)

if(ENABLE_TESTING)
    # Find GoogleTest
    find_package(GTest QUIET)
    if(NOT GTest_FOUND)
        # Download and include GoogleTest
        include(FetchContent)
        FetchContent_Declare(
            googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG release-1.12.1
        )
        FetchContent_MakeAvailable(googletest)
    endif()

    # Enable testing for this project
    enable_testing()

    # Test source files  
    set(TEST_SOURCES
        tests/medical_equipment/test_bed_base.cpp
        tests/medical_equipment/test_patient_bed.cpp
        tests/medical_equipment/test_surgical_bed.cpp
        tests/medical_equipment/test_bed_factory.cpp
        tests/medical_equipment/test_godot_bed_factory.cpp
        tests/medical_equipment/test_light_strip_simple.cpp
        # NOTE: Window controls tests disabled due to Godot header dependencies
        # Use the independent tests/CMakeLists.txt build for complete testing
        # tests/window_controls/test_window.cpp
        # tests/window_controls/test_state_pattern.cpp
        # tests/window_controls/test_curtain_states.cpp
        # tests/window_controls/test_shade_states.cpp
        # tests/window_controls/test_window_state_implementations.cpp
        # tests/core/test_register_types.cpp
        # tests/core/test_lifecycle_management.cpp
        # tests/core/test_extension_registry.cpp
    )

    # Create test executable
    add_executable(${PROJECT_NAME}_tests ${TEST_SOURCES})

    # Link test executable with GoogleTest and our extension
    target_link_libraries(${PROJECT_NAME}_tests 
        gtest 
        gtest_main
    )

    # Include directories for tests
    target_include_directories(${PROJECT_NAME}_tests PRIVATE
        extensions/
        extensions/core/
        extensions/window_controls/
        extensions/medical_equipment/
        tests/
        tests/medical_equipment/
        tests/window_controls/
        tests/core/
    )

    # Add test directory to the build
    add_test(NAME ${PROJECT_NAME}_unit_tests COMMAND ${PROJECT_NAME}_tests)

    message(STATUS "Testing enabled - GoogleTest configured")
endif()