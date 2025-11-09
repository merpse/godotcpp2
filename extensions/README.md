
# � Medical Equipment C++ Extension

This folder contains the C++ source code for the Medical Equipment Extension demonstrating professional healthcare simulation with C++ objects providing asset interactions for Godot 4.5+.

## 📁 C++ Extension Structure

### 🏥 Medical Equipment (`medical_equipment/`)
C++ objects providing advanced healthcare simulation and asset control:
- **Design Patterns**: Factory, Strategy, Template Method, Observer, Composite (all in C++)
- **C++ Objects**: BedFactory, PatientBed, SurgicalBed providing medical equipment control
- **Asset Control**: C++ objects manage sprites for beds, lighting, monitors, and scanners
- **Enhanced Features (2025)**: RGB lighting control, emergency mode, automated scanner movement

### 🪟 Window Controls (`window_controls/`)  
C++ objects for monitor and scanner asset management:
- **Design Patterns**: State Pattern in C++ for window/monitor control
- **C++ Objects**: CustomWindow providing monitor and scanner sprite control
- **Asset Control**: C++ state management for medical device visual states

### 🎯 Core Framework (`core/`)
C++ extension registration and lifecycle:
- **Registration**: All C++ extension objects registered with Godot in register_types.cpp
- **Configuration**: C++ extension metadata and initialization
- **Lifecycle**: C++ extension loading and dependency management

## 🏗️ C++ Extension Architecture Benefits

### C++ Objects Control Visual Assets
- **BedFactory** - C++ Factory Pattern creates bed objects that control bed sprites
- **PatientBed** - C++ Template Method + Strategy objects control patient care assets  
- **SurgicalBed** - C++ Observer + Composite objects manage surgical environment
- **CustomWindow** - C++ State Pattern objects control monitor/scanner sprite states

### Professional C++ Design Patterns
- **Factory Pattern** (C++) - BedFactory centralizes bed object creation
- **Strategy Pattern** (C++) - Dynamic lighting behavior via C++ objects
- **State Pattern** (C++) - CustomWindow state management for asset control
- **Template Method** (C++) - Bed base class provides consistent workflows
- **Observer Pattern** (C++) - Emergency system with C++ observers
- **Composite Pattern** (C++) - Medical device hierarchy in C++ objects

### C++ Extension → Asset Integration
```
C++ Extension Directory Structure:
├── medical_equipment/         # C++ medical equipment object source
│   ├── bed.h/cpp              # Abstract Bed base class (Template Method)
│   ├── patient_bed.h/cpp      # PatientBed C++ object (controls patient sprites)
│   ├── surgical_bed.h/cpp     # SurgicalBed C++ object (controls surgical environment)
│   ├── bed_factory.h/cpp      # BedFactory C++ object (Factory Pattern)
│   ├── light_strip.h          # C++ Strategy Pattern lighting objects
│   └── medical_devices.h      # C++ Composite Pattern device objects
├── window_controls/           # C++ window/monitor object source
│   ├── window.h/cpp           # CustomWindow C++ object (controls monitor sprites)
│   ├── curtain_state.h        # C++ State Pattern interfaces
│   ├── shade_state.h          # C++ Shade behavior interfaces
│   └── *_state.cpp           # C++ State implementations for asset control
└── core/                      # C++ extension framework
    ├── register_types.cpp     # Registers all C++ objects with Godot
    └── extension_config.json  # C++ extension metadata
```

## 🔧 C++ Extension Build System

The CMake build system compiles all C++ extension objects into a single library:

```cmake
# C++ extension compilation structure:
extensions/core/register_types.cpp         # Registers BedFactory, PatientBed, SurgicalBed, CustomWindow
extensions/window_controls/*.cpp           # CustomWindow C++ object compilation
extensions/medical_equipment/*.cpp         # Medical equipment C++ objects compilation

# Output: bin/libWindowExtension.*.dylib   # Contains all C++ objects for asset control
```

## 🚀 C++ Extension Usage

Each C++ extension folder contains:
- **C++ Source Files** (`.h/.cpp`) - C++ object implementations providing asset control
- **README.md** - C++ object documentation and asset integration guides
- **Design Documents** - C++ design patterns and asset control architecture

## 🎮 C++ Extension → Asset Demo Integration

C++ extension objects are demonstrated through:
- **MedicalEquipmentDemo.tscn** - Interactive demo using C++ objects to control medical assets
- **MedicalEquipmentDemo.gd** - GDScript interfacing with C++ extension objects
- **Simulation Fallback** - Demo works with or without C++ extension loading

## 📋 C++ Extension Object Registry

| C++ Object | Design Patterns | Asset Control Purpose |
|------------|----------------|---------------------|
| BedFactory | Factory Pattern | Creates bed objects that control bed sprites |
| PatientBed | Template Method + Strategy | Controls patient bed sprites and comfort features |
| SurgicalBed | Observer + Composite | Controls surgical bed sprites, RGB lighting, emergency mode, scanner automation |
| CustomWindow | State Pattern | Controls monitor and scanner sprite states |

## 🎉 Benefits of C++ Extension Architecture

1. **C++ Backend Control** - All asset interactions managed by C++ extension objects
2. **Design Pattern Demonstrations** - 5 patterns implemented in C++ backend
3. **Professional Asset Management** - C++ objects provide structured sprite control
4. **Scalable C++ Architecture** - Easy to add new C++ medical equipment objects
5. **Dual-Mode Support** - C++ extensions with simulation fallback for development

## 🏗️ Quick C++ Extension Build Instructions

```bash
# From project root (godotcpp2/)
cmake -B build
cmake --build build --parallel

# Verify C++ extension library creation
ls -la bin/libWindowExtension.*.dylib

# Test C++ extension objects
./test_extension.sh

# Run C++ object demo in Godot
# Open MedicalEquipmentDemo.tscn in Godot editor
```

## 📊 C++ Extension Development Status

| Component | Status | Description |
|-----------|--------|-------------|
| C++ Extension Compilation | ✅ Complete | All C++ objects compile to .dylib library |
| C++ Object Registration | ✅ Complete | BedFactory, PatientBed, SurgicalBed, CustomWindow registered |
| Asset Control Architecture | ✅ Complete | C++ objects designed to control visual assets |
| Demo Integration | ✅ Complete | Demo interfaces with C++ objects (with simulation fallback) |
| Documentation | ✅ Complete | Comprehensive C++ extension documentation |

## 🧹 Clean C++ Extension Architecture

This C++ extension has been professionally organized with:
- ✅ **Modern C++ Design** - C++17 features with Godot 4.5 GDExtension
- ✅ **Asset Control Objects** - C++ objects specifically designed for sprite management
- ✅ **Design Pattern Implementation** - 5 patterns implemented in C++ backend
- ✅ **Professional Build System** - CMake with parallel compilation
- ✅ **Comprehensive Testing** - Unit tests for all C++ extension objects

### 4. Installation in Godot Project
1. Copy `window.gdextension` to your Godot project root
2. Copy the `bin/` directory to your Godot project
3. The Window class will be available in Godot

### 5. Usage in GDScript
```gdscript
extends Node

func _ready():
    # Create a CustomWindow instance (renamed to avoid conflict with Godot's Window)
    var custom_window = CustomWindow.new()
    add_child(custom_window)
    
    # Use the window methods
    custom_window.apply_shade()      # Prints: "No shade state set"
    custom_window.operate_curtain()  # Prints: "No curtain state set"
```

## 🏗️ Architecture
- **CustomWindow**: Main Node class with shade and curtain functionality
- **ShadeState**: Abstract interface for window shade behaviors
- **CurtainState**: Abstract interface for curtain behaviors
- **State Implementations**: Opaque, Transparent, ClosedCurtain classes

## 🚨 Known Issues & Troubleshooting

### Issue 1: `mem_alloc2` Interface Error
```
ERROR: Attempt to get non-existent interface function: 'mem_alloc2'.
ERROR: Unable to load GDExtension interface function mem_alloc2()
```

**Cause**: Version mismatch between Godot 4.5.1 and godot-cpp 4.5-stable branch.

**Solutions**:
1. **Use compatible Godot build**: Try Godot 4.5.0 or development builds
2. **Try different godot-cpp version**:
   ```bash
   cd godot-cpp
   git checkout godot-4.3-stable  # Try older version
   scons --clean
   scons platform=macos target=template_debug
   ```
3. **Update compatibility setting** in `window.gdextension`:
   ```ini
   [configuration]
   entry_symbol = "window_library_init"
   compatibility_minimum = "4.3"  # Try lower version
   ```

### Issue 2: GDScript Parse Errors
If you see "Parse Error" in test scripts, use the fixed version:
```bash
cp test_project/main_simple_fixed.gd test_project/main_simple.gd
```

## 📝 Step-by-Step Build Instructions

### Complete Build Process
```bash
# 1. Clone and prepare godot-cpp
git clone https://github.com/godotengine/godot-cpp.git
cd godot-cpp
git checkout godot-4.5-stable
git submodule update --init

# 2. Build godot-cpp (this takes time)
scons platform=macos target=template_debug -j$(sysctl -n hw.logicalcpu)
scons platform=macos target=template_release -j$(sysctl -n hw.logicalcpu)

# 3. Build the extension
cd ../window
scons platform=macos target=template_debug
scons platform=macos target=template_release

# 4. Verify build outputs
ls -la ../bin/
# Should show:
# libwindow.macos.template_debug.dylib
# libwindow.macos.template_release.dylib
```

### Testing the Extension
```bash
cd ../test_project
godot --headless project.godot --quit
```

If successful, you should see:
```
✅ CustomWindow class found!
✅ CustomWindow instance created successfully
No shade state set
No curtain state set
```

### Alternative Testing (Without Extension Loading)
If the extension fails to load, you can test Godot itself:
```bash
# Create a minimal test project
mkdir minimal_test && cd minimal_test
echo '[gd_scene format=3]' > test.tscn
echo 'extends Node
func _ready(): print("Godot is working!")' > test.gd

# Test Godot runs
godot --headless test.tscn --quit
```

### Debugging Extension Loading
1. **Check file permissions**:
   ```bash
   chmod +x ../bin/libwindow.macos.template_debug.dylib
   ```

2. **Verify godot-cpp compatibility**:
   ```bash
   cd ../godot-cpp
   git log --oneline -1  # Should show 4.5-stable commit
   ```

3. **Test with different Godot versions**:
   - Download Godot 4.5.0 instead of 4.5.1
   - Try Godot development builds

## 🧪 Unit Testing

This project includes a comprehensive unit testing framework using Google Test (gtest) with custom mock objects.

### Quick Test Run
```bash
cd tests/
./run_tests.sh
```

### Test Results
- ✅ **30 test cases** covering all functionality
- ⚡ **~20ms execution time** 
- 🔍 **100% pass rate**
- 🎯 **Zero dependencies** on Godot runtime

### Test Coverage
- **CustomWindow Tests**: Constructor, state management, method calls
- **State Pattern Tests**: Interface validation, polymorphism, transitions
- **Mock System Tests**: Framework validation, memory management, stress testing

For detailed testing documentation, see [`tests/README.md`](tests/README.md).

### Adding New Tests
1. Create `test_*.cpp` file in `tests/` directory
2. Include `#include "mocks/godot_mock.h"`
3. Use Google Test macros (`EXPECT_*`, `ASSERT_*`)
4. Update `CMakeLists.txt` and rebuild

## 🔧 Development Workflow

### Making Changes to the Extension
1. **Modify C++ code** in `window/` directory
2. **Rebuild the extension**:
   ```bash
   cd window
   scons platform=macos target=template_debug
   ```
3. **Test in Godot** (restart Godot Editor if needed)

### Adding New Methods
1. **Declare in header** (`window.h`)
2. **Implement in source** (`window.cpp`)
3. **Bind in GDScript** (`_bind_methods()`)
4. **Rebuild and test**

## ✅ Build Status
- ✅ Debug build: `libwindow.macos.template_debug.dylib` 
- ✅ Release build: `libwindow.macos.template_release.dylib`
- ✅ Extension properly registered as `CustomWindow` class
- ✅ No naming conflicts with Godot's built-in Window class
- ✅ **Unit tests**: 30/30 tests pass successfully
- ✅ **Testing framework**: Google Test with mock objects
- ⚠️ Known version compatibility issue with Godot 4.5.1

## 📚 Documentation

- [`README.md`](README.md) - This file (setup and usage)
- [`tests/README.md`](tests/README.md) - Unit testing framework documentation
- [`../TROUBLESHOOTING.md`](../TROUBLESHOOTING.md) - Detailed troubleshooting guide
- [`../STATUS.md`](../STATUS.md) - Complete project status
