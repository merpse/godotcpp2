# Surgical Bed Menu Demo
# Demonstrates the surgical bed menu interface

extends Control

var surgical_bed_menu_scene: PackedScene = preload("res://scenes/beds/surgical_bed_menu.tscn")
var surgical_bed_menu: Node

@onready var output_label = $VBoxContainer/OutputPanel/ScrollContainer/OutputLabel

func _ready():
	print("🏥 Surgical Bed Menu Demo initialized")
	setup_surgical_bed_menu()

func setup_surgical_bed_menu():
	"""Load and setup the surgical bed menu"""
	surgical_bed_menu = surgical_bed_menu_scene.instantiate()
	
	# Connect signals to monitor changes
	surgical_bed_menu.bed_height_changed.connect(_on_bed_height_changed)
	surgical_bed_menu.bed_temperature_changed.connect(_on_bed_temperature_changed)
	surgical_bed_menu.lighting_mode_changed.connect(_on_lighting_mode_changed)
	surgical_bed_menu.brightness_changed.connect(_on_brightness_changed)
	
	# Add to the UI container
	$VBoxContainer/MenuContainer.add_child(surgical_bed_menu)
	
	append_output("🔬 Surgical Bed Menu loaded successfully")
	append_output("✅ All control signals connected")

func _on_bed_height_changed(height):
	"""Handle bed height change"""
	var height_name = surgical_bed_menu.BedHeight.keys()[height]
	append_output("🔧 Bed height changed to: " + height_name)

func _on_bed_temperature_changed(temperature):
	"""Handle bed temperature change"""
	var temp_name = surgical_bed_menu.Temperature.keys()[temperature]
	append_output("🌡️ Bed temperature changed to: " + temp_name)

func _on_lighting_mode_changed(mode):
	"""Handle lighting mode change"""
	var mode_name = surgical_bed_menu.LightingMode.keys()[mode]
	append_output("💡 Lighting mode changed to: " + mode_name)

func _on_brightness_changed(brightness):
	"""Handle brightness change"""
	append_output("🔆 Manual brightness set to: " + str(int(brightness)) + "%")

func append_output(text: String):
	"""Add text to output log"""
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] %s\n" % [timestamp, text]
	output_label.text += log_entry
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll_container = $VBoxContainer/OutputPanel/ScrollContainer
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _on_clear_log_pressed():
	"""Clear the output log"""
	output_label.text = ""
	append_output("📋 Log cleared")

func _on_test_all_pressed():
	"""Test all functions automatically - including C++ extension features"""
	append_output("🧪 Running automated test sequence...")
	
	# Test height controls
	surgical_bed_menu.set_bed_height(surgical_bed_menu.BedHeight.LOW)
	await get_tree().create_timer(0.5).timeout
	
	surgical_bed_menu.set_bed_height(surgical_bed_menu.BedHeight.HIGH)
	await get_tree().create_timer(0.5).timeout
	
	surgical_bed_menu.set_bed_height(surgical_bed_menu.BedHeight.MEDIUM)
	await get_tree().create_timer(0.5).timeout
	
	# Test temperature controls
	surgical_bed_menu.set_bed_temperature(surgical_bed_menu.Temperature.COOL)
	await get_tree().create_timer(0.5).timeout
	
	surgical_bed_menu.set_bed_temperature(surgical_bed_menu.Temperature.WARM)
	await get_tree().create_timer(0.5).timeout
	
	surgical_bed_menu.set_bed_temperature(surgical_bed_menu.Temperature.NORMAL)
	await get_tree().create_timer(0.5).timeout
	
	# Test lighting controls
	surgical_bed_menu.set_lighting_mode(surgical_bed_menu.LightingMode.MANUAL)
	await get_tree().create_timer(0.5).timeout
	
	surgical_bed_menu.set_lighting_mode(surgical_bed_menu.LightingMode.AUTO)
	await get_tree().create_timer(0.5).timeout
	
	# Test C++ extension specific functions
	append_output("🏥 Testing C++ surgical functions...")
	surgical_bed_menu.start_surgical_procedure("Appendectomy")
	await get_tree().create_timer(0.5).timeout
	
	surgical_bed_menu.perform_maintenance_check()
	await get_tree().create_timer(0.5).timeout
	
	append_output("✅ Automated test sequence complete!")

func _on_get_status_pressed():
	"""Display current status information - including C++ extension data"""
	var status = surgical_bed_menu.get_status_info()
	append_output("📊 Current Status:")
	append_output("   Height: " + status["height"])
	append_output("   Temperature: " + status["temperature"]) 
	append_output("   Lighting: " + status["lighting_mode"])
	append_output("   Brightness: " + str(status["manual_brightness"]) + "%")
	append_output("   C++ Extension: " + ("Available" if status["cpp_extension_available"] else "Not Available"))
	
	# Add C++ specific data if available
	if status.has("cpp_height"):
		append_output("   C++ Height: " + str(status["cpp_height"]) + " cm")
		append_output("   C++ Temperature: " + str(status["cpp_temperature"]) + "°C")
		append_output("   C++ Sterile Mode: " + ("Active" if status["cpp_sterile_mode"] else "Inactive"))

func _on_start_procedure_pressed():
	"""Start a surgical procedure using C++ extension"""
	surgical_bed_menu.start_surgical_procedure("General Surgery")
	append_output("🏥 Surgical procedure initiated")

func _on_maintenance_check_pressed():
	"""Perform maintenance check using C++ extension"""
	surgical_bed_menu.perform_maintenance_check()
	append_output("🔧 Maintenance check performed")

func _on_emergency_test_pressed():
	"""Test emergency mode using C++ extension"""
	surgical_bed_menu.trigger_emergency_mode()
	append_output("🚨 Emergency mode activated")
	await get_tree().create_timer(2.0).timeout
	surgical_bed_menu.clear_emergency_mode()
	append_output("✅ Emergency mode cleared")