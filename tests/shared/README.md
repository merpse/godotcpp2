# Shared Test Utilities

This directory contains common testing infrastructure shared across all extension test suites.

## Directory Structure

```
shared/
├── mocks/                  # Mock implementations for testing
│   ├── godot_mock.h       # Godot engine mock objects
│   └── ...
├── utils/                  # Test utility functions
│   ├── test_helpers.h     # Common test helper functions
│   └── test_fixtures.h    # Common test fixtures
└── README.md              # This file
```

## Mock Objects

### Godot Mock (`mocks/godot_mock.h`)
Provides mock implementations of essential Godot classes for isolated unit testing:
- `godot::UtilityFunctions::print()` - Mock print functionality
- `godot::String` - Mock string class
- `godot::Node` - Mock node class (if needed)

## Test Utilities

### Test Helpers (`utils/test_helpers.h`)
Common utility functions used across multiple test suites:
- String comparison helpers
- Floating point comparison utilities
- Exception testing helpers
- Mock object validation

### Test Fixtures (`utils/test_fixtures.h`)
Common test fixtures and base classes:
- Base test classes with common setup/teardown
- Mock object factory functions
- Shared test data

## Usage

Include the shared utilities in your test files:

```cpp
#include "../shared/mocks/godot_mock.h"
#include "../shared/utils/test_helpers.h"
#include "../shared/utils/test_fixtures.h"
```

## Guidelines

1. **Isolation**: Mock objects should provide complete isolation from Godot runtime
2. **Consistency**: Use shared utilities for consistent testing behavior
3. **Maintenance**: Keep shared utilities simple and well-documented
4. **Coverage**: Ensure shared utilities are tested themselves