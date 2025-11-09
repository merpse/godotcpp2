#!/bin/bash

# Comprehensive GDExtension Test Runner
# Executes all organized tests and reports results

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build_tests"
TEST_RESULTS_DIR="$BUILD_DIR/test_results"
LOG_FILE="$TEST_RESULTS_DIR/test_runner.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test configuration
VERBOSE=false
BUILD_TESTS=true
RUN_COVERAGE=false
RUN_GODOT_TESTS=true
SPECIFIC_SUITE=""

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_color $BLUE "=================================================="
    print_color $BLUE "$1"
    print_color $BLUE "=================================================="
}

print_success() {
    print_color $GREEN "✅ $1"
}

print_warning() {
    print_color $YELLOW "⚠️ $1"
}

print_error() {
    print_color $RED "❌ $1"
}

print_info() {
    print_color $PURPLE "📋 $1"
}

# Usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -v, --verbose           Enable verbose output"
    echo "  -s, --suite SUITE       Run specific test suite (godot|medical|window|core|all)"
    echo "  -n, --no-build          Skip building tests"
    echo "  -g, --no-godot          Skip Godot integration tests"
    echo "  -c, --coverage          Run with coverage analysis"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all tests"
    echo "  $0 -s godot            # Run only Godot integration tests"
    echo "  $0 -s medical          # Run only medical equipment tests"
    echo "  $0 -v -c               # Run all tests with verbose output and coverage"
    echo ""
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--suite)
                SPECIFIC_SUITE="$2"
                shift 2
                ;;
            -n|--no-build)
                BUILD_TESTS=false
                shift
                ;;
            -g|--no-godot)
                RUN_GODOT_TESTS=false
                shift
                ;;
            -c|--coverage)
                RUN_COVERAGE=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Setup test environment
setup_environment() {
    print_header "Setting Up Test Environment"
    
    # Create directories
    mkdir -p "$BUILD_DIR"
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Create log file
    touch "$LOG_FILE"
    
    print_success "Test directories created"
    print_info "Build directory: $BUILD_DIR"
    print_info "Results directory: $TEST_RESULTS_DIR"
    print_info "Log file: $LOG_FILE"
}

# Build tests
build_tests() {
    if [ "$BUILD_TESTS" = false ]; then
        print_warning "Skipping test build (--no-build specified)"
        return 0
    fi

    print_header "Building Organized Test Suite"
    
    cd "$ROOT_DIR"
    
    # Configure CMake for tests
    print_info "Configuring CMake for tests..."
    if [ "$VERBOSE" = true ]; then
        cmake -B "$BUILD_DIR" -S tests -DCMAKE_BUILD_TYPE=Debug | tee -a "$LOG_FILE"
    else
        cmake -B "$BUILD_DIR" -S tests -DCMAKE_BUILD_TYPE=Debug >> "$LOG_FILE" 2>&1
    fi
    
    # Build all test targets
    print_info "Building test executables..."
    if [ "$VERBOSE" = true ]; then
        cmake --build "$BUILD_DIR" --parallel | tee -a "$LOG_FILE"
    else
        cmake --build "$BUILD_DIR" --parallel >> "$LOG_FILE" 2>&1
    fi
    
    print_success "Test suite built successfully"
}

# Verify test executables
verify_executables() {
    print_header "Verifying Test Executables"
    
    local executables=(
        "$BUILD_DIR/medical_equipment_tests"
        "$BUILD_DIR/window_controls_tests"
        "$BUILD_DIR/core_framework_tests"
        "$BUILD_DIR/all_tests"
    )
    
    local all_found=true
    
    for exe in "${executables[@]}"; do
        if [ -f "$exe" ] && [ -x "$exe" ]; then
            print_success "$(basename "$exe") - Ready"
        else
            print_error "$(basename "$exe") - Missing or not executable"
            all_found=false
        fi
    done
    
    if [ "$all_found" = false ]; then
        print_error "Some test executables are missing. Build may have failed."
        exit 1
    fi
    
    print_success "All test executables verified"
}

# Run specific test suite
run_test_suite() {
    local suite_name=$1
    local executable=$2
    local description=$3
    
    print_header "Running $description Tests"
    
    local start_time=$(date +%s)
    local result_file="$TEST_RESULTS_DIR/${suite_name}_results.xml"
    local output_file="$TEST_RESULTS_DIR/${suite_name}_output.log"
    
    print_info "Executable: $executable"
    print_info "Results: $result_file"
    print_info "Output: $output_file"
    
    # Run the test suite
    if [ -f "$executable" ]; then
        if [ "$VERBOSE" = true ]; then
            "$executable" --gtest_output=xml:"$result_file" 2>&1 | tee "$output_file"
            local exit_code=${PIPESTATUS[0]}
        else
            "$executable" --gtest_output=xml:"$result_file" > "$output_file" 2>&1
            local exit_code=$?
        fi
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [ $exit_code -eq 0 ]; then
            print_success "$description tests completed in ${duration}s"
            
            # Extract test summary from output
            local test_count=$(grep -o "Running [0-9]* tests" "$output_file" | grep -o "[0-9]*" || echo "0")
            local passed_count=$(grep -o "\[[[:space:]]*PASSED[[:space:]]*\] [0-9]* tests" "$output_file" | grep -o "[0-9]*" || echo "0")
            local failed_count=$(grep -o "\[[[:space:]]*FAILED[[:space:]]*\] [0-9]* tests" "$output_file" | grep -o "[0-9]*" || echo "0")
            
            print_info "Tests run: $test_count, Passed: $passed_count, Failed: $failed_count"
            return 0
        else
            print_error "$description tests failed (exit code: $exit_code) after ${duration}s"
            
            if [ "$VERBOSE" = false ]; then
                print_info "Showing last 10 lines of output:"
                tail -10 "$output_file"
            fi
            return 1
        fi
    else
        print_error "Test executable not found: $executable"
        return 1
    fi
}

# Run Godot integration tests
run_godot_tests() {
    print_header "Running Godot Integration Tests"
    
    if [ "$RUN_GODOT_TESTS" = false ]; then
        print_warning "Skipping Godot tests (disabled)"
        return 0
    fi
    
    local start_time=$(date +%s)
    local output_file="$TEST_RESULTS_DIR/godot_tests_output.log"
    
    print_info "Running headless test runner..."
    print_info "Output: $output_file"
    
    # Change to project directory
    cd "$ROOT_DIR"
    
    # Run Godot headless tests
    if [ "$VERBOSE" = true ]; then
        if command -v godot &> /dev/null; then
            godot --headless --path . --script tests/headless_test_runner.gd 2>&1 | tee "$output_file"
            local exit_code=${PIPESTATUS[0]}
        else
            print_error "Godot executable not found. Please install Godot or add it to PATH."
            return 1
        fi
    else
        if command -v godot &> /dev/null; then
            godot --headless --path . --script tests/headless_test_runner.gd > "$output_file" 2>&1
            local exit_code=$?
        else
            print_error "Godot executable not found. Please install Godot or add it to PATH."
            return 1
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Parse test results from output
    local tests_passed=$(grep -o "Tests Passed: [0-9]*" "$output_file" | grep -o "[0-9]*" || echo "0")
    local tests_failed=$(grep -o "Tests Failed: [0-9]*" "$output_file" | grep -o "[0-9]*" || echo "0")
    local total_tests=$((tests_passed + tests_failed))
    
    if [ "$tests_failed" -eq 0 ] && [ "$total_tests" -gt 0 ]; then
        print_success "Godot integration tests completed in ${duration}s"
        print_info "Tests run: $total_tests, Passed: $tests_passed, Failed: $tests_failed"
        return 0
    elif [ "$total_tests" -eq 0 ]; then
        print_warning "No Godot tests were executed - check test runner"
        if [ "$VERBOSE" = false ]; then
            print_info "Showing last 10 lines of output:"
            tail -10 "$output_file"
        fi
        return 1
    else
        print_error "Godot integration tests failed after ${duration}s"
        print_info "Tests run: $total_tests, Passed: $tests_passed, Failed: $tests_failed"
        
        if [ "$VERBOSE" = false ]; then
            print_info "Showing last 10 lines of output:"
            tail -10 "$output_file"
        fi
        return 1
    fi
}

# Run all test suites
run_all_tests() {
    print_header "Running Complete Test Suite"
    
    local total_start_time=$(date +%s)
    local failed_suites=()
    local passed_suites=()
    
    # Godot Integration Tests (run first as they test the foundation)
    if run_godot_tests; then
        passed_suites+=("Godot Integration")
    else
        failed_suites+=("Godot Integration")
    fi
    
    # Medical Equipment Tests
    if run_test_suite "medical" "$BUILD_DIR/medical_equipment_tests" "Medical Equipment"; then
        passed_suites+=("Medical Equipment")
    else
        failed_suites+=("Medical Equipment")
    fi
    
    # Window Controls Tests
    if run_test_suite "window" "$BUILD_DIR/window_controls_tests" "Window Controls"; then
        passed_suites+=("Window Controls")
    else
        failed_suites+=("Window Controls")
    fi
    
    # Core Framework Tests
    if run_test_suite "core" "$BUILD_DIR/core_framework_tests" "Core Framework"; then
        passed_suites+=("Core Framework")
    else
        failed_suites+=("Core Framework")
    fi
    
    # Comprehensive Tests (all combined)
    if run_test_suite "comprehensive" "$BUILD_DIR/all_tests" "Comprehensive"; then
        passed_suites+=("Comprehensive")
    else
        failed_suites+=("Comprehensive")
    fi
    
    local total_end_time=$(date +%s)
    local total_duration=$((total_end_time - total_start_time))
    
    # Report final results
    print_header "Test Suite Summary"
    
    print_info "Total execution time: ${total_duration}s"
    print_info "Passed suites: ${#passed_suites[@]}"
    print_info "Failed suites: ${#failed_suites[@]}"
    
    if [ ${#passed_suites[@]} -gt 0 ]; then
        print_success "Passed: ${passed_suites[*]}"
    fi
    
    if [ ${#failed_suites[@]} -gt 0 ]; then
        print_error "Failed: ${failed_suites[*]}"
        return 1
    else
        print_success "All test suites passed!"
        return 0
    fi
}

# Run coverage analysis
run_coverage() {
    if [ "$RUN_COVERAGE" = false ]; then
        return 0
    fi
    
    print_header "Running Coverage Analysis"
    
    # Check if gcov is available
    if ! command -v gcov &> /dev/null; then
        print_warning "gcov not found, skipping coverage analysis"
        return 0
    fi
    
    print_info "Analyzing test coverage..."
    # Coverage analysis implementation would go here
    print_warning "Coverage analysis not yet implemented"
}

# Generate test report
generate_report() {
    print_header "Generating Test Report"
    
    local report_file="$TEST_RESULTS_DIR/test_report.md"
    local timestamp=$(date)
    
    cat > "$report_file" << EOF
# GDExtension Test Report

**Generated:** $timestamp  
**Test Runner:** $(basename "$0")  
**Root Directory:** $ROOT_DIR  
**Build Directory:** $BUILD_DIR  

## Test Suite Organization

### 📁 Test Structure
\`\`\`
tests/
├── medical_equipment/     🏥 Healthcare simulation tests
├── window_controls/       🪟 UI interaction tests  
├── core/                  🎯 Extension framework tests
└── shared/                🔧 Common test utilities
\`\`\`

### 🏥 Medical Equipment Tests
- ✅ Bed base class functionality
- ✅ Patient bed specialized features
- ✅ Surgical bed operations
- ✅ Factory pattern implementation

### 🪟 Window Controls Tests  
- ✅ Window operations
- ✅ State pattern implementation
- ✅ Shade state management
- ✅ Curtain state management

### 🎯 Core Framework Tests
- ✅ Extension registration
- ✅ Lifecycle management
- ✅ Registry coordination

## Results Summary

Test results can be found in the following files:
- Medical Equipment: \`medical_results.xml\`
- Window Controls: \`window_results.xml\`
- Core Framework: \`core_results.xml\`
- Comprehensive: \`comprehensive_results.xml\`

## Execution Logs

Detailed execution logs are available in:
- Main log: \`test_runner.log\`
- Individual outputs: \`*_output.log\`

---
*Organized GDExtension Test Suite - Professional C++ Testing Framework*
EOF

    print_success "Test report generated: $report_file"
}

# Main execution function
main() {
    parse_args "$@"
    
    print_header "🧪 Organized GDExtension Test Runner"
    print_info "Running organized C++ unit tests for GDExtensions"
    print_info "Extensions: Medical Equipment, Window Controls, Core Framework"
    
    # Setup
    setup_environment
    
    # For Godot tests, skip C++ building and verification
    if [ "$SPECIFIC_SUITE" != "godot" ]; then
        # Build tests
        build_tests
        verify_executables
    fi
    
    # Run tests based on suite selection
    case "$SPECIFIC_SUITE" in
        "godot")
            run_godot_tests
            ;;
        "medical")
            run_test_suite "medical" "$BUILD_DIR/medical_equipment_tests" "Medical Equipment"
            ;;
        "window")
            run_test_suite "window" "$BUILD_DIR/window_controls_tests" "Window Controls"
            ;;
        "core")
            run_test_suite "core" "$BUILD_DIR/core_framework_tests" "Core Framework"
            ;;
        "all"|"")
            run_all_tests
            ;;
        *)
            print_error "Unknown test suite: $SPECIFIC_SUITE"
            print_info "Available suites: godot, medical, window, core, all"
            exit 1
            ;;
    esac
    
    local test_exit_code=$?
    
    # Coverage analysis
    run_coverage
    
    # Generate report
    generate_report
    
    # Final status
    if [ $test_exit_code -eq 0 ]; then
        print_header "🎉 Test Suite Completed Successfully!"
        print_success "All organized extension tests passed"
        print_info "View detailed results in: $TEST_RESULTS_DIR"
    else
        print_header "❌ Test Suite Failed"
        print_error "Some tests failed"
        print_info "Check logs in: $TEST_RESULTS_DIR"
        exit 1
    fi
}

# Execute main function
main "$@"