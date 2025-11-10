# Test script to demonstrate C++ Strategy pattern integration with SVG light bar
# This shows how C++ logic enhances existing Godot visual components

extends Node

func _ready():
	print("\n🧪 Testing C++ Strategy Pattern + SVG Integration")
	print("==================================================")
	
	# Test 1: Check if GodotLightStrip class is available
	test_cpp_class_availability()
	
	# Test 2: Create and test GodotLightStrip instance
	test_light_strip_creation()
	
	# Test 3: Test Strategy pattern behaviors
	test_strategy_behaviors()
	
	print("==================================================")
	print("✅ Integration test complete!")

func test_cpp_class_availability():
	print("\n🔍 Test 1: C++ Class Availability")
	
	if ClassDB.class_exists("GodotLightStrip"):
		print("✅ GodotLightStrip class is available!")
		print("📋 Available methods:")
		var methods = ClassDB.class_get_method_list("GodotLightStrip")
		for method in methods:
			if method.name in ["activate", "deactivate", "set_behavior", "get_current_mode", "get_brightness"]:
				print("  • ", method.name)
	else:
		print("❌ GodotLightStrip class not found!")
		print("🔧 Make sure the extension is built and loaded properly")

func test_light_strip_creation():
	print("\n🏗️ Test 2: Light Strip Instance Creation")
	
	if not ClassDB.class_exists("GodotLightStrip"):
		print("❌ Cannot create instance - class not available")
		return
	
	var light_strip = ClassDB.instantiate("GodotLightStrip")
	if light_strip:
		print("✅ GodotLightStrip instance created successfully")
		light_strip.set_name("TestLightStrip")
		add_child(light_strip)
		print("🔗 Added to scene tree as: ", light_strip.name)
		
		# Test basic operations
		print("\n🧪 Testing basic operations:")
		light_strip.activate()
		print("💡 Activated light strip")
		
		var mode = light_strip.get_current_mode()
		var brightness = light_strip.get_brightness()
		print("📊 Current mode: ", mode)
		print("🔆 Current brightness: ", brightness)
		
	else:
		print("❌ Failed to create GodotLightStrip instance")

func test_strategy_behaviors():
	print("\n🎯 Test 3: Strategy Pattern Behaviors")
	
	if not ClassDB.class_exists("GodotLightStrip"):
		print("❌ Cannot test behaviors - class not available")
		return
	
	var light_strip = ClassDB.instantiate("GodotLightStrip")
	if not light_strip:
		print("❌ Cannot create test instance")
		return
	
	add_child(light_strip)
	light_strip.activate()
	
	# Test different behaviors
	var behaviors = ["auto", "manual", "emergency"]
	
	for behavior in behaviors:
		print("\n🔄 Testing behavior: ", behavior)
		light_strip.set_behavior(behavior)
		
		var mode = light_strip.get_current_mode()
		var brightness = light_strip.get_brightness()
		
		print("  📋 Mode after switch: ", mode)
		print("  🔆 Brightness: ", brightness)
		
		# Simulate time passing
		await get_tree().create_timer(0.5).timeout
	
	print("\n🎉 All behavior tests completed!")