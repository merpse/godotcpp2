# 🧪 Testing Architecture Documentation

## Overview

This project implements a **three-tier testing architecture** designed to provide comprehensive validation of Godot C++ extensions at different levels of integration and complexity.

## 🏗️ Architecture Diagram

```
                Testing Architecture
                ────────────────────
                                    
    🔬 Unit Tests        🔗 Integration Tests      👁️  Visual Tests
    ─────────────        ────────────────────     ──────────────
                                    
    tests/               integration_tests/        test_project/
    ├── medical/         ├── test_medical.gd       ├── project.godot
    ├── window/          ├── test_extension.gd     ├── scenes/
    ├── core/            └── test_scene.tscn       ├── scripts/
    └── shared/                                    └── TESTING_GUIDE.md
                                    
    GoogleTest           GDScript Tests            Godot Project
    Fast & Isolated      Medium Speed              Interactive Testing
    C++ Code Only        Godot Runtime             Full Environment
```

## 🎯 Three-Tier System Details

### 1. 🔬 Unit Tests (`tests/`) - C++ Validation Layer

**Purpose**: Fast, isolated testing of individual C++ components

**Characteristics**:
- **Framework**: GoogleTest (industry standard C++ testing)
- **Execution Time**: ⚡ Milliseconds (very fast feedback)
- **Environment**: Isolated from Godot engine
- **Scope**: Individual classes, functions, and design patterns
- **Automation**: Fully automated via `run_tests.sh`

**Directory Structure**:
```
tests/
├── medical_equipment/          # Healthcare simulation unit tests
│   ├── test_bed_base.cpp      # Abstract bed class validation
│   ├── test_patient_bed.cpp   # Patient bed implementation
│   ├── test_surgical_bed.cpp  # Surgical bed implementation
│   └── test_bed_factory.cpp   # Factory pattern testing
├── window_controls/            # UI interaction unit tests
│   ├── test_window.cpp        # Window management testing
│   ├── test_state_pattern.cpp # State pattern validation
│   ├── test_shade_states.cpp  # Shade behavior testing
│   └── test_curtain_states.cpp # Curtain state testing
├── core/                       # Extension framework tests
│   ├── test_extension_registry.cpp # Registration testing
│   └── test_lifecycle_management.cpp # Lifecycle validation
├── shared/                     # Common testing utilities
│   ├── mocks/                 # Mock Godot objects
│   ├── utils/                 # Test helper functions
│   └── README.md              # Utilities documentation
├── CMakeLists.txt             # Build configuration
├── run_tests.sh               # Test execution script
└── README.md                  # Unit testing documentation
```

**Usage Examples**:
```cpp
// Example unit test for PatientBed
TEST_F(PatientBedTest, SetPatientUpdatesInternalState) {
    PatientBed bed;
    Patient patient("John Doe", 35);
    
    bed.set_patient(patient);
    
    EXPECT_EQ(bed.get_patient_name(), "John Doe");
    EXPECT_TRUE(bed.is_occupied());
}

// Example factory pattern test
TEST_F(BedFactoryTest, CreatePatientBedReturnsCorrectType) {
    BedFactory factory;
    
    auto bed = factory.createBed(BedType::PATIENT);
    
    ASSERT_NE(bed, nullptr);
    EXPECT_EQ(bed->get_bed_type(), BedType::PATIENT);
}
```

**When to Use**:
- ✅ Testing individual C++ classes and methods
- ✅ Validating design pattern implementations
- ✅ Ensuring algorithmic correctness
- ✅ Development-time regression testing
- ✅ Continuous integration validation

### 2. 🔗 Integration Tests (`integration_tests/`) - Extension-Engine Layer

**Purpose**: Automated testing of extension integration with Godot engine

**Characteristics**:
- **Framework**: GDScript testing within Godot environment
- **Execution Time**: 🔄 Medium (requires Godot startup)
- **Environment**: Godot runtime with scripting access
- **Scope**: Extension registration, API communication, signal handling
- **Automation**: Can be automated via Godot command line

**Directory Structure**:
```
integration_tests/
├── test_medical_extension.gd   # Medical equipment integration tests
├── test_extension.gd           # Window controls integration tests
├── test_extension.tscn         # Test scene for integration
└── README.md                   # Integration testing guide
```

**Usage Examples**:
```gdscript
# Example GDScript integration test
extends Node

func test_medical_bed_creation():
    var factory = BedFactory.new()
    var bed = factory.create_bed_by_type(BedFactory.BedType.PATIENT)
    
    assert(bed != null, "Bed should be created successfully")
    assert(bed.has_method("set_patient"), "Bed should have set_patient method")

func test_extension_registration():
    assert(ClassDB.class_exists("PatientBed"), "PatientBed should be registered")
    assert(ClassDB.class_exists("SurgicalBed"), "SurgicalBed should be registered")
    assert(ClassDB.class_exists("BedFactory"), "BedFactory should be registered")

func test_signal_communication():
    var bed = PatientBed.new()
    var signal_received = false
    
    bed.connect("emergency_triggered", func(): signal_received = true)
    bed.trigger_emergency()
    
    assert(signal_received, "Emergency signal should be emitted")
```

**When to Use**:
- ✅ Testing extension registration with Godot
- ✅ Validating signal and method exposure
- ✅ Ensuring proper API integration
- ✅ Testing cross-language communication (C++ ↔ GDScript)
- ✅ Automated regression testing of extension interface

### 3. 👁️ Visual Tests (`test_project/`) - User Experience Layer

**Purpose**: Interactive and visual validation of complete functionality

**Characteristics**:
- **Framework**: Full Godot project with scenes and scripts
- **Execution Time**: 🐌 Slower (requires full Godot environment)
- **Environment**: Complete Godot editor and runtime environment
- **Scope**: End-to-end user experience, visual verification, gameplay testing
- **Automation**: Manual testing, visual inspection required

**Directory Structure**:
```
test_project/
├── project.godot              # Godot project configuration
├── scenes/                    # Test scenes for each extension
│   ├── MedicalTest.tscn      # Medical equipment testing scene
│   ├── WindowTest.tscn       # Window controls testing scene
│   └── IntegrationTest.tscn  # Combined functionality testing
├── scripts/                   # GDScript testing scripts
│   ├── MedicalTestController.gd
│   ├── WindowTestController.gd
│   └── TestRunner.gd
├── resources/                 # Test assets and resources
└── TESTING_GUIDE.md          # Visual testing instructions
```

**Usage Examples**:
```gdscript
# Example visual test controller
extends Control

@onready var factory = BedFactory.new()
@onready var status_label = $StatusLabel

func _on_create_patient_bed_pressed():
    var bed = factory.create_bed_by_type(BedFactory.BedType.PATIENT)
    bed.position = Vector2(100, 100)
    add_child(bed)
    status_label.text = "Patient bed created successfully"

func _on_test_emergency_pressed():
    var beds = get_children().filter(func(child): return child is PatientBed)
    for bed in beds:
        bed.trigger_emergency()
    status_label.text = "Emergency triggered on all beds"

func _on_test_lighting_pressed():
    var beds = get_children().filter(func(child): return child is PatientBed)
    for bed in beds:
        bed.activate_lights()
        bed.set_light_brightness(0.8)
    status_label.text = "Lighting activated and configured"
```

**When to Use**:
- ✅ Manual verification of user interface elements
- ✅ Visual confirmation of animations and effects
- ✅ Interactive testing of user workflows
- ✅ Performance testing under realistic conditions
- ✅ User experience validation
- ✅ Demonstration and showcase purposes

## 🔄 Recommended Testing Workflow

### 1. **Development Phase** (Primary: Unit Tests)
```bash
# Fast feedback during development
cd tests/
./run_tests.sh --suite medical     # Test specific extension
./run_tests.sh --verbose           # Detailed output for debugging
```

### 2. **Integration Phase** (Primary: Integration Tests)
```bash
# Test extension-engine communication
cd integration_tests/
godot --headless --script test_medical_extension.gd
```

### 3. **User Experience Phase** (Primary: Visual Tests)
```bash
# Open in Godot editor for interactive testing
cd test_project/
godot project.godot
# → Manually test UI, animations, and user workflows
```

### 4. **Release Phase** (All Three Tiers)
```bash
# Complete validation pipeline
./run_tests.sh                     # Unit tests
./run_integration_tests.sh         # Integration tests
# Manual visual verification       # Visual tests
```

## 📊 Testing Metrics and Coverage

### Unit Test Coverage
- **95+ test cases** across all extensions
- **5 design patterns** thoroughly tested
- **Mock objects** for isolated testing
- **Shared utilities** for code reuse
- **Automated reporting** with XML output

### Integration Test Coverage
- ✅ Extension registration validation
- ✅ Signal communication testing
- ✅ Method exposure verification
- ✅ Cross-language API testing
- ✅ Runtime behavior validation

### Visual Test Coverage
- ✅ User interface interaction
- ✅ Animation and visual effects
- ✅ Workflow and usability testing
- ✅ Performance under realistic load
- ✅ Cross-platform compatibility

## 🎯 Best Practices

### For Unit Tests (`tests/`)
- ✅ **Fast Execution**: Keep tests under 100ms each
- ✅ **Isolation**: No dependencies on external systems
- ✅ **Deterministic**: Same input always produces same output
- ✅ **Focused**: One concept per test
- ✅ **Clear Naming**: Test names describe expected behavior

### For Integration Tests (`integration_tests/`)
- ✅ **API Focus**: Test public interface, not implementation
- ✅ **Signal Testing**: Verify all signals are properly exposed
- ✅ **Error Handling**: Test error conditions and edge cases
- ✅ **Lifecycle Testing**: Test object creation and destruction
- ✅ **Platform Independence**: Avoid platform-specific assumptions

### For Visual Tests (`test_project/`)
- ✅ **User-Centric**: Test actual user workflows
- ✅ **Visual Verification**: Confirm animations and UI behavior
- ✅ **Performance Aware**: Test under realistic conditions
- ✅ **Documentation**: Provide clear testing instructions
- ✅ **Reproducible**: Document exact steps for manual testing

## 🔧 Tools and Infrastructure

### Development Tools
- **GoogleTest**: Professional C++ testing framework
- **CMake**: Build system for test compilation
- **Git**: Version control with test history
- **VS Code**: IDE with testing extensions

### Automation Tools
- **run_tests.sh**: Comprehensive test runner script
- **GitHub Actions**: Continuous integration (if configured)
- **Coverage Tools**: Code coverage analysis
- **Report Generation**: Automated test reporting

### Analysis Tools
- **Valgrind**: Memory leak detection (Linux/macOS)
- **AddressSanitizer**: Memory error detection
- **Performance Profilers**: Runtime performance analysis
- **Static Analysis**: Code quality verification

## 📚 Additional Resources

- [`tests/README.md`](tests/README.md) - Detailed unit testing documentation
- [`integration_tests/README.md`](integration_tests/README.md) - Integration testing guide
- [`test_project/TESTING_GUIDE.md`](test_project/TESTING_GUIDE.md) - Visual testing instructions
- [Godot GDExtension Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html)
- [GoogleTest Documentation](https://google.github.io/googletest/)

---

This three-tier testing architecture ensures comprehensive validation while maintaining efficiency and clarity at each level of the testing pyramid.