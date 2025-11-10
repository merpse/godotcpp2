# CMakeLists.txt for Organized GDExtension Tests
cmake_minimum_required(VERSION 3.16)

project(GDExtensionTests)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(PkgConfig REQUIRED)

# Add godot-cpp path for tests
set(GODOT_CPP_PATH ${CMAKE_SOURCE_DIR}/../godot-cpp)

# Set godot-cpp library path
set(GODOT_CPP_LIB ${GODOT_CPP_PATH}/bin/libgodot-cpp.macos.template_debug.universal.a)

# Enable testing
enable_testing()

# Include directories
include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/../extensions)
include_directories(${CMAKE_SOURCE_DIR}/shared)

# Add godot-cpp include directories
include_directories(${GODOT_CPP_PATH}/include)
include_directories(${GODOT_CPP_PATH}/gen/include)
include_directories(${GODOT_CPP_PATH}/gdextension)

# GoogleTest setup
add_subdirectory(${CMAKE_SOURCE_DIR}/../extensions/googletest ${CMAKE_BINARY_DIR}/googletest)

# Define test compilation flags
set(TEST_COMPILE_FLAGS -DTESTING_MODE=1)

# Shared test utilities library
add_library(shared_test_utils STATIC
    shared/mocks/godot_mock.cpp
    shared/mocks/godot_mock.h
    shared/utils/test_helpers.h
    shared/utils/test_fixtures.h
)

target_include_directories(shared_test_utils PUBLIC
    shared
    ../extensions/googletest/googletest/include
    ${GODOT_CPP_PATH}/include
    ${GODOT_CPP_PATH}/gen/include
    ${GODOT_CPP_PATH}/gdextension
)

target_link_libraries(shared_test_utils
    gtest
    gtest_main
)

set_target_properties(shared_test_utils PROPERTIES
    COMPILE_FLAGS "${TEST_COMPILE_FLAGS}"
)

# Medical Equipment Tests
set(MEDICAL_EQUIPMENT_TEST_SOURCES
    medical_equipment/test_bed_base.cpp
    medical_equipment/test_patient_bed.cpp
    medical_equipment/test_surgical_bed.cpp
    medical_equipment/test_bed_factory.cpp
    medical_equipment/test_godot_bed_factory.cpp
    medical_equipment/test_light_strip.cpp
)

add_executable(medical_equipment_tests ${MEDICAL_EQUIPMENT_TEST_SOURCES})

target_include_directories(medical_equipment_tests PRIVATE
    ../extensions/medical_equipment
    shared
    ../extensions/googletest/googletest/include
    ${GODOT_CPP_PATH}/include
    ${GODOT_CPP_PATH}/gen/include
    ${GODOT_CPP_PATH}/gdextension
)

target_link_libraries(medical_equipment_tests
    shared_test_utils
    gtest
    gtest_main
    ${GODOT_CPP_LIB}
)

set_target_properties(medical_equipment_tests PROPERTIES
    COMPILE_FLAGS "${TEST_COMPILE_FLAGS}"
)

# Window Controls Tests (TEMPORARILY DISABLED due to mock conflicts)
# TODO: Fix Godot header conflicts with mocks
# set(WINDOW_CONTROLS_TEST_SOURCES
#     window_controls/test_window.cpp
#     window_controls/test_state_pattern.cpp
#     window_controls/test_shade_states.cpp
#     window_controls/test_curtain_states.cpp
#     window_controls/test_window_state_implementations.cpp
# )
#
# add_executable(window_controls_tests ${WINDOW_CONTROLS_TEST_SOURCES})

# target_include_directories(window_controls_tests PRIVATE
#     ../extensions/window_controls
#     shared
#     ../extensions/googletest/googletest/include
#     ${GODOT_CPP_PATH}/include
#     ${GODOT_CPP_PATH}/gen/include
#     ${GODOT_CPP_PATH}/gdextension
# )
#
# target_link_libraries(window_controls_tests
#     shared_test_utils
#     gtest
#     gtest_main
#     ${GODOT_CPP_LIB}
# )
#
# set_target_properties(window_controls_tests PROPERTIES
#     COMPILE_FLAGS "${TEST_COMPILE_FLAGS}"
# )

# Core Framework Tests (TEMPORARILY DISABLED due to mock conflicts)
# TODO: Fix Godot header conflicts with mocks
# set(CORE_FRAMEWORK_TEST_SOURCES
#     core/test_extension_registry.cpp
#     core/test_lifecycle_management.cpp
#     core/test_register_types.cpp
# )
#
# add_executable(core_framework_tests ${CORE_FRAMEWORK_TEST_SOURCES})

# target_include_directories(core_framework_tests PRIVATE
#     ../extensions/core
#     shared
#     ../extensions/googletest/googletest/include
#     ${GODOT_CPP_PATH}/include
#     ${GODOT_CPP_PATH}/gen/include
#     ${GODOT_CPP_PATH}/gdextension
# )
#
# target_link_libraries(core_framework_tests
#     shared_test_utils
#     gtest
#     gtest_main
#     ${GODOT_CPP_LIB}
# )
#
# set_target_properties(core_framework_tests PROPERTIES
#     COMPILE_FLAGS "${TEST_COMPILE_FLAGS}"
# )

# All tests combined (currently only medical equipment tests)
add_executable(all_tests
    ${MEDICAL_EQUIPMENT_TEST_SOURCES}
    # ${WINDOW_CONTROLS_TEST_SOURCES}  # DISABLED
    # ${CORE_FRAMEWORK_TEST_SOURCES}   # DISABLED
)

target_include_directories(all_tests PRIVATE
    ../extensions/medical_equipment
    # ../extensions/window_controls     # DISABLED
    # ../extensions/core                # DISABLED
    shared
    ../extensions/googletest/googletest/include
    ${GODOT_CPP_PATH}/include
    ${GODOT_CPP_PATH}/gen/include
    ${GODOT_CPP_PATH}/gdextension
)

target_link_libraries(all_tests
    shared_test_utils
    gtest
    gtest_main
    ${GODOT_CPP_LIB}
)

set_target_properties(all_tests PROPERTIES
    COMPILE_FLAGS "${TEST_COMPILE_FLAGS}"
)

# Register tests with CTest
add_test(NAME MedicalEquipmentTests COMMAND medical_equipment_tests)
# add_test(NAME WindowControlsTests COMMAND window_controls_tests)      # DISABLED
# add_test(NAME CoreFrameworkTests COMMAND core_framework_tests)        # DISABLED
add_test(NAME AllTests COMMAND all_tests)

# Set test properties
set_tests_properties(MedicalEquipmentTests PROPERTIES
    TIMEOUT 60
    LABELS "medical;equipment"
)

# set_tests_properties(WindowControlsTests PROPERTIES               # DISABLED
#     TIMEOUT 60                                                     # DISABLED
#     LABELS "window;controls"                                       # DISABLED
# )                                                                  # DISABLED

# set_tests_properties(CoreFrameworkTests PROPERTIES               # DISABLED
#     TIMEOUT 60                                                     # DISABLED
#     LABELS "core;framework"                                        # DISABLED
# )                                                                  # DISABLED

set_tests_properties(AllTests PROPERTIES
    TIMEOUT 180
    LABELS "comprehensive"
)

# Custom targets for running specific test suites
add_custom_target(test_medical
    COMMAND ${CMAKE_CTEST_COMMAND} -L medical -V
    DEPENDS medical_equipment_tests
    COMMENT "Running medical equipment tests"
)

add_custom_target(test_window
    COMMAND ${CMAKE_CTEST_COMMAND} -L window -V
    DEPENDS window_controls_tests
    COMMENT "Running window controls tests"
)

add_custom_target(test_core
    COMMAND ${CMAKE_CTEST_COMMAND} -L core -V
    DEPENDS core_framework_tests
    COMMENT "Running core framework tests"
)

add_custom_target(test_all
    COMMAND ${CMAKE_CTEST_COMMAND} -V
    DEPENDS all_tests
    COMMENT "Running all extension tests"
)

# Custom target for test coverage (if available)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_program(GCOV_PATH gcov)
    if(GCOV_PATH)
        add_custom_target(test_coverage
            COMMAND ${CMAKE_CTEST_COMMAND}
            COMMAND gcov ${CMAKE_BINARY_DIR}/**/*.gcno
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Running tests with coverage analysis"
        )
    endif()
endif()

# Installation (optional)
install(TARGETS medical_equipment_tests all_tests
    RUNTIME DESTINATION bin/tests
)

# CPack configuration for test packaging (optional)
set(CPACK_PACKAGE_NAME "GDExtensionTests")
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_PACKAGE_DESCRIPTION "Organized unit tests for Godot C++ GDExtensions")
include(CPack)