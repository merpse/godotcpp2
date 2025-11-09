extends Node

func _ready():
	print("=== Testing CustomWindow Extension (Alternative Method) ===")
	print("Godot version: ", Engine.get_version_info())
	print("Platform: ", OS.get_name())
	
	# Check if the class is available through ClassDB
	var available_classes = ClassDB.get_class_list()
	print("Total classes available: ", available_classes.size())
	
	# Look for classes containing "Window"
	var window_classes = []
	for class_name in available_classes:
		if "Window" in class_name:
			window_classes.append(class_name)
	
	print("Window-related classes found: ", window_classes)
	
	# Try to check if CustomWindow is registered
	if ClassDB.class_exists("CustomWindow"):
		print("✅ CustomWindow class is registered!")
		test_custom_window()
	else:
		print("❌ CustomWindow class not found in ClassDB")
		print("This might be due to the mem_alloc2 interface mismatch")
		print("Extension may still work for core functionality")

func test_custom_window():
	print("\n--- Creating CustomWindow Instance ---")
	var custom_window = CustomWindow.new()
	
	if custom_window:
		add_child(custom_window)
		print("✅ CustomWindow instance created successfully!")
		
		# Test the methods
		print("\n--- Testing Extension Methods ---")
		print("Testing apply_shade():")
		custom_window.apply_shade()
		
		print("Testing operate_curtain():")
		custom_window.operate_curtain()
		
		print("\n🎉 CustomWindow extension is working correctly!")
		
		# Clean up
		custom_window.queue_free()
	else:
		print("❌ Failed to create CustomWindow instance")

# Alternative test without direct instantiation
func test_extension_loading():
	print("\n=== Extension Loading Test ===")
	
	# Check if extension file exists
	if ResourceLoader.exists("res://window.gdextension"):
		print("✅ window.gdextension file found")
	else:
		print("❌ window.gdextension file not found")
	
	# Check if library files exist
	if FileAccess.file_exists("res://bin/libwindow.macos.template_debug.dylib"):
		print("✅ Debug library found")
	else:
		print("❌ Debug library not found")
		
	if FileAccess.file_exists("res://bin/libwindow.macos.template_release.dylib"):
		print("✅ Release library found")
	else:
		print("❌ Release library not found")