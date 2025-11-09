# 🔄 Integration Tests

This directory contains **Godot-level integration tests** that are part of our **three-tier testing architecture**.

## 🏗️ Testing Architecture Position

This is the **middle tier** of our testing pyramid:

```
                Three-Tier Testing Architecture
                ──────────────────────────────
                                    
    🔬 Unit Tests        🔗 Integration Tests      👁️  Visual Tests
    (tests/)             (integration_tests/)      (test_project/)
    ──────────           ────────────────────      ──────────────
    C++ Isolation        Extension ↔ Godot        User Experience
    Fast (ms)            Medium Speed (sec)        Slower (manual)
    GoogleTest           GDScript Tests            Interactive Demo
```

## 📁 Integration Tests Purpose

**Integration tests** verify extension functionality within the Godot engine runtime:
- ✅ **Extension Loading**: Verify extensions load properly in Godot
- ✅ **GDScript Integration**: Test extension APIs from GDScript  
- ✅ **Scene Integration**: Test extensions in actual Godot scenes
- ✅ **Runtime Behavior**: Verify extensions work in Godot environment
- ✅ **Signal Communication**: Test C++ to GDScript signal flow
- ✅ **Method Exposure**: Verify all public methods are accessible

## 📊 Three-Tier Comparison

### 🔬 **Unit Tests** (`../tests/`) - Foundation Layer
- **Purpose**: Test individual C++ classes in isolation
- **Dependencies**: None (uses mock objects)
- **Speed**: ⚡ Very fast (milliseconds) 
- **Coverage**: Code logic, design patterns, algorithms
- **Execution**: `cd ../tests && ./run_tests.sh`
- **When to Use**: During C++ development, debugging logic

### � **Integration Tests** (`./`) - Communication Layer
- **Purpose**: Test extensions within Godot engine
- **Dependencies**: Godot runtime, compiled extensions
- **Speed**: 🔄 Medium (seconds)
- **Coverage**: Extension loading, GDScript APIs, scene behavior
- **Execution**: Godot engine required
- **When to Use**: After compilation, before user testing

### 👁️ **Visual Tests** (`../test_project/`) - Experience Layer  
- **Purpose**: Interactive and visual validation
- **Dependencies**: Full Godot environment
- **Speed**: 🐌 Slower (manual testing)
- **Coverage**: UI, animations, user workflows
- **Execution**: Open in Godot editor
- **When to Use**: Final verification, demonstrations

## 🗂️ File Organization

### **Current Integration Tests**
```
integration_tests/
├── test_medical_extension.gd     # Medical equipment extension integration test
├── test_extension.gd             # Window controls extension integration test
├── test_extension.tscn           # Test scene for extension verification
├── legacy_window.gdextension     # Legacy extension config (reference)
├── window.gdextension.uid        # Godot UID file
├── test_extension.gd.uid         # Godot UID file
└── README.md                     # This file
```

### **Medical Equipment Integration Test** (`test_medical_extension.gd`)
Tests the healthcare simulation extension through GDScript:
- 🏭 **Factory Pattern**: Create beds via BedFactory
- 🏥 **Patient Bed**: Test patient-specific functionality
- ⚕️ **Surgical Bed**: Test surgical-specific features with enhanced controls
- 💡 **Advanced Lighting**: Test RGB color control system (red, green, blue)
- 🚨 **Emergency Mode**: Test one-click emergency activation with blinking
- 🔬 **Scanner Control**: Test automated movement and scan sequences
- �️ **Mouse Interaction**: Test collision detection and visual feedback
- 🎮 **Control Integration**: Test proper mode switching and state management
- 📊 **Real-time Status**: Test live status updates and equipment monitoring

### **Window Controls Integration Test** (`test_extension.gd`)  
Tests the window management extension through GDScript:
- 🪟 **CustomWindow**: Test window creation and management
- 🎨 **Shade Operations**: Test shade state changes
- 🔄 **Curtain Operations**: Test curtain state management

### **Legacy Files**
- **`legacy_window.gdextension`**: Old extension configuration (kept for reference)
- **`*.uid`**: Godot unique ID files for resource tracking

## 🚀 Running Integration Tests

### **Prerequisites**
1. **Compiled Extensions**: Ensure extensions are built (`../bin/libWindowExtension.*.dylib`)
2. **Godot 4.5+**: Compatible Godot engine installation
3. **Project Setup**: Main project configured with extension manifest

### **Method 1: Individual GDScript Tests**
```bash
# Test medical equipment extension
godot --headless --script integration_tests/test_medical_extension.gd ../project.godot

# Test window controls extension  
godot --headless --script integration_tests/test_extension.gd ../project.godot
```

### **Method 2: Scene-Based Testing**
```bash
# Load and run test scene
godot integration_tests/test_extension.tscn
```

### **Method 3: Interactive Testing**
```bash
# Open Godot project and run integration tests interactively
cd ..
godot project.godot
# Then run the integration test scripts from within Godot
```

## 📋 Expected Test Output

### **Medical Equipment Integration Test**
```
=== Medical Equipment Extension Test ===

🏭 Testing Factory Pattern:
Creating Patient Bed...
✅ Patient bed created successfully
Testing patient admission...
Testing light controls...

⚕️ Testing Surgical Bed:
Creating Surgical Bed...
✅ Surgical bed created successfully
Testing sterile mode...
Testing surgical procedures...

🚨 Testing Observer Pattern:
Testing emergency alerts...
✅ Emergency system functional

🎉 All medical equipment tests passed!
```

### **Window Controls Integration Test**
```
Testing CustomWindow extension with Godot 4.5.0...
Testing shade operations...
Testing curtain operations...
CustomWindow extension test completed successfully!
```

## 🔧 Development Workflow

### **Complete Testing Strategy**
```bash
# 1. Run unit tests first (fast feedback)
cd tests && ./run_tests.sh

# 2. Build extensions if tests pass
cd .. && cmake --build build --parallel

# 3. Run integration tests (verify Godot integration)
godot --headless --script integration_tests/test_medical_extension.gd project.godot

# 4. Manual testing in Godot (if needed)
godot project.godot
```

### **Adding New Integration Tests**

#### **For New Extensions**
1. Create `test_[extension_name].gd` in this directory
2. Follow the pattern of existing integration tests
3. Test extension loading and basic functionality
4. Verify GDScript API accessibility

#### **Example Integration Test Template**
```gdscript
# [Extension Name] Integration Test
extends Node

func _ready():
    print("=== [Extension Name] Integration Test ===")
    
    # Test extension loading
    var extension_object = ExtensionClass.new()
    if extension_object:
        print("✅ Extension loaded successfully")
        
        # Test specific functionality
        test_basic_functionality()
        test_advanced_features()
        
        print("🎉 Integration test completed!")
    else:
        print("❌ Extension failed to load")
    
    get_tree().quit()

func test_basic_functionality():
    # Add your extension-specific tests here
    pass

func test_advanced_features():
    # Add advanced feature tests here
    pass
```

## 🎯 Integration vs Unit Testing

| Aspect | Unit Tests | Integration Tests |
|--------|------------|-------------------|
| **Speed** | Very fast (< 1 second) | Slower (5-30 seconds) |
| **Isolation** | Complete (mocked dependencies) | Real environment |
| **Coverage** | Code logic, algorithms | Extension loading, APIs |
| **Dependencies** | None | Godot engine required |
| **Debugging** | Easy (direct C++) | Harder (through Godot) |
| **CI/CD** | Always run | Run after unit tests pass |
| **Purpose** | Verify code correctness | Verify system integration |

## 📈 Best Practices

### **Integration Test Guidelines**
- ✅ **Keep Simple**: Focus on extension loading and basic API access
- ✅ **Test Real Scenarios**: Use actual use cases, not just API calls
- ✅ **Quick Execution**: Aim for tests that complete in under 30 seconds
- ✅ **Clear Output**: Provide clear pass/fail feedback
- ✅ **Error Handling**: Gracefully handle extension loading failures

### **When to Add Integration Tests**
- 🔄 **New Extension**: Always create integration test for new extensions
- 🔌 **GDScript API Changes**: Test API accessibility from GDScript
- 🎮 **Scene Integration**: Test extensions in actual game scenes
- 🐛 **Bug Reports**: Reproduce integration issues

## 🚨 Troubleshooting

### **Common Issues**

#### **Extension Not Loading**
```bash
# Check if extension binary exists
ls -la ../bin/libWindowExtension.*

# Verify extension manifest
cat ../medical_equipment.gdextension

# Check Godot console output
godot --verbose integration_tests/test_medical_extension.gd
```

#### **API Not Available in GDScript**
- Ensure extension classes are properly registered in `register_types.cpp`
- Check that class binding is correct in C++ code
- Verify extension is loaded before creating objects

#### **Test Scene Issues**
- Ensure scene file is compatible with Godot 4.5+
- Check that extension dependencies are met
- Verify scene script paths are correct

---

**🎯 Integration tests provide the final verification that our organized GDExtension collection works properly within the Godot engine environment!**