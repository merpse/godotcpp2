extends Node

func _ready():
	print("Testing CustomWindow extension with Godot 4.5.0...")
	
	# Create an instance of our CustomWindow
	var custom_window = CustomWindow.new()
	
	# Test the extension functionality
	print("Testing shade operations...")
	custom_window.apply_shade()
	
	print("Testing curtain operations...")
	custom_window.operate_curtain()
	
	print("CustomWindow extension test completed successfully!")
	
	# Clean up and exit
	custom_window.queue_free()
	get_tree().quit()