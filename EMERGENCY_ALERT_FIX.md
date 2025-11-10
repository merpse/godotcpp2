# Emergency Alert System - C++ Integration Test Guide

## Fixed Issues

### 1. **Emergency Blinking Integration**
- ✅ Enhanced emergency blinking to use C++ Strategy pattern
- ✅ Added safety checks for missing light_bar node  
- ✅ Added try-catch blocks for C++ extension errors
- ✅ Implemented fallback behavior when C++ is unavailable

### 2. **C++ Light Strip Initialization**
- ✅ Properly activate C++ light strip on initialization
- ✅ Set initial behavior mode (auto/manual/emergency)
- ✅ Added detailed error logging for debugging

### 3. **Scene Loading Issues**
- ✅ Updated project.godot to use debug scene as main scene
- ✅ Created debug_emergency_scene.tscn for testing
- ✅ Fixed UID reference issues in scene loading

## How to Test Emergency Alert

### Option 1: Quick Debug Test
1. **Load the debug scene in Godot:**
   - Open `debug_emergency_scene.tscn`
   - Run the scene (F6)
   - Check console output for C++ integration status

2. **Expected Output:**
   ```
   🚨 Emergency Alert Debug Test
   ========================================
   🔧 Test 1: C++ Light Strip Initialization
   ✅ GodotLightStrip class found
   ✅ GodotLightStrip instance created
   ✅ Light strip activated
   ✅ Set to auto mode: auto
   
   🚨 Test 2: Emergency Behavior  
   🔄 Switching to emergency mode...
   📊 Emergency mode: emergency
   🔆 Emergency brightness: 0.85
   ✅ Emergency mode activated successfully
   
   💡 Test 3: Emergency Blinking Simulation
   ✅ Emergency blinking test started (5 blinks)
   💡 Blink - Mode: emergency Brightness: 0.95
   💡 Blink - Mode: emergency Brightness: 0.15
   💡 Blink - Mode: emergency Brightness: 0.95
   ✅ Emergency blinking test completed
   ```

### Option 2: Full Surgical Bed Test
1. **Load the surgical bed scene:**
   - Open `scenes/beds/surgical_bed_menu.tscn` in Godot
   - Run the scene

2. **Test Emergency Mode:**
   - Click the "EMERGENCY MODE" button
   - **Expected behavior:**
     - Button text changes to "STOP EMERGENCY"
     - Button gets red tint
     - Light bar starts blinking red (bright/dim cycle)
     - Console shows C++ Strategy pattern switching to emergency mode
   
3. **Stop Emergency Mode:**
   - Click "STOP EMERGENCY" button
   - **Expected behavior:**
     - Button returns to normal
     - Light bar stops blinking and returns to normal lighting
     - Console shows C++ Strategy returning to previous mode (auto/manual)

## Troubleshooting

### If Emergency Button Doesn't Work:
1. **Check Console Output:**
   - Look for "⚠️" warning messages
   - Check if GodotLightStrip class is available
   - Verify C++ extension is loaded

2. **Common Issues:**
   ```
   ❌ GodotLightStrip class not available
   → Extension not loaded - check WindowExtension.gdextension
   
   ⚠️ Light bar node not found
   → Scene structure issue - check SVG light bar path
   
   ⚠️ Error accessing C++ light strip during blink
   → C++ extension crash - check extension build
   ```

### Fallback Behavior:
- If C++ extension fails, emergency mode still works
- Uses manual red blinking without C++ Strategy pattern
- All safety checks prevent crashes

## Technical Details

### Enhanced Emergency Functions:
```gdscript
# 1. Improved emergency start with C++ integration
func start_emergency_mode():
    # Sets C++ light strip to emergency behavior
    cpp_light_strip.set_behavior("emergency")
    # Coordinates SVG blinking with C++ calculations

# 2. Enhanced blinking with safety checks  
func _on_emergency_blink():
    # Gets brightness from C++ Strategy pattern
    var cpp_brightness = cpp_light_strip.get_brightness()
    # Applies to SVG light bar with error handling

# 3. Safe color setting with fallbacks
func _set_emergency_light_color():
    # Uses C++ brightness or falls back to manual values
```

### File Changes Made:
- `scenes/beds/surgical_bed_menu.gd` - Enhanced emergency system
- `debug_emergency_test.gd` - Standalone emergency test
- `debug_emergency_scene.tscn` - Debug scene for testing
- `project.godot` - Updated main scene reference

## Success Criteria

✅ **Emergency button click triggers red blinking**  
✅ **C++ Strategy pattern properly switches to emergency mode**  
✅ **SVG light bar coordinates with C++ brightness calculations**  
✅ **No crashes or errors during emergency mode**  
✅ **Graceful fallback if C++ extension unavailable**

Run either test option above to verify your emergency alert system is working correctly!