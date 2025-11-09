extends Node

func _ready():
	print("=== Testing CustomWindow Extension ===")
	print("Godot version: ", Engine.get_version_info())
	print("Platform: ", OS.get_name())
	
	# Check if CustomWindow class exists
	if ClassDB.class_exists("CustomWindow"):
		print("✅ CustomWindow class found!")
		test_custom_window()
	else:
		print("❌ CustomWindow class not found!")
		show_available_classes()

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

func show_available_classes():
	print("\n=== Available Classes Analysis ===")
	var available_classes = ClassDB.get_class_list()
	print("Total classes available: ", available_classes.size())
	
	# Look for classes containing "Window"
	var window_classes = []
	for class_name in available_classes:
		if "Window" in class_name:
			window_classes.append(class_name)
	
	print("Window-related classes found: ", window_classes)
	
	# Show first 10 classes as sample
	print("Sample classes (first 10):")
	for i in range(min(10, available_classes.size())):
		print("  ", available_classes[i])