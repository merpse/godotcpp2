extends Node

func _ready():
	print("Testing CustomWindow extension...")
	
	# Test if CustomWindow class is available
	if ClassDB.class_exists("CustomWindow"):
		print("✅ CustomWindow class found!")
		
		# Create an instance
		var custom_window = ClassDB.instantiate("CustomWindow")
		if custom_window != null:
			add_child(custom_window)
			print("✅ CustomWindow instance created successfully")
			
			# Test the methods
			custom_window.apply_shade()
			custom_window.operate_curtain()
		else:
			print("❌ Failed to create CustomWindow instance")
	else:
		print("❌ CustomWindow class not found!")
		print("Available classes containing 'Window':")
		var classes = ClassDB.get_class_list()
		for class_name in classes:
			if "Window" in class_name:
				print("  - ", class_name)
	
	print("Done testing.")