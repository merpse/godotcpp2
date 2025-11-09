#!/bin/bash

# Quick Godot Test Runner - For development and debugging
# This is a simplified version for fast testing during development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() {
    echo -e "${1}${2}${NC}"
}

print_header() {
    print_color $BLUE "🧪 $1"
}

print_success() {
    print_color $GREEN "✅ $1"
}

print_error() {
    print_color $RED "❌ $1"
}

cd "$ROOT_DIR"

print_header "Quick Godot Integration Test"

# Check if Godot is available
if ! command -v godot &> /dev/null; then
    print_error "Godot executable not found. Please install Godot or add it to PATH."
    exit 1
fi

# Run the test
echo "Running: godot --headless --path . --script tests/headless_test_runner.gd"
if godot --headless --path . --script tests/headless_test_runner.gd 2>&1 | tee /tmp/godot_test_output.log; then
    # Check if we actually got test results (not just a successful exit code)
    if grep -q "Tests Passed:" /tmp/godot_test_output.log; then
        print_success "Godot tests completed successfully!"
        exit 0
    else
        print_error "Godot test runner failed to execute properly!"
        exit 1
    fi
else
    print_error "Godot tests failed!"
    exit 1
fi