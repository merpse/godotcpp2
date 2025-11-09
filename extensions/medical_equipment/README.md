# 🏥 Medical Equipment Extension

This folder contains all medical equipment related extensions for Godot.

## 📁 File Structure

### Core Classes
- **`bed.h/cpp`** - Abstract base class for all medical beds
- **`patient_bed.h/cpp`** - Patient bed with comfort features
- **`surgical_bed.h/cpp`** - Surgical bed with sterile procedures

### Factory System
- **`bed_factory.h/cpp`** - Factory pattern implementation for bed creation

### Lighting System
- **`light_strip.h`** - Strategy pattern lighting system with multiple behaviors

### Medical Devices
- **`medical_devices.h`** - Composite pattern medical device integration

## 🏗️ Design Patterns
- **Factory Pattern** - Centralized bed creation
- **Strategy Pattern** - Dynamic lighting behaviors
- **Template Method** - Consistent bed operations
- **Observer Pattern** - Emergency alert system
- **Composite Pattern** - Medical device hierarchy

## 🎯 Features

### 🛏️ **Patient Care System**
- Patient comfort management with sleep tracking
- Family visit mode with ambient lighting
- Temperature control (warm, normal, cool)
- Position control with automated adjustments

### 🔬 **Surgical Environment (Enhanced 2025)**
- **Sterile Mode**: UV sterilization and contamination prevention
- **Advanced RGB Lighting**: Individual red, green, blue intensity control (0-100%)
- **Emergency Mode**: One-click red alert lighting with 500ms blinking animation
- **Smart Scanner**: Automated center→right→center movement with boundary detection
- **Mouse Interaction**: Collision detection with yellow highlighting on hover

### 🚨 **Emergency Response**
- Real-time emergency alert system
- Observer pattern notifications
- Visual and audio emergency indicators
- Safe timer management with proper cleanup

### 🔍 **Medical Device Integration**
- Multi-scanner capabilities (MRI, CT, X-RAY, Ultrasound)
- Automated scan sequences with data logging
- Vital sign monitoring with real-time updates
- Device positioning and orientation control

### 🎮 **Interactive Controls**
- Mouse collision detection with visual feedback
- Real-time status updates for all equipment
- Manual and automated operation modes
- Comprehensive state management

## 📖 Documentation
- **`MEDICAL_EQUIPMENT_DESIGN.md`** - Detailed design documentation