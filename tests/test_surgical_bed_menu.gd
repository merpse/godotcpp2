# Unit Tests for Surgical Bed Menu Scene
# Tests all functionality including height, temperature, and lighting controls

extends "res://addons/gut/test.gd"

const SurgicalBedMenuScene = preload("res://scenes/beds/surgical_bed_menu.gd")

var surgical_bed_menu: SurgicalBedMenuScene
var scene_instance: PackedScene

func before_each():
	"""Setup before each test"""
	# Load the actual scene
	scene_instance = load("res://scenes/beds/surgical_bed_menu.tscn")
	surgical_bed_menu = scene_instance.instantiate()
	add_child(surgical_bed_menu)
	
	# Wait for ready to be called
	await surgical_bed_menu.ready

func after_each():
	"""Cleanup after each test"""
	if surgical_bed_menu:
		surgical_bed_menu.queue_free()
		surgical_bed_menu = null

# Basic initialization tests
func test_scene_initializes_correctly():
	"""Test that the scene initializes with correct default values"""
	assert_eq(surgical_bed_menu.get_current_height(), SurgicalBedMenuScene.BedHeight.MEDIUM, 
		"Should start with MEDIUM height")
	assert_eq(surgical_bed_menu.get_current_temperature(), SurgicalBedMenuScene.Temperature.NORMAL, 
		"Should start with NORMAL temperature")
	assert_eq(surgical_bed_menu.get_current_lighting_mode(), SurgicalBedMenuScene.LightingMode.AUTO, 
		"Should start with AUTO lighting")
	assert_eq(surgical_bed_menu.get_manual_brightness(), 50.0, 
		"Should start with 50% brightness")

func test_scene_nodes_exist():
	"""Test that all required nodes exist in the scene"""
	# Check critical UI nodes exist
	assert_not_null(surgical_bed_menu.get_node("HBoxContainer/BedDisplay/BedImage"), 
		"Bed image node should exist")
	assert_not_null(surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/HeightControls/HeightButtons/LowButton"), 
		"Low height button should exist")
	assert_not_null(surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/TemperatureControls/TempButtons/CoolButton"), 
		"Cool temperature button should exist")
	assert_not_null(surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/LightButtons/AutoButton"), 
		"Auto lighting button should exist")
	assert_not_null(surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/StatusPanel/StatusLabel"), 
		"Status label should exist")

# Height control tests
func test_height_control_low():
	"""Test setting bed height to LOW"""
	var signal_emitted = false
	var received_height
	
	surgical_bed_menu.bed_height_changed.connect(func(height): 
		signal_emitted = true
		received_height = height
	)
	
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.LOW)
	
	assert_true(signal_emitted, "Height changed signal should be emitted")
	assert_eq(received_height, SurgicalBedMenuScene.BedHeight.LOW, "Signal should contain LOW height")
	assert_eq(surgical_bed_menu.get_current_height(), SurgicalBedMenuScene.BedHeight.LOW, 
		"Current height should be LOW")

func test_height_control_medium():
	"""Test setting bed height to MEDIUM"""
	# First set to LOW, then to MEDIUM to ensure change detection
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.LOW)
	
	var signal_emitted = false
	var received_height
	
	surgical_bed_menu.bed_height_changed.connect(func(height): 
		signal_emitted = true
		received_height = height
	)
	
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.MEDIUM)
	
	assert_true(signal_emitted, "Height changed signal should be emitted")
	assert_eq(received_height, SurgicalBedMenuScene.BedHeight.MEDIUM, "Signal should contain MEDIUM height")
	assert_eq(surgical_bed_menu.get_current_height(), SurgicalBedMenuScene.BedHeight.MEDIUM, 
		"Current height should be MEDIUM")

func test_height_control_high():
	"""Test setting bed height to HIGH"""
	var signal_emitted = false
	var received_height
	
	surgical_bed_menu.bed_height_changed.connect(func(height): 
		signal_emitted = true
		received_height = height
	)
	
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.HIGH)
	
	assert_true(signal_emitted, "Height changed signal should be emitted")
	assert_eq(received_height, SurgicalBedMenuScene.BedHeight.HIGH, "Signal should contain HIGH height")
	assert_eq(surgical_bed_menu.get_current_height(), SurgicalBedMenuScene.BedHeight.HIGH, 
		"Current height should be HIGH")

func test_height_no_change_same_value():
	"""Test that setting same height doesn't emit signal"""
	var signal_emitted = false
	
	surgical_bed_menu.bed_height_changed.connect(func(_height): 
		signal_emitted = true
	)
	
	# Try to set same height (MEDIUM is default)
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.MEDIUM)
	
	assert_false(signal_emitted, "Signal should not be emitted when setting same height")

# Temperature control tests
func test_temperature_control_cool():
	"""Test setting bed temperature to COOL"""
	var signal_emitted = false
	var received_temp
	
	surgical_bed_menu.bed_temperature_changed.connect(func(temp): 
		signal_emitted = true
		received_temp = temp
	)
	
	surgical_bed_menu.set_bed_temperature(SurgicalBedMenuScene.Temperature.COOL)
	
	assert_true(signal_emitted, "Temperature changed signal should be emitted")
	assert_eq(received_temp, SurgicalBedMenuScene.Temperature.COOL, "Signal should contain COOL temperature")
	assert_eq(surgical_bed_menu.get_current_temperature(), SurgicalBedMenuScene.Temperature.COOL, 
		"Current temperature should be COOL")

func test_temperature_control_warm():
	"""Test setting bed temperature to WARM"""
	var signal_emitted = false
	var received_temp
	
	surgical_bed_menu.bed_temperature_changed.connect(func(temp): 
		signal_emitted = true
		received_temp = temp
	)
	
	surgical_bed_menu.set_bed_temperature(SurgicalBedMenuScene.Temperature.WARM)
	
	assert_true(signal_emitted, "Temperature changed signal should be emitted")
	assert_eq(received_temp, SurgicalBedMenuScene.Temperature.WARM, "Signal should contain WARM temperature")
	assert_eq(surgical_bed_menu.get_current_temperature(), SurgicalBedMenuScene.Temperature.WARM, 
		"Current temperature should be WARM")

func test_temperature_visual_feedback():
	"""Test that temperature changes affect visual appearance"""
	var bed_image = surgical_bed_menu.get_node("HBoxContainer/BedDisplay/BedImage")
	var initial_color = bed_image.modulate
	
	# Set to COOL temperature
	surgical_bed_menu.set_bed_temperature(SurgicalBedMenuScene.Temperature.COOL)
	var cool_color = bed_image.modulate
	
	# Set to WARM temperature
	surgical_bed_menu.set_bed_temperature(SurgicalBedMenuScene.Temperature.WARM)
	var warm_color = bed_image.modulate
	
	# Colors should be different
	assert_ne(initial_color, cool_color, "Cool temperature should change bed color")
	assert_ne(initial_color, warm_color, "Warm temperature should change bed color")
	assert_ne(cool_color, warm_color, "Cool and warm colors should be different")

# Lighting control tests
func test_lighting_control_auto():
	"""Test setting lighting to AUTO mode"""
	# First set to MANUAL, then to AUTO to ensure change detection
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	
	var signal_emitted = false
	var received_mode
	
	surgical_bed_menu.lighting_mode_changed.connect(func(mode): 
		signal_emitted = true
		received_mode = mode
	)
	
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.AUTO)
	
	assert_true(signal_emitted, "Lighting mode changed signal should be emitted")
	assert_eq(received_mode, SurgicalBedMenuScene.LightingMode.AUTO, "Signal should contain AUTO mode")
	assert_eq(surgical_bed_menu.get_current_lighting_mode(), SurgicalBedMenuScene.LightingMode.AUTO, 
		"Current lighting mode should be AUTO")

func test_lighting_control_manual():
	"""Test setting lighting to MANUAL mode"""
	var signal_emitted = false
	var received_mode
	
	surgical_bed_menu.lighting_mode_changed.connect(func(mode): 
		signal_emitted = true
		received_mode = mode
	)
	
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	
	assert_true(signal_emitted, "Lighting mode changed signal should be emitted")
	assert_eq(received_mode, SurgicalBedMenuScene.LightingMode.MANUAL, "Signal should contain MANUAL mode")
	assert_eq(surgical_bed_menu.get_current_lighting_mode(), SurgicalBedMenuScene.LightingMode.MANUAL, 
		"Current lighting mode should be MANUAL")

func test_brightness_slider_functionality():
	"""Test brightness slider when in manual mode"""
	var brightness_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/BrightnessControl/BrightnessSlider")
	
	# Set to manual mode first
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	
	# Check slider is enabled (editable)
	assert_true(brightness_slider.editable, "Brightness slider should be enabled in MANUAL mode")
	
	# Test brightness change signal
	var signal_emitted = false
	var received_brightness
	
	surgical_bed_menu.brightness_changed.connect(func(value): 
		signal_emitted = true
		received_brightness = value
	)
	
	# Simulate slider change
	brightness_slider.value = 75.0
	brightness_slider.value_changed.emit(75.0)
	
	assert_true(signal_emitted, "Brightness changed signal should be emitted")
	assert_eq(received_brightness, 75.0, "Signal should contain correct brightness value")

func test_brightness_slider_disabled_in_auto():
	"""Test brightness slider is disabled in AUTO mode"""
	var brightness_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/BrightnessControl/BrightnessSlider")
	
	# Ensure we're in AUTO mode
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.AUTO)
	
	# Check slider is disabled (not editable)
	assert_false(brightness_slider.editable, "Brightness slider should be disabled in AUTO mode")

# Status and integration tests
func test_status_info_complete():
	"""Test that status info contains all required information"""
	var status = surgical_bed_menu.get_status_info()
	
	assert_has(status, "height", "Status should include height")
	assert_has(status, "temperature", "Status should include temperature")
	assert_has(status, "lighting_mode", "Status should include lighting_mode")
	assert_has(status, "manual_brightness", "Status should include manual_brightness")
	assert_has(status, "temperature_color", "Status should include temperature_color")
	
	# Verify data types
	assert_typeof(status["height"], TYPE_STRING, "Height should be string")
	assert_typeof(status["temperature"], TYPE_STRING, "Temperature should be string")
	assert_typeof(status["lighting_mode"], TYPE_STRING, "Lighting mode should be string")
	assert_typeof(status["manual_brightness"], TYPE_FLOAT, "Manual brightness should be float")

func test_status_label_updates():
	"""Test that status label updates when values change"""
	var status_label = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/StatusPanel/StatusLabel")
	var initial_text = status_label.text
	
	# Change height and check status updates
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.HIGH)
	var after_height_change = status_label.text
	
	assert_ne(initial_text, after_height_change, "Status label should update after height change")
	assert_string_contains(after_height_change, "HIGH", "Status should show HIGH height")

func test_button_states_update():
	"""Test that buttons disable/enable correctly based on current state"""
	var low_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/HeightControls/HeightButtons/LowButton")
	var medium_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/HeightControls/HeightButtons/MediumButton")
	var high_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/HeightControls/HeightButtons/HighButton")
	
	# Initially MEDIUM should be disabled (default state)
	assert_true(medium_btn.disabled, "Medium button should be disabled initially")
	assert_false(low_btn.disabled, "Low button should be enabled initially")
	assert_false(high_btn.disabled, "High button should be enabled initially")
	
	# Set to HIGH and check button states
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.HIGH)
	
	assert_false(medium_btn.disabled, "Medium button should be enabled after changing to HIGH")
	assert_false(low_btn.disabled, "Low button should be enabled after changing to HIGH")
	assert_true(high_btn.disabled, "High button should be disabled after changing to HIGH")

# Error handling and edge case tests
func test_invalid_operations():
	"""Test that invalid operations are handled gracefully"""
	var initial_height = surgical_bed_menu.get_current_height()
	
	# Setting same value multiple times should not cause issues
	surgical_bed_menu.set_bed_height(initial_height)
	surgical_bed_menu.set_bed_height(initial_height)
	surgical_bed_menu.set_bed_height(initial_height)
	
	assert_eq(surgical_bed_menu.get_current_height(), initial_height, 
		"Height should remain unchanged after setting same value multiple times")

# Integration test with all systems
func test_full_integration():
	"""Test interaction of all systems together"""
	var status_label = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/StatusPanel/StatusLabel")
	
	# Perform a series of operations
	surgical_bed_menu.set_bed_height(SurgicalBedMenuScene.BedHeight.HIGH)
	surgical_bed_menu.set_bed_temperature(SurgicalBedMenuScene.Temperature.WARM)
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	
	# Check final state
	var final_status = surgical_bed_menu.get_status_info()
	assert_eq(final_status["height"], "HIGH", "Final height should be HIGH")
	assert_eq(final_status["temperature"], "WARM", "Final temperature should be WARM")
	assert_eq(final_status["lighting_mode"], "MANUAL", "Final lighting mode should be MANUAL")
	
	# Status label should reflect all changes
	var final_status_text = status_label.text
	assert_string_contains(final_status_text, "HIGH", "Status should show HIGH height")
	assert_string_contains(final_status_text, "WARM", "Status should show WARM temperature")
	assert_string_contains(final_status_text, "MANUAL", "Status should show MANUAL lighting")

# RGB Color Control Tests
func test_rgb_color_initialization():
	"""Test that RGB colors initialize with correct default values"""
	var rgb_values = surgical_bed_menu.get_rgb_values()
	assert_eq(rgb_values["red"], 100.0, "Red should initialize to 100%")
	assert_eq(rgb_values["green"], 100.0, "Green should initialize to 100%")
	assert_eq(rgb_values["blue"], 100.0, "Blue should initialize to 100%")

func test_rgb_sliders_exist():
	"""Test that RGB slider controls exist in the scene"""
	var red_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider")
	var green_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenSlider")
	var blue_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueSlider")
	
	assert_not_null(red_slider, "Red color slider should exist")
	assert_not_null(green_slider, "Green color slider should exist")
	assert_not_null(blue_slider, "Blue color slider should exist")
	
	# Check initial values
	assert_eq(red_slider.value, 100.0, "Red slider should start at 100%")
	assert_eq(green_slider.value, 100.0, "Green slider should start at 100%")
	assert_eq(blue_slider.value, 100.0, "Blue slider should start at 100%")

func test_rgb_color_changes():
	"""Test that RGB color changes work correctly"""
	# Switch to manual mode first
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	
	# Get RGB sliders
	var red_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider")
	var green_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenSlider")
	var blue_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueSlider")
	
	# Track signal emissions
	var rgb_signals = []
	surgical_bed_menu.rgb_color_changed.connect(func(color, value): rgb_signals.append([color, value]))
	
	# Change red value
	red_slider.value = 75.0
	red_slider.emit_signal("value_changed", 75.0)
	await wait_frames(2)
	
	var rgb_values = surgical_bed_menu.get_rgb_values()
	assert_eq(rgb_values["red"], 75.0, "Red value should be updated to 75%")
	assert_true(rgb_signals.size() > 0, "RGB color changed signal should be emitted")
	assert_eq(rgb_signals[0][0], "red", "Signal should indicate red color change")
	assert_eq(rgb_signals[0][1], 75.0, "Signal should carry correct value")

func test_rgb_controls_disabled_in_auto_mode():
	"""Test that RGB controls are disabled in AUTO lighting mode"""
	# Start in AUTO mode (default)
	assert_eq(surgical_bed_menu.get_current_lighting_mode(), SurgicalBedMenuScene.LightingMode.AUTO)
	
	# Get RGB sliders
	var red_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider")
	var green_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenSlider")
	var blue_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueSlider")
	
	# RGB controls should be disabled in AUTO mode
	assert_false(red_slider.editable, "Red slider should be disabled in AUTO mode")
	assert_false(green_slider.editable, "Green slider should be disabled in AUTO mode")
	assert_false(blue_slider.editable, "Blue slider should be disabled in AUTO mode")
	
	# Switch to manual mode
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	await wait_frames(2)
	
	# RGB controls should be enabled in MANUAL mode
	assert_true(red_slider.editable, "Red slider should be enabled in MANUAL mode")
	assert_true(green_slider.editable, "Green slider should be enabled in MANUAL mode")
	assert_true(blue_slider.editable, "Blue slider should be enabled in MANUAL mode")

# Emergency Mode Tests
func test_emergency_mode_initialization():
	"""Test that emergency mode initializes correctly"""
	assert_eq(surgical_bed_menu.get_current_emergency_state(), SurgicalBedMenuScene.EmergencyState.NORMAL, 
		"Should start in NORMAL emergency state")
	assert_false(surgical_bed_menu.is_emergency_blinking(), "Should not be blinking initially")

func test_emergency_button_exists():
	"""Test that emergency button exists in the scene"""
	var emergency_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/EmergencyControl/EmergencyButton")
	assert_not_null(emergency_btn, "Emergency button should exist")
	assert_eq(emergency_btn.text, "EMERGENCY MODE", "Emergency button should have correct initial text")

func test_emergency_mode_activation():
	"""Test that emergency mode activates correctly"""
	# Track signal emissions
	var emergency_signals = []
	surgical_bed_menu.emergency_mode_changed.connect(func(is_emergency): emergency_signals.append(is_emergency))
	
	# Get emergency button
	var emergency_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/EmergencyControl/EmergencyButton")
	
	# Activate emergency mode
	emergency_btn.emit_signal("pressed")
	await wait_frames(2)
	
	# Check emergency state
	assert_eq(surgical_bed_menu.get_current_emergency_state(), SurgicalBedMenuScene.EmergencyState.EMERGENCY, 
		"Should be in EMERGENCY state")
	assert_true(surgical_bed_menu.is_emergency_blinking(), "Should be blinking in emergency mode")
	assert_eq(emergency_btn.text, "STOP EMERGENCY", "Button text should change when in emergency mode")
	
	# Check signal was emitted
	assert_true(emergency_signals.size() > 0, "Emergency mode changed signal should be emitted")
	assert_true(emergency_signals[0], "Signal should indicate emergency mode is active")

func test_emergency_mode_deactivation():
	"""Test that emergency mode deactivates correctly"""
	# First activate emergency mode
	var emergency_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/EmergencyControl/EmergencyButton")
	emergency_btn.emit_signal("pressed")
	await wait_frames(2)
	
	# Verify it's active
	assert_eq(surgical_bed_menu.get_current_emergency_state(), SurgicalBedMenuScene.EmergencyState.EMERGENCY)
	
	# Track signal emissions
	var emergency_signals = []
	surgical_bed_menu.emergency_mode_changed.connect(func(is_emergency): emergency_signals.append(is_emergency))
	
	# Deactivate emergency mode
	emergency_btn.emit_signal("pressed")
	await wait_frames(2)
	
	# Check emergency state
	assert_eq(surgical_bed_menu.get_current_emergency_state(), SurgicalBedMenuScene.EmergencyState.NORMAL, 
		"Should be back to NORMAL state")
	assert_false(surgical_bed_menu.is_emergency_blinking(), "Should stop blinking when emergency mode ends")
	assert_eq(emergency_btn.text, "EMERGENCY MODE", "Button text should revert when emergency mode ends")
	
	# Check signal was emitted
	assert_true(emergency_signals.size() > 0, "Emergency mode changed signal should be emitted")
	assert_false(emergency_signals[0], "Signal should indicate emergency mode is inactive")

func test_light_bar_exists():
	"""Test that light bar element exists in the scene"""
	var light_bar = surgical_bed_menu.get_node("HBoxContainer/BedDisplay/LightBar")
	assert_not_null(light_bar, "Light bar should exist in the scene")

func test_status_info_includes_new_features():
	"""Test that status info includes RGB and emergency state information"""
	var status = surgical_bed_menu.get_status_info()
	
	# Check RGB values are included
	assert_true(status.has("rgb_values"), "Status should include RGB values")
	assert_eq(status["rgb_values"]["red"], 100.0, "Status should show correct red value")
	assert_eq(status["rgb_values"]["green"], 100.0, "Status should show correct green value")
	assert_eq(status["rgb_values"]["blue"], 100.0, "Status should show correct blue value")
	
	# Check emergency state is included
	assert_true(status.has("emergency_state"), "Status should include emergency state")
	assert_eq(status["emergency_state"], "NORMAL", "Status should show correct emergency state")
	
	# Check blinking state is included
	assert_true(status.has("is_blinking"), "Status should include blinking state")
	assert_false(status["is_blinking"], "Status should show correct blinking state")

func test_rgb_integration_with_manual_mode():
	"""Test that RGB controls work properly with manual lighting mode"""
	# Switch to manual mode
	surgical_bed_menu.set_lighting_mode(SurgicalBedMenuScene.LightingMode.MANUAL)
	await wait_frames(2)
	
	# Get RGB sliders
	var red_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider")
	var green_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenSlider")
	var blue_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueSlider")
	
	# Change multiple RGB values
	red_slider.value = 50.0
	red_slider.emit_signal("value_changed", 50.0)
	green_slider.value = 75.0
	green_slider.emit_signal("value_changed", 75.0)
	blue_slider.value = 25.0
	blue_slider.emit_signal("value_changed", 25.0)
	await wait_frames(2)
	
	# Check values are updated
	var rgb_values = surgical_bed_menu.get_rgb_values()
	assert_eq(rgb_values["red"], 50.0, "Red should be updated to 50%")
	assert_eq(rgb_values["green"], 75.0, "Green should be updated to 75%")
	assert_eq(rgb_values["blue"], 25.0, "Blue should be updated to 25%")
	
	# Get value labels and check they're updated
	var red_label = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedValue")
	var green_label = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenValue")
	var blue_label = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueValue")
	
	assert_eq(red_label.text, "50%", "Red label should show 50%")
	assert_eq(green_label.text, "75%", "Green label should show 75%")
	assert_eq(blue_label.text, "25%", "Blue label should show 25%")

# Scanner mouse collision detection tests
func test_scanner_mouse_collision_nodes_exist():
	"""Test that scanner collision detection nodes are properly configured"""
	var scanner = surgical_bed_menu.get_node("HBoxContainer/BedDisplay/Scanner")
	assert_not_null(scanner, "Scanner node should exist")
	assert_eq(scanner.mouse_filter, Control.MOUSE_FILTER_PASS, "Scanner should have mouse filter enabled for collision detection")

func test_scanner_hover_detection():
	"""Test that scanner hover state is properly managed"""
	var scanner = surgical_bed_menu.get_node("HBoxContainer/BedDisplay/Scanner")
	
	# Initially should not be hovered
	assert_false(surgical_bed_menu.is_scanner_hovered, "Scanner should not be hovered initially")
	
	# Simulate mouse enter
	surgical_bed_menu._on_scanner_mouse_entered()
	assert_true(surgical_bed_menu.is_scanner_hovered, "Scanner should be hovered after mouse enter")
	
	# Check visual feedback (yellow highlight)
	var expected_hover_color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow
	assert_eq(scanner.modulate, expected_hover_color, "Scanner should be highlighted yellow when hovered")
	
	# Simulate mouse exit
	surgical_bed_menu._on_scanner_mouse_exited()
	assert_false(surgical_bed_menu.is_scanner_hovered, "Scanner should not be hovered after mouse exit")

func test_scanner_auto_power_on_hover():
	"""Test that scanner automatically powers on when hovered"""
	# Ensure scanner starts in OFF state
	if surgical_bed_menu.current_scanner_state != SurgicalBedMenuScene.ScannerState.OFF:
		surgical_bed_menu._on_scanner_power_pressed()  # Turn it off first
		await wait_frames(1)
	
	assert_eq(surgical_bed_menu.current_scanner_state, SurgicalBedMenuScene.ScannerState.OFF, 
		"Scanner should start in OFF state")
	
	# Simulate mouse hover
	surgical_bed_menu._on_scanner_mouse_entered()
	await wait_frames(1)
	
	# Check that scanner powered on automatically
	assert_eq(surgical_bed_menu.current_scanner_state, SurgicalBedMenuScene.ScannerState.ON, 
		"Scanner should auto-power ON when mouse hovers")

func test_scanner_no_redundant_power_on():
	"""Test that hovering over already-on scanner doesn't cause issues"""
	# Ensure scanner is ON
	if surgical_bed_menu.current_scanner_state != SurgicalBedMenuScene.ScannerState.ON:
		surgical_bed_menu._on_scanner_power_pressed()  # Turn it on
		await wait_frames(1)
	
	assert_eq(surgical_bed_menu.current_scanner_state, SurgicalBedMenuScene.ScannerState.ON, 
		"Scanner should be in ON state")
	
	# Simulate mouse hover (should not cause issues)
	surgical_bed_menu._on_scanner_mouse_entered()
	await wait_frames(1)
	
	# Should still be ON (no errors or state changes)
	assert_eq(surgical_bed_menu.current_scanner_state, SurgicalBedMenuScene.ScannerState.ON, 
		"Scanner should remain ON without issues")

func test_scanner_visual_states():
	"""Test scanner visual appearance in different states"""
	var scanner = surgical_bed_menu.get_node("HBoxContainer/BedDisplay/Scanner")
	var hover_color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow
	var off_color = Color(0.5, 0.5, 0.5, 0.7)    # Dimmed
	var on_color = Color(1.0, 1.0, 1.0, 1.0)     # Full visibility
	
	# Test OFF state appearance
	if surgical_bed_menu.current_scanner_state != SurgicalBedMenuScene.ScannerState.OFF:
		surgical_bed_menu._on_scanner_power_pressed()
		await wait_frames(1)
	
	surgical_bed_menu._update_scanner_display()
	assert_eq(scanner.modulate, off_color, "Scanner should be dimmed when OFF")
	
	# Test hover override (should be yellow even when OFF)
	surgical_bed_menu.is_scanner_hovered = true
	surgical_bed_menu._update_scanner_display()
	assert_eq(scanner.modulate, hover_color, "Scanner should be yellow when hovered, even if OFF")
	
	# Test ON state appearance (without hover)
	surgical_bed_menu.is_scanner_hovered = false
	if surgical_bed_menu.current_scanner_state != SurgicalBedMenuScene.ScannerState.ON:
		surgical_bed_menu._on_scanner_power_pressed()
		await wait_frames(1)
	
	surgical_bed_menu._update_scanner_display()
	assert_eq(scanner.modulate, on_color, "Scanner should be full visibility when ON")

# UI Improvements tests
func test_window_size_configuration():
	"""Test that window is configured with larger size"""
	var root_container = surgical_bed_menu.get_node(".")
	assert_eq(root_container.custom_minimum_size, Vector2(1600, 1200), 
		"Window should have minimum size of 1600x1200")

func test_theme_application():
	"""Test that medical UI theme is properly applied"""
	var root_container = surgical_bed_menu.get_node(".")
	assert_not_null(root_container.theme, "Root container should have theme applied")

func test_margin_spacing():
	"""Test that proper margins and spacing are configured"""
	var root_container = surgical_bed_menu.get_node(".")
	
	# Check margin overrides exist (indicates proper spacing configuration)
	var margin_left = root_container.get_theme_constant("margin_left")
	var margin_top = root_container.get_theme_constant("margin_top")
	
	# Should have non-zero margins for proper spacing
	assert_gt(margin_left, 0, "Should have left margin for proper spacing")
	assert_gt(margin_top, 0, "Should have top margin for proper spacing")

func test_scanner_node_sizing():
	"""Test that scanner node has proper custom sizing configuration"""
	var scanner = surgical_bed_menu.get_node("HBoxContainer/BedDisplay/Scanner")
	assert_eq(scanner.custom_minimum_size, Vector2(200, 80), 
		"Scanner should have custom minimum size of 200x80")
	assert_eq(scanner.size_flags_horizontal, 0, 
		"Scanner should not expand horizontally")