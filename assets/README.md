# 🎨 Medical Equipment Assets

This directory contains professional SVG assets for the Medical Equipment Extension that are controlled by **C++ extension objects**. Each asset is designed to be managed by specific C++ objects providing asset interactions.

## ✨ Latest Interactive Features

### 🔥 Advanced RGB Lighting System
- **Individual Color Controls**: Separate red, green, blue intensity sliders (0-100%)
- **Real-time Preview**: Live color blending and brightness adjustment
- **Emergency Mode**: One-click emergency lighting with blinking animation

### 🔧 Smart Scanner Control
- **Automated Movement**: Smooth scanner motion from center → right → center
- **Boundary Detection**: Intelligent container edge detection prevents overflow
- **Position Tracking**: Real-time scanner position display

### 🎯 Interactive Collision Detection
- **Mouse Highlighting**: Surgical bed turns yellow on mouse hover
- **Visual Feedback**: Immediate visual response to user interaction
- **State Management**: Smooth color transitions and state tracking

## 🏥 Asset → C++ Object Integration

### Core Design Philosophy
The assets in this directory are specifically designed to be controlled by **C++ extension objects**, not just displayed as static images. Each asset represents a component that receives state updates from its corresponding C++ object.

```
Asset File                  ←→  C++ Extension Object Control
├── patient_bed.svg         ←→  PatientBed C++ object
├── surgical_bed.svg        ←→  SurgicalBed C++ object  
├── monitor.svg             ←→  CustomWindow C++ object
├── scanner.svg             ←→  CustomWindow C++ object
├── light_strip.svg         ←→  PatientBed/SurgicalBed lighting control
├── comfort_mode.svg        ←→  PatientBed comfort state control
├── sterile_mode.svg        ←→  SurgicalBed sterile state control
├── emergency_alert.svg     ←→  Observer Pattern emergency system
└── hospital_background.svg ←→  Static environment asset
```

## 📁 Asset Directory Structure

```
assets/
└── medical/                    # Medical equipment visual assets
    ├── patient_bed.svg         # Patient bed sprite (controlled by PatientBed C++)
    ├── surgical_bed.svg        # Surgical bed sprite (controlled by SurgicalBed C++)
    ├── monitor.svg             # Medical monitor sprite (controlled by CustomWindow C++)
    ├── scanner.svg             # Medical scanner sprite (controlled by CustomWindow C++)
    ├── light_strip.svg         # Lighting system sprite (controlled by C++ Strategy Pattern)
    ├── comfort_mode.svg        # Comfort mode indicator (controlled by PatientBed C++)
    ├── sterile_mode.svg        # Sterile mode indicator (controlled by SurgicalBed C++)
    ├── emergency_alert.svg     # Emergency alert sprite (controlled by C++ Observer Pattern)
    ├── hospital_background.svg # Hospital environment background
    └── *.svg.import           # Godot import configuration files
```

## 🎯 C++ Object → Asset Control Mapping

### 🏭 Factory Pattern Assets
**BedFactory C++ Object Controls:**
- Creation and positioning of bed sprites (`patient_bed.svg`, `surgical_bed.svg`)
- Initial asset state configuration via C++ factory methods

### 🛏️ Patient Bed Assets (PatientBed C++ Object)
**C++ Object**: `PatientBed`  
**Controlled Assets**:
- `patient_bed.svg` - Main patient bed sprite positioning and visibility
- `comfort_mode.svg` - Comfort mode visual indicator activation
- `light_strip.svg` - Lighting system controlled via C++ Strategy Pattern
- Emergency lighting states controlled via C++ Observer Pattern

**C++ Control Methods**:
```cpp
PatientBed::enableComfortMode()     // Controls comfort_mode.svg visibility
PatientBed::activateLights()        // Controls light_strip.svg state
PatientBed::setLightBrightness()    // Controls light_strip.svg intensity
PatientBed::triggerEmergency()      // Controls emergency lighting via Observer
```

### 🔬 Surgical Bed Assets (SurgicalBed C++ Object)
**C++ Object**: `SurgicalBed`  
**Controlled Assets**:
- `surgical_bed.svg` - Main surgical bed sprite positioning and visibility
- `sterile_mode.svg` - Sterile mode visual indicator activation
- `light_strip.svg` - Precision lighting controlled via C++ Strategy Pattern
- `monitor.svg` / `scanner.svg` - Medical devices via C++ Composite Pattern

**C++ Control Methods**:
```cpp
SurgicalBed::enterSterileMode()         // Controls sterile_mode.svg visibility
SurgicalBed::integrateMedicalDevice()   // Controls monitor.svg/scanner.svg
SurgicalBed::startProcedure()           // Controls multiple asset states
SurgicalBed::activateLights()           // Controls surgical lighting
```

### 🪟 Monitor/Scanner Assets (CustomWindow C++ Object)
**C++ Object**: `CustomWindow`  
**Controlled Assets**:
- `monitor.svg` - Medical monitor sprite state and opacity
- `scanner.svg` - Medical scanner sprite state and positioning

**C++ Control Methods**:
```cpp
CustomWindow::setState()         // Controls monitor/scanner sprite states
CustomWindow::adjustOpacity()    // Controls asset transparency
CustomWindow::activateScanner()  // Controls scanner.svg animations
```

## 🎨 Asset Design Specifications

### 🏥 Medical Equipment Asset Standards
- **Format**: SVG vector graphics for scalability
- **Style**: Professional medical equipment aesthetic
- **Colors**: Healthcare standard colors (whites, blues, medical greens)
- **Size**: Optimized for Godot texture import
- **Compatibility**: Designed for Godot 4.5+ texture system

### 📐 Asset Dimensions and Usage

| Asset | Dimensions | Usage | C++ Object Controller |
|-------|------------|--------|----------------------|
| `patient_bed.svg` | Medical bed scale | Patient care scenarios | PatientBed C++ |
| `surgical_bed.svg` | Medical bed scale | Surgical procedures | SurgicalBed C++ |
| `monitor.svg` | Device scale | Vital sign monitoring | CustomWindow C++ |
| `scanner.svg` | Device scale | Medical scanning | CustomWindow C++ |
| `light_strip.svg` | Lighting scale | Room illumination | Strategy Pattern C++ |
| `comfort_mode.svg` | Indicator scale | Patient comfort status | PatientBed C++ |
| `sterile_mode.svg` | Indicator scale | Sterile environment status | SurgicalBed C++ |
| `emergency_alert.svg` | Alert scale | Emergency notifications | Observer Pattern C++ |

## 🔄 C++ Object State → Asset Visual Mapping

### Patient Care Asset States (PatientBed C++)
```
C++ Object State                Asset Visual Response
├── enableComfortMode()      →  comfort_mode.svg becomes visible
├── activateLights()         →  light_strip.svg activates warm lighting
├── setLightBrightness(0.7)  →  light_strip.svg adjusts to 70% brightness
└── triggerEmergency()       →  emergency_alert.svg appears, lighting turns red
```

### Surgical Procedure Asset States (SurgicalBed C++)
```
C++ Object State                Asset Visual Response  
├── enterSterileMode()       →  sterile_mode.svg becomes visible
├── startProcedure("brain")  →  surgical_bed.svg + monitor.svg active
├── activateLights()         →  light_strip.svg precision white lighting
└── integrateMedicalDevice() →  scanner.svg + monitor.svg coordinated display
```

### Monitor Control Asset States (CustomWindow C++)
```
C++ Object State                Asset Visual Response
├── setState("monitoring")   →  monitor.svg displays active monitoring
├── adjustOpacity(0.8)      →  monitor.svg/scanner.svg 80% opacity
└── activateScanner()       →  scanner.svg positioning and scanning animation
```

## 🚀 Asset Integration with C++ Extension Demo

### Demo Scene Asset Usage
The `MedicalEquipmentDemo.tscn` scene demonstrates C++ object → asset control:

1. **C++ Object Creation** → Assets appear and position correctly
2. **C++ State Changes** → Assets update visual states dynamically  
3. **C++ Pattern Execution** → Multiple assets coordinate via C++ logic
4. **Emergency Scenarios** → Observer Pattern updates multiple assets simultaneously

### Simulation Mode Asset Support
When C++ extensions aren't loaded, the demo provides simulation that mimics C++ object asset control:
- Asset positioning simulated via GDScript
- Visual state changes simulated to match C++ object behavior
- All asset interactions maintain same visual behavior as C++ objects

## 📊 Asset → C++ Object Status

| Asset | C++ Object Integration | Status | Notes |
|-------|----------------------|--------|--------|
| `patient_bed.svg` | PatientBed | ✅ Ready | Controlled by C++ PatientBed object |
| `surgical_bed.svg` | SurgicalBed | ✅ Ready | Controlled by C++ SurgicalBed object |
| `monitor.svg` | CustomWindow | ✅ Ready | Controlled by C++ window state object |
| `scanner.svg` | CustomWindow | ✅ Ready | Controlled by C++ window state object |
| `light_strip.svg` | Strategy Pattern | ✅ Ready | Controlled by C++ lighting strategy |
| `comfort_mode.svg` | PatientBed | ✅ Ready | Controlled by C++ comfort state |
| `sterile_mode.svg` | SurgicalBed | ✅ Ready | Controlled by C++ sterile state |
| `emergency_alert.svg` | Observer Pattern | ✅ Ready | Controlled by C++ emergency system |
| `hospital_background.svg` | Static | ✅ Ready | Background environment asset |

## 🔧 Asset Development Guidelines

### Adding New Medical Equipment Assets
1. **Design Asset** - Create SVG following medical equipment standards
2. **Create C++ Object** - Develop corresponding C++ extension object
3. **Implement Control Interface** - Add asset control methods to C++ object
4. **Update Demo** - Integrate asset and C++ object into demonstration
5. **Document Integration** - Update this README with asset → C++ object mapping

### Asset Naming Convention
- Use descriptive medical equipment names
- Include equipment type and function
- Follow snake_case naming: `medical_device_name.svg`
- Ensure C++ object name corresponds to asset purpose

## 🎉 Professional Asset Management

This asset collection demonstrates:
- ✅ **C++ Backend Control** - All assets managed by C++ extension objects
- ✅ **Design Pattern Integration** - Assets respond to C++ pattern implementations
- ✅ **Professional Medical Design** - Healthcare-appropriate visual styling
- ✅ **Scalable Architecture** - Easy to add new assets with corresponding C++ objects
- ✅ **Dual-Mode Support** - Assets work with C++ extensions and simulation fallback

---

**🏁 These medical equipment assets showcase professional C++ extension object → asset integration for comprehensive healthcare simulation in Godot!**