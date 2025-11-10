# 💡 Using C++ LightStrip in Surgical Bed Scene

## Current Status
You've added a visual LightStrip node to your surgical bed scene, but it's using GDScript functionality. I've created a Godot-compatible wrapper for your C++ LightStrip class so you can use the Strategy pattern!

## New C++ Integration Available

### Files Created:
- `extensions/medical_equipment/godot_light_strip.h` - Godot wrapper class
- `extensions/medical_equipment/godot_light_strip.cpp` - Implementation  
- Updated `register_types.cpp` to register `GodotLightStrip` class

## How to Use C++ LightStrip in Your Scene

### Option 1: Replace Current LightStrip Node
```gdscript
# In SurgicalBed.gd, replace the current @onready declaration:
# OLD: @onready var light_strip = $LightStrip  # Sprite2D node
# NEW: @onready var cpp_light_strip = $GodotLightStrip  # C++ Strategy Pattern

func setup_bed():
    # Initialize C++ LightStrip with Strategy Pattern
    if cpp_light_strip:
        cpp_light_strip.set_normal_behavior()
        cpp_light_strip.set_brightness(0.3)  # Dim initially
        print("💡 C++ LightStrip initialized with Strategy Pattern")

func activate_sterile_mode():
    # Use C++ Strategy Pattern for different lighting behaviors
    if cpp_light_strip:
        cpp_light_strip.set_emergency_behavior()  # Switch strategy
        cpp_light_strip.set_color(255, 255, 255)  # Pure white sterile light
        cpp_light_strip.set_brightness(1.0)       # Full brightness
        cpp_light_strip.activate()
```

### Option 2: Use Both (Hybrid Approach)
```gdscript
# Keep visual light_strip for rendering, use cpp_light_strip for logic
@onready var light_strip = $LightStrip           # Visual (Sprite2D)
@onready var cpp_light_strip = $GodotLightStrip  # Logic (C++ Strategy Pattern)

func update_lighting():
    # Use C++ logic to determine lighting state
    cpp_light_strip.set_brightness(0.8)
    var brightness = cpp_light_strip.get_brightness()
    var behavior = cpp_light_strip.get_current_behavior()
    
    # Apply to visual sprite
    light_strip.modulate.a = brightness
    print("💡 C++ Behavior: ", behavior, " Brightness: ", brightness)
```

## Available C++ LightStrip Methods

```gdscript
# Activation
cpp_light_strip.activate()
cpp_light_strip.deactivate()

# Strategy Pattern - Different Behaviors
cpp_light_strip.set_normal_behavior()      # Normal operating mode
cpp_light_strip.set_emergency_behavior()   # Emergency/sterile mode

# Lighting Control
cpp_light_strip.set_brightness(0.8)        # 0.0 to 1.0
cpp_light_strip.set_color(255, 255, 255)   # RGB values

# State Queries
var is_on = cpp_light_strip.is_active()
var brightness = cpp_light_strip.get_brightness()
var behavior = cpp_light_strip.get_current_behavior()
```

## Benefits of Using C++ LightStrip

✅ **Strategy Pattern**: Switch between Normal/Emergency lighting behaviors
✅ **Performance**: C++ logic for complex lighting calculations  
✅ **Extensibility**: Easy to add new lighting behaviors
✅ **Professional Architecture**: Demonstrates design patterns
✅ **Observer Pattern**: Can notify other systems of lighting changes

## Next Steps

1. **Build the extension** with new GodotLightStrip class
2. **Add GodotLightStrip node** to your surgical bed scene
3. **Update SurgicalBed.gd** to use C++ methods
4. **Test Strategy Pattern** switching between normal/emergency modes

This gives you the full power of your C++ Strategy Pattern in your Godot scene! 🎯