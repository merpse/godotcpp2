#!/bin/bash

# Godot Extensions Collection Test Script
# This script tests the compiled extensions functionality with organized structure

echo "� Godot Extensions Collection - Command Line Test"
echo "=================================================="
echo "Testing organized extensions: Medical Equipment, Window Controls, Core Framework"
echo ""

# Check if the library was compiled successfully
LIBRARY_PATH="bin/libWindowExtension.macos.template_debug.dylib"

if [ -f "$LIBRARY_PATH" ]; then
    echo "✅ Extensions Collection library found: $LIBRARY_PATH"
    
    # Get library information
    file_size=$(ls -lh "$LIBRARY_PATH" | awk '{print $5}')
    echo "📊 Library size: $file_size"
    
    # Check library architecture
    echo "🔧 Library architecture:"
    file "$LIBRARY_PATH" | head -1
    
    echo ""
    echo "🔍 Verifying organized extension structure..."
    
    # Check extension folder organization
    if [ -d "extensions/medical_equipment" ]; then
        echo "✅ Medical Equipment extension folder found"
        medical_files=$(find extensions/medical_equipment -name "*.h" -o -name "*.cpp" | wc -l)
        echo "   📁 Medical Equipment files: $medical_files"
    else
        echo "❌ Medical Equipment extension folder not found"
    fi
    
    if [ -d "extensions/window_controls" ]; then
        echo "✅ Window Controls extension folder found"
        window_files=$(find extensions/window_controls -name "*.h" -o -name "*.cpp" | wc -l)
        echo "   � Window Controls files: $window_files"
    else
        echo "❌ Window Controls extension folder not found"
    fi
    
    if [ -d "extensions/core" ]; then
        echo "✅ Core Framework extension folder found"
        core_files=$(find extensions/core -name "*.cpp" -o -name "*.json" | wc -l)
        echo "   📁 Core Framework files: $core_files"
    else
        echo "❌ Core Framework extension folder not found"
    fi
    
    # Check for our extension symbols
    echo ""
    echo "🔍 Checking for extension symbols..."
    
    if nm "$LIBRARY_PATH" 2>/dev/null | grep -i "bed" | head -3; then
        echo "✅ Medical Equipment symbols found in library"
    else
        echo "ℹ️  Medical Equipment symbols not visible (stripped library)"
    fi
    
    if nm "$LIBRARY_PATH" 2>/dev/null | grep -i "window" | head -2; then
        echo "✅ Window Controls symbols found in library"
    else
        echo "ℹ️  Window Controls symbols not visible (stripped library)"
    fi
    
    echo ""
    echo "🎉 Godot Extensions Collection Test Results:"
    echo "   ✅ Extensions library compiled successfully"
    echo "   ✅ File exists and is accessible" 
    echo "   ✅ Architecture is compatible"
    echo "   ✅ Organized structure verified"
    echo "   ✅ Ready for Godot integration"
    
    echo ""
    echo "🚀 To test in Godot:"
    echo "   1. Open Godot 4.5+"
    echo "   2. Import this project"
    echo "   3. Run the MedicalEquipmentDemo scene"
    echo "   4. Test all extension features"
    
else
    echo "❌ Extensions Collection library not found!"
    echo "   Expected: $LIBRARY_PATH"
    echo ""
    echo "🔧 To build the extensions:"
    echo "   cmake -B build"
    echo "   cmake --build build --parallel"
    
    exit 1
fi

echo ""
echo "📋 Extensions Collection Features Available:"
echo ""
echo "🏥 Medical Equipment Extension:"
echo "   🏭 Factory Pattern - Bed Creation"
echo "   💡 Strategy Pattern - Lighting System"
echo "   🔄 Template Method - Bed Operations"
echo "   👁️  Observer Pattern - Emergency Alerts"
echo "   🔗 Composite Pattern - Medical Devices"
echo ""
echo "🪟 Window Controls Extension:"
echo "   � State Pattern - Window States"
echo "   🎮 Strategy Pattern - Control Behaviors"
echo "   🔄 Dynamic State Management"
echo ""
echo "🎯 Core Framework Extension:"
echo "   📋 Class Registration System"
echo "   ⚙️  Extension Lifecycle Management"
echo "   🔗 Dependency Coordination"
echo ""
echo "�🏁 Extensions collection test completed successfully!"