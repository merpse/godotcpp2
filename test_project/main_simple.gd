extends Node

func _ready():
	print("=== Testing CustomWindow Extension ===")
	print("Godot version: ", Engine.get_version_info())
	print("Platform: ", OS.get_name())
	
	# Check if the class exists
	if ClassDB.class_exists("CustomWindow"):
		print("✅ CustomWindow class found!")
		
		# Create a CustomWindow instance
		var custom_window = CustomWindow.new()
		add_child(custom_window)
		
		print("✅ CustomWindow created successfully!")
		
		# Test the methods
		print("--- Testing Methods ---")
		custom_window.apply_shade()
		custom_window.operate_curtain()
		
		print("🎉 Extension is working!")
	else:
		print("❌ CustomWindow class not found!")
		print("Available classes containing 'Window':")
		var classes = ClassDB.get_class_list()
		var window_classes = []
		for class_name in classes:
			if "Window" in class_name:
				window_classes.append(class_name)
		for class_name in window_classes:
			print("  - ", class_name)
		
		print("")
		print("Extension troubleshooting:")
		print("1. Check if window.gdextension is in the project root")
		print("2. Check if bin/ folder contains the .dylib files")
		print("3. Restart Godot and try again")