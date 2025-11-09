#!/bin/bash

echo "🎮 Running Godot Extension Test (GUI Mode)"
echo "==========================================="

PROJECT_PATH="/Users/marimerpanganiban/Documents/workspace/godotcpp2/test_project"

echo "📂 Project location: $PROJECT_PATH"
echo ""

if command -v godot &> /dev/null; then
    echo "🚀 Starting Godot with your extension..."
    echo "Look for console output in Godot's output panel!"
    echo ""
    godot "$PROJECT_PATH/project.godot"
elif command -v godot4 &> /dev/null; then
    echo "🚀 Starting Godot 4 with your extension..."
    echo "Look for console output in Godot's output panel!"
    echo ""
    godot4 "$PROJECT_PATH/project.godot"
else
    echo "❌ Godot not found in PATH"
    echo ""
    echo "📋 Manual Instructions:"
    echo "1. Open Godot Engine"
    echo "2. Click 'Import' and select: $PROJECT_PATH"
    echo "3. Open the project"
    echo "4. Press F5 or click the Play button to run"
    echo "5. Check the Output panel for console messages"
    echo ""
    echo "🔧 Alternative commands to try:"
    echo "   - godot $PROJECT_PATH/project.godot"
    echo "   - godot4 $PROJECT_PATH/project.godot"
    echo "   - /Applications/Godot.app/Contents/MacOS/Godot $PROJECT_PATH/project.godot"
fi