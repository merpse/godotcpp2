# 🎯 Core Extension Framework

This folder contains the core registration and configuration files for all Godot extensions.

## 📁 File Structure

### Registration System
- **`register_types.cpp`** - Main class registration for Godot
- **`extension_config.json`** - Extension configuration metadata

## 🔧 Functionality
- **Class Registration** - Registers all extension classes with Godot
- **Extension Initialization** - Handles extension lifecycle
- **Type Binding** - Binds C++ classes to Godot's type system

## 🏗️ Extension Types Registered
- Medical Equipment classes (Bed, PatientBed, SurgicalBed, BedFactory)
- Window Control classes (Window, various state implementations)
- Supporting utility classes

## 📋 Configuration
The core system handles registration of all extension modules and ensures proper initialization order for dependencies.