@tool
extends EditorPlugin

func _enter_tree():
	print("🏥 Medical Equipment Extension Plugin Loaded")

func _exit_tree():
	print("🏥 Medical Equipment Extension Plugin Unloaded")