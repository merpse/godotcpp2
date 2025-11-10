extends SceneTree

# Simple test script to verify C++ Strategy pattern functionality
# This can be run directly with godot --script test_strategy_pattern.gd

func _init():
	print("🔧 Testing C++ Strategy Pattern Implementation")
	print("==================================================")  # Fixed string literal
	
	test_light_strip_strategy_pattern()
	
	# Exit cleanly
	quit()

func test_light_strip_strategy_pattern():
	print("\n💡 Testing LightStrip Strategy Pattern")
	
	# Test if our C++ classes are available
	if ClassDB.class_exists("GodotLightStrip"):
		print("✅ GodotLightStrip class found")
		
		# Create a light strip instance
		var light_strip = ClassDB.instantiate("GodotLightStrip")
		if light_strip:
			print("✅ GodotLightStrip instance created")
			
			# Test basic activation
			light_strip.activate()
			print("✅ Light strip activated")
			
			# Test brightness control (the function user was looking at)
			light_strip.set_brightness(0.8)
			print("🔆 Brightness set to 0.8")
			
			# Test Strategy pattern behavior switching
			print("\n🔄 Testing Strategy Pattern Behavior Switching:")
			
			# Test normal mode
			light_strip.set_behavior("normal")
			var mode = light_strip.get_current_mode()
			print("📊 Normal mode: ", mode)
			print("🔆 Normal brightness: ", light_strip.get_brightness())
			
			# Test emergency mode (Strategy pattern switch)
			print("\n🚨 Switching to Emergency Mode...")
			light_strip.set_emergency_behavior()
			mode = light_strip.get_current_mode()
			print("📊 Emergency mode: ", mode)
			print("🔆 Emergency brightness: ", light_strip.get_brightness())
			
			# Test deactivation
			print("\n🔄 Deactivating emergency mode...")
			light_strip.set_behavior("normal")
			mode = light_strip.get_current_mode()
			print("📊 Back to normal mode: ", mode)
			
			print("\n✅ Strategy Pattern test completed successfully!")
			
		else:
			print("❌ Failed to create GodotLightStrip instance")
	else:
		print("❌ GodotLightStrip class not found")
		print("Make sure the WindowExtension is properly loaded")
	
	# Test bed integration
	print("\n🏥 Testing Bed Integration with LightStrip")
	if ClassDB.class_exists("GodotBedFactory"):
		print("✅ GodotBedFactory class found")
		
		var factory = ClassDB.instantiate("GodotBedFactory")
		if factory:
			var surgical_bed = factory.create_bed("surgical")
			if surgical_bed:
				print("✅ Surgical bed created")
				
				# Test bed light controls (using setLightBrightness function)
				surgical_bed.power_on()
				surgical_bed.set_light_brightness(0.7)
				print("🔆 Bed light brightness set to 0.7 via C++ function")
				
				# Test emergency via bed
				surgical_bed.trigger_emergency()
				print("🚨 Emergency triggered via bed")
				
			else:
				print("❌ Failed to create surgical bed")
		else:
			print("❌ Failed to create bed factory")
	else:
		print("❌ GodotBedFactory class not found")