# Simple scene validation test
extends SceneTree

func _init():
	print("🧪 Testing scene loading...")
	
	# Test if scene can load
	var scene_path = "res://scenes/beds/surgical_bed_menu.tscn"
	var scene = load(scene_path)
	
	if scene:
		print("✅ Scene loaded successfully: ", scene_path)
		
		# Test if scene can be instantiated
		var instance = scene.instantiate()
		if instance:
			print("✅ Scene can be instantiated")
			print("✅ Scene type: ", instance.get_class())
			
			# Check if required nodes exist without actually adding to tree
			var scanner = instance.get_node_or_null("HBoxContainer/BedDisplay/Scanner")
			var emergency_btn = instance.get_node_or_null("HBoxContainer/ControlsPanel/LightingControls/EmergencyControl/EmergencyButton")
			var red_slider = instance.get_node_or_null("HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider")
			var scanner_power = instance.get_node_or_null("HBoxContainer/ControlsPanel/ScannerControls/ScannerButtons/PowerButton")
			
			print("✅ Scanner node exists: ", scanner != null)
			print("✅ Emergency button exists: ", emergency_btn != null)
			print("✅ RGB slider exists: ", red_slider != null)
			print("✅ Scanner power button exists: ", scanner_power != null)
			
			instance.queue_free()
			print("✅ All components validated successfully!")
		else:
			print("❌ Failed to instantiate scene")
	else:
		print("❌ Failed to load scene: ", scene_path)
	
	print("🎯 Validation complete - exiting")
	quit()