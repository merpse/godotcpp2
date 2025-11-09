#!/bin/bash
# CustomWindow Extension - Quick Build Script
# This script provides easy commands for building and testing

set -e  # Exit on any error

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${YELLOW}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if godot-cpp is initialized
check_submodules() {
    print_step "Checking godot-cpp submodule..."
    if [ ! -f "godot-cpp/CMakeLists.txt" ]; then
        print_step "Initializing godot-cpp submodule..."
        git submodule update --init --recursive
        print_success "Submodule initialized"
    else
        print_success "Submodule already initialized"
    fi
}

# Function to build extension with CMake
build_extension() {
    print_header "Building CustomWindow Extension with CMake"
    
    check_submodules
    
    BUILD_TYPE=${1:-Debug}
    print_step "Building in $BUILD_TYPE mode..."
    
    mkdir -p build
    cd build
    
    print_step "Configuring CMake..."
    cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
    
    print_step "Building with all CPU cores..."
    cmake --build . --parallel
    
    cd ..
    
    print_success "Extension built successfully!"
    echo -e "${GREEN}📁 Output: bin/libWindowExtension.macos.template_$(echo $BUILD_TYPE | tr '[:upper:]' '[:lower:]').dylib${NC}"
}

# Function to build with SCons (legacy)
build_scons() {
    print_header "Building CustomWindow Extension with SCons"
    
    check_submodules
    
    TARGET=${1:-template_debug}
    PLATFORM=${2:-macos}
    
    cd window
    print_step "Building with SCons ($PLATFORM, $TARGET)..."
    scons platform="$PLATFORM" target="$TARGET"
    cd ..
    
    print_success "SCons build completed!"
    echo -e "${GREEN}📁 Output: bin/libwindow.$PLATFORM.$TARGET.dylib${NC}"
}

# Function to run unit tests
run_tests() {
    print_header "Running Unit Tests"
    
    # Check if tests are built
    if [ ! -f "window/tests/build/window_tests" ]; then
        print_step "Building tests first..."
        cd window/tests
        mkdir -p build
        cd build
        cmake ..
        make -j$(nproc 2>/dev/null || echo 4)
        cd ../../..
    fi
    
    print_step "Running comprehensive test suite..."
    cd window/tests/build
    ./window_tests
    cd ../../..
    
    print_success "All unit tests completed!"
}

# Function to test Godot integration
test_godot() {
    print_header "Testing Godot Integration"
    
    print_step "Checking Godot version..."
    GODOT_VERSION=$(godot --version 2>&1 | head -1)
    echo "Found: $GODOT_VERSION"
    
    if [[ "$GODOT_VERSION" != *"4.5.stable"* ]]; then
        print_error "Warning: Expected Godot 4.5.0, found different version"
        echo "This may cause compatibility issues"
    fi
    
    print_step "Testing extension loading..."
    godot --headless project.godot --quit
    
    print_step "Testing extension functionality..."
    godot --headless --path . test_extension.tscn --quit
    
    print_success "Godot integration tests completed!"
}

# Function to clean build artifacts
clean() {
    print_header "Cleaning Build Artifacts"
    
    print_step "Removing CMake build directory..."
    rm -rf build
    
    print_step "Removing test build directory..."
    rm -rf window/tests/build
    
    print_step "Removing SCons artifacts..."
    cd window
    if command -v scons >/dev/null 2>&1; then
        scons --clean >/dev/null 2>&1 || true
    fi
    rm -f *.os
    cd ..
    
    print_step "Removing built libraries..."
    rm -rf bin/*.dylib bin/*.dll bin/*.so
    
    print_success "Clean completed!"
}

# Function to setup development environment
setup() {
    print_header "Setting up Development Environment"
    
    print_step "Checking system requirements..."
    
    # Check CMake
    if command -v cmake >/dev/null 2>&1; then
        CMAKE_VERSION=$(cmake --version | head -1)
        print_success "CMake found: $CMAKE_VERSION"
    else
        print_error "CMake not found. Please install CMake 3.16+"
        exit 1
    fi
    
    # Check C++ compiler
    if command -v clang++ >/dev/null 2>&1; then
        CXX_VERSION=$(clang++ --version | head -1)
        print_success "C++ compiler found: $CXX_VERSION"
    elif command -v g++ >/dev/null 2>&1; then
        CXX_VERSION=$(g++ --version | head -1)
        print_success "C++ compiler found: $CXX_VERSION"
    else
        print_error "No C++ compiler found. Please install a C++17 compatible compiler"
        exit 1
    fi
    
    # Check Godot
    if command -v godot >/dev/null 2>&1; then
        GODOT_VERSION=$(godot --version 2>&1 | head -1)
        print_success "Godot found: $GODOT_VERSION"
        if [[ "$GODOT_VERSION" != *"4.5.stable"* ]]; then
            print_error "Warning: Expected Godot 4.5.0 for full compatibility"
        fi
    else
        print_error "Godot not found. Please install Godot 4.5.0"
        exit 1
    fi
    
    check_submodules
    
    print_success "Development environment setup completed!"
}

# Function to show usage
show_help() {
    echo -e "${BLUE}CustomWindow Extension Build Script${NC}"
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  ${YELLOW}setup${NC}                    - Check and setup development environment"
    echo "  ${YELLOW}build [debug|release]${NC}    - Build extension with CMake (default: debug)"
    echo "  ${YELLOW}scons [target] [platform]${NC} - Build with SCons (default: template_debug macos)"
    echo "  ${YELLOW}test${NC}                     - Run unit tests"
    echo "  ${YELLOW}godot${NC}                    - Test Godot integration"
    echo "  ${YELLOW}all${NC}                      - Setup + build + test + godot test"
    echo "  ${YELLOW}clean${NC}                    - Clean all build artifacts"
    echo "  ${YELLOW}help${NC}                     - Show this help"
    echo
    echo "Examples:"
    echo "  $0 setup                 # Check system requirements"
    echo "  $0 build                 # Build debug version"
    echo "  $0 build release         # Build release version" 
    echo "  $0 scons template_debug macos    # Build with SCons"
    echo "  $0 test                  # Run unit tests"
    echo "  $0 godot                 # Test with Godot"
    echo "  $0 all                   # Full build and test cycle"
    echo "  $0 clean                 # Clean everything"
}

# Function to run all steps
run_all() {
    print_header "Running Full Build and Test Cycle"
    
    setup
    echo
    build_extension "Release"
    echo
    run_tests
    echo
    test_godot
    echo
    
    print_success "🎉 All operations completed successfully!"
}

# Main script logic
case "${1:-help}" in
    "setup")
        setup
        ;;
    "build")
        build_extension "${2:-Debug}"
        ;;
    "scons")
        build_scons "${2:-template_debug}" "${3:-macos}"
        ;;
    "test")
        run_tests
        ;;
    "godot")
        test_godot
        ;;
    "all")
        run_all
        ;;
    "clean")
        clean
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac