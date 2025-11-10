# Debug Emergency Alert Test - Focused test for emergency blinking with C++ Strategy pattern
extends Node

var cpp_light_strip = null
var light_bar_dummy = null
var emergency_timer = null
var is_blinking = false

func _ready():
	print("\n🚨 Emergency Alert Debug Test")
	print("========================================")
	
	# Test 1: Initialize C++ Light Strip
	test_cpp_light_strip_init()
	
	# Test 2: Test emergency behavior
	test_emergency_behavior()
	
	# Test 3: Simulate blinking
	test_emergency_blinking()
	
	print("========================================")

func test_cpp_light_strip_init():
	print("\n🔧 Test 1: C++ Light Strip Initialization")
	
	if ClassDB.class_exists("GodotLightStrip"):
		print("✅ GodotLightStrip class found")
		
		cpp_light_strip = ClassDB.instantiate("GodotLightStrip")
		if cpp_light_strip:
			print("✅ GodotLightStrip instance created")
			
			cpp_light_strip.set_name("EmergencyTestStrip")
			add_child(cpp_light_strip)
			
			# Activate the light strip
			cpp_light_strip.activate()
			print("✅ Light strip activated")
			
			# Set initial mode
			cpp_light_strip.set_behavior("auto")
			print("✅ Set to auto mode: ", cpp_light_strip.get_current_mode())
			
		else:
			print("❌ Failed to create GodotLightStrip instance")
	else:
		print("❌ GodotLightStrip class not available")

func test_emergency_behavior():
	print("\n🚨 Test 2: Emergency Behavior")
	
	if cpp_light_strip:
		print("🔄 Switching to emergency mode...")
		cpp_light_strip.set_behavior("emergency")
		
		var mode = cpp_light_strip.get_current_mode()
		var brightness_raw = cpp_light_strip.get_brightness()
		var brightness = float(brightness_raw)
		
		print("📊 Emergency mode: ", mode)
		print("🔆 Emergency brightness: ", brightness)
		
		if mode == "emergency":
			print("✅ Emergency mode activated successfully")
		else:
			print("⚠️ Emergency mode not properly set")
			
	else:
		print("❌ No light strip available for emergency test")

func test_emergency_blinking():
	print("\n💡 Test 3: Emergency Blinking Simulation")
	
	if cpp_light_strip:
		# Setup emergency timer
		emergency_timer = Timer.new()
		emergency_timer.wait_time = 0.5
		emergency_timer.timeout.connect(_on_emergency_blink_test)
		emergency_timer.autostart = true
		emergency_timer.one_shot = false
		add_child(emergency_timer)
		
		is_blinking = true
		print("✅ Emergency blinking test started (5 blinks)")
		
		# Stop after 5 seconds
		await get_tree().create_timer(5.0).timeout
		emergency_timer.stop()
		is_blinking = false
		print("✅ Emergency blinking test completed")
		
	else:
		print("❌ No light strip available for blinking test")

func _on_emergency_blink_test():
	if is_blinking and cpp_light_strip:
		var current_brightness_raw = cpp_light_strip.get_brightness()
		var current_brightness = float(current_brightness_raw)
		var current_mode = cpp_light_strip.get_current_mode()
		
		print("💡 Blink - Mode: ", current_mode, " Brightness: ", current_brightness)
		
		# In a real scene, this would update the SVG light bar:
		# light_bar.modulate = Color(1.0, 0.2, 0.2, current_brightness)