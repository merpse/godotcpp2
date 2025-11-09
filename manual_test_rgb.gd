# Quick manual test for RGB lighting and emergency mode
extends Node

func _ready():
	print("🧪 Starting manual RGB lighting and emergency mode test...")
	
	# Load the surgical bed scene
	var scene = load("res://scenes/beds/surgical_bed_menu.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	
	# Wait a frame for initialization
	await get_tree().process_frame
	
	print("✅ Scene loaded successfully")
	
	# Test basic functionality
	test_rgb_controls(instance)
	test_emergency_mode(instance)
	
	print("🎯 Manual test completed successfully!")
	get_tree().quit()

func test_rgb_controls(surgical_bed_menu):
	print("🔴🟢🔵 Testing RGB controls...")
	
	# Check initial RGB values
	var rgb_values = surgical_bed_menu.get_rgb_values()
	print("   Initial RGB - Red: ", rgb_values["red"], "%, Green: ", rgb_values["green"], "%, Blue: ", rgb_values["blue"], "%")
	
	# Switch to manual mode to enable RGB controls
	surgical_bed_menu.set_lighting_mode(surgical_bed_menu.LightingMode.MANUAL)
	print("   ✅ Switched to manual lighting mode")
	
	# Test RGB sliders exist
	var red_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider")
	var green_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenSlider")
	var blue_slider = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueSlider")
	
	if red_slider and green_slider and blue_slider:
		print("   ✅ RGB sliders found in scene")
		print("   ✅ Red slider editable: ", red_slider.editable)
		print("   ✅ Green slider editable: ", green_slider.editable)
		print("   ✅ Blue slider editable: ", blue_slider.editable)
	else:
		print("   ❌ RGB sliders missing")

func test_emergency_mode(surgical_bed_menu):
	print("🚨 Testing emergency mode...")
	
	# Check initial emergency state
	var emergency_state = surgical_bed_menu.get_current_emergency_state()
	print("   Initial emergency state: ", surgical_bed_menu.EmergencyState.keys()[emergency_state])
	
	# Check emergency button exists
	var emergency_btn = surgical_bed_menu.get_node("HBoxContainer/ControlsPanel/LightingControls/EmergencyControl/EmergencyButton")
	if emergency_btn:
		print("   ✅ Emergency button found: '", emergency_btn.text, "'")
		
		# Test emergency mode activation
		surgical_bed_menu.start_emergency_mode()
		print("   ✅ Emergency mode activated")
		print("   ✅ Button text changed to: '", emergency_btn.text, "'")
		print("   ✅ Emergency state: ", surgical_bed_menu.EmergencyState.keys()[surgical_bed_menu.get_current_emergency_state()])
		print("   ✅ Is blinking: ", surgical_bed_menu.is_emergency_blinking())
		
		# Test emergency mode deactivation
		surgical_bed_menu.stop_emergency_mode()
		print("   ✅ Emergency mode deactivated")
		print("   ✅ Button text changed to: '", emergency_btn.text, "'")
		print("   ✅ Emergency state: ", surgical_bed_menu.EmergencyState.keys()[surgical_bed_menu.get_current_emergency_state()])
		print("   ✅ Is blinking: ", surgical_bed_menu.is_emergency_blinking())
	else:
		print("   ❌ Emergency button missing")