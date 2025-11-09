# 🎮 Godot Extensions Usage Guide

## Overview

This guide provides **step-by-step instructions** for adding and using the Extensions Collection in your Godot projects. Our collection includes Medical Equipment, Window Controls, and Core Framework extensions.

---

## 🚀 Quick Start: Adding Extensions to Nodes

### 1. **Setup Requirements**

Before using extensions in your Godot project:

✅ **Extension Built**: Ensure you've built the extensions
```bash
cmake -B build && cmake --build build --parallel
```

✅ **Extension File**: Copy `test_project/window.gdextension` to your project root  
✅ **Library File**: Copy `bin/libwindow.*.dylib` to your project  
✅ **Godot Version**: Use Godot 4.5 or newer

### 2. **Basic Extension Usage Pattern**

#### **Standard Node Setup**
```gdscript
# In any GDScript file (extends Node, Control, Node2D, etc.)
extends Node  # or Control, Node2D, etc.

func _ready():
    # Extensions are automatically available once loaded
    create_medical_equipment()
    setup_window_controls()
```

#### **Medical Equipment Usage**
```gdscript
extends Node

func _ready():
    # Create factory instance
    var factory = BedFactory.new()
    
    # Create medical beds
    var patient_bed = factory.create_bed_by_type(BedFactory.BedType.PATIENT)
    var surgical_bed = factory.create_bed_by_type(BedFactory.BedType.SURGICAL)
    
    # Add to scene tree (optional - depends on your use case)
    add_child(patient_bed)
    add_child(surgical_bed)
    
    # Use extension features
    setup_patient_care(patient_bed)
    setup_surgical_environment(surgical_bed)

func setup_patient_care(bed):
    # Patient-specific features
    bed.enable_comfort_mode()
    bed.activate_lights()
    bed.set_light_brightness(0.7)
    bed.simulate_family_visit()
    
func setup_surgical_environment(bed):
    # Surgical-specific features
    bed.enter_sterile_mode()
    bed.start_procedure("surgery_demo")
    bed.integrate_medical_device()
```

#### **Window Controls Usage**
```gdscript
extends Node

func _ready():
    # Create window control
    var window_control = CustomWindow.new()
    add_child(window_control)
    
    # Use state pattern features
    setup_window_behavior(window_control)

func setup_window_behavior(window):
    # State pattern in action
    window.apply_shade()        # Uses current state
    window.operate_curtain()    # Uses current curtain state
    
    # Change states dynamically (if methods are exposed)
    # window.set_transparency(0.5)  # Example of state change
```

---

## 📋 Complete Integration Examples

### **Example 1: Medical Equipment in a Hospital Scene**

```gdscript
# HospitalRoom.gd
extends Node2D

# Medical equipment references
var patient_bed: Node
var surgical_bed: Node
var bed_factory: BedFactory

# Room management
var room_number: int = 101
var patient_name: String = ""

func _ready():
    setup_medical_room()

func setup_medical_room():
    print("🏥 Setting up Hospital Room ", room_number)
    
    # Initialize medical equipment factory
    bed_factory = BedFactory.new()
    
    # Create patient bed
    patient_bed = bed_factory.create_bed_by_type(BedFactory.BedType.PATIENT)
    patient_bed.set_name("PatientBed_Room" + str(room_number))
    patient_bed.position = Vector2(100, 200)
    add_child(patient_bed)
    
    # Configure patient comfort
    patient_bed.enable_comfort_mode()
    patient_bed.activate_lights()
    patient_bed.set_light_brightness(0.6)
    
    print("✅ Patient bed ready")

func admit_patient(name: String):
    patient_name = name
    print("👤 Admitting patient: ", name)
    
    # Use Template Method Pattern
    patient_bed.perform_bed_operation()
    
    # Simulate patient care
    patient_bed.simulate_family_visit()

func trigger_emergency():
    print("🚨 EMERGENCY TRIGGERED")
    
    # Observer Pattern - All systems notified
    patient_bed.trigger_emergency()
    
    # Emergency lighting (Strategy Pattern)
    patient_bed.set_light_brightness(1.0)  # Full brightness

func _on_emergency_button_pressed():
    trigger_emergency()

func _on_comfort_slider_changed(value: float):
    patient_bed.set_light_brightness(value)
```

### **Example 2: Window Management in UI Scene**

```gdscript
# WindowManager.gd
extends Control

var main_window: CustomWindow
var dialog_windows: Array[CustomWindow] = []

func _ready():
    setup_window_system()

func setup_window_system():
    print("🪟 Initializing Window Management System")
    
    # Create main window
    main_window = CustomWindow.new()
    main_window.set_name("MainWindow")
    add_child(main_window)
    
    # Configure window behavior
    main_window.apply_shade()
    main_window.operate_curtain()
    
    print("✅ Window system ready")

func create_dialog_window(title: String) -> CustomWindow:
    var dialog = CustomWindow.new()
    dialog.set_name("Dialog_" + title)
    add_child(dialog)
    
    dialog_windows.append(dialog)
    
    # Apply different state than main window
    dialog.apply_shade()
    
    return dialog

func close_all_dialogs():
    for dialog in dialog_windows:
        dialog.queue_free()
    dialog_windows.clear()

func _on_window_mode_changed(mode: String):
    match mode:
        "transparent":
            # Switch to transparent state (if method exists)
            main_window.apply_shade()
        "opaque":
            # Switch to opaque state (if method exists)  
            main_window.apply_shade()
```

### **Example 3: Combined Extensions Demo**

```gdscript
# ExtensionsDemo.gd
extends Control

# Extension instances
var bed_factory: BedFactory
var medical_beds: Array = []
var window_controls: Array = []

func _ready():
    setup_comprehensive_demo()

func setup_comprehensive_demo():
    print("🎯 Starting Comprehensive Extensions Demo")
    
    # Initialize all extension types
    setup_medical_equipment()
    setup_window_controls()
    setup_integration_features()

func setup_medical_equipment():
    print("🏥 Setting up Medical Equipment...")
    
    bed_factory = BedFactory.new()
    
    # Create different bed types
    var beds_config = [
        {"type": BedFactory.BedType.PATIENT, "name": "Patient_01"},
        {"type": BedFactory.BedType.SURGICAL, "name": "Surgery_01"}
    ]
    
    for config in beds_config:
        var bed = bed_factory.create_bed_by_type(config.type)
        bed.set_name(config.name)
        add_child(bed)
        medical_beds.append(bed)
        
        # Configure based on type
        if config.type == BedFactory.BedType.PATIENT:
            configure_patient_bed(bed)
        else:
            configure_surgical_bed(bed)

func configure_patient_bed(bed):
    bed.enable_comfort_mode()
    bed.activate_lights()
    bed.set_light_brightness(0.7)

func configure_surgical_bed(bed):
    bed.enter_sterile_mode()
    bed.integrate_medical_device()

func setup_window_controls():
    print("🪟 Setting up Window Controls...")
    
    for i in range(3):
        var window = CustomWindow.new()
        window.set_name("Window_" + str(i))
        add_child(window)
        window_controls.append(window)
        
        # Apply different states
        window.apply_shade()
        window.operate_curtain()

func setup_integration_features():
    print("🔗 Setting up Integration Features...")
    
    # Connect medical equipment to window controls
    # (Example of how extensions can work together)
    
    # Emergency mode affects all windows
    for bed in medical_beds:
        # Note: You would need to set up signals in C++ for this
        # bed.connect("emergency_triggered", _on_medical_emergency)

func _on_medical_emergency():
    print("🚨 Medical emergency detected - adjusting all systems")
    
    # Trigger emergency lighting on all beds
    for bed in medical_beds:
        bed.trigger_emergency()
    
    # Adjust window states for emergency
    for window in window_controls:
        window.apply_shade()  # Emergency transparency
```

---

## 🔧 Advanced Usage Patterns

### **1. Factory Pattern Usage**

```gdscript
# Best practice: Use factory for object creation
func create_medical_equipment():
    var factory = BedFactory.new()
    
    # Type-safe creation
    var patient_bed = factory.create_bed_by_type(BedFactory.BedType.PATIENT)
    var surgical_bed = factory.create_bed_by_type(BedFactory.BedType.SURGICAL)
    
    # String-based creation (less type-safe but more flexible)
    var emergency_bed = factory.create_bed_by_name("emergency")
    
    return {"patient": patient_bed, "surgical": surgical_bed, "emergency": emergency_bed}
```

### **2. Strategy Pattern Usage**

```gdscript
# Runtime behavior switching
func adjust_room_lighting(bed, mode: String):
    match mode:
        "day":
            bed.activate_lights()
            bed.set_light_brightness(0.6)
        "night":
            bed.activate_lights()
            bed.set_light_brightness(0.3)
        "emergency":
            bed.trigger_emergency()  # Switches to emergency strategy
            bed.set_light_brightness(1.0)
```

### **3. Observer Pattern Usage**

```gdscript
# Emergency notification system
func setup_emergency_system():
    for bed in medical_beds:
        # If signals are exposed, connect them
        # bed.connect("emergency_triggered", _on_emergency)
        pass

func _on_emergency():
    # All observers receive notification
    print("🚨 Emergency notification received")
    # Update UI, alert staff, adjust lighting, etc.
```

---

## 📱 Integration with Godot UI

### **UI Scene Setup**

```gdscript
# MainUI.gd
extends Control

@onready var bed_list = $VBoxContainer/BedList
@onready var status_label = $VBoxContainer/StatusLabel
@onready var emergency_button = $VBoxContainer/EmergencyButton

var active_beds: Array = []

func _ready():
    setup_ui_integration()

func setup_ui_integration():
    # Create medical equipment
    var factory = BedFactory.new()
    
    # Create beds and add to UI list
    for i in range(3):
        var bed = factory.create_bed_by_type(BedFactory.BedType.PATIENT)
        bed.set_name("Bed_" + str(i + 1))
        active_beds.append(bed)
        
        # Add to scene tree (required for some operations)
        add_child(bed)
        
        # Add to UI list
        var bed_item = preload("res://BedItemUI.tscn").instantiate()
        bed_item.setup_bed_display(bed)
        bed_list.add_child(bed_item)

func _on_emergency_button_pressed():
    for bed in active_beds:
        bed.trigger_emergency()
    
    status_label.text = "🚨 EMERGENCY ACTIVATED ON ALL BEDS"
```

---

## 🎯 Best Practices

### **✅ Do's**

1. **Always check extension loading**:
   ```gdscript
   if ClassDB.class_exists("BedFactory"):
       var factory = BedFactory.new()
   else:
       print("❌ Medical equipment extension not loaded")
   ```

2. **Use proper error handling**:
   ```gdscript
   func create_bed_safely():
       try:
           var factory = BedFactory.new()
           var bed = factory.create_bed_by_type(BedFactory.BedType.PATIENT)
           return bed
       except Exception as e:
           print("❌ Bed creation failed: ", e)
           return null
   ```

3. **Follow Godot node lifecycle**:
   ```gdscript
   func _ready():
       # Create extensions after scene is ready
       setup_extensions()
   
   func _exit_tree():
       # Clean up extension resources if needed
       cleanup_extensions()
   ```

### **❌ Don'ts**

1. **Don't assume extension is loaded without checking**
2. **Don't create extension objects in `_init()`** - wait for `_ready()`
3. **Don't ignore error messages** from extension loading

---

## 🔍 Troubleshooting Common Issues

### **Issue: Extension Not Found**
```gdscript
# Check if extension is loaded
if not ClassDB.class_exists("BedFactory"):
    print("❌ Extension not loaded. Check:")
    print("  - .gdextension file in project root")
    print("  - Library file in bin/ directory")
    print("  - Godot version 4.5+")
```

### **Issue: Methods Not Available**
```gdscript
# Check if object was created properly
var bed = BedFactory.new().create_bed_by_type(BedFactory.BedType.PATIENT)
if bed and bed.has_method("activate_lights"):
    bed.activate_lights()
else:
    print("❌ Bed object invalid or method not exposed")
```

### **Issue: Memory/Performance**
```gdscript
# Proper cleanup for large numbers of extension objects
func cleanup_medical_equipment():
    for bed in medical_beds:
        if is_instance_valid(bed):
            bed.queue_free()
    medical_beds.clear()
```

---

This guide provides comprehensive instructions for integrating our Extensions Collection into your Godot projects. Each extension (Medical Equipment, Window Controls, Core Framework) follows these same patterns for consistent usage across your application.

For more specific examples, see the `MedicalEquipmentDemo.gd` file and the `test_project/` demo scenes.