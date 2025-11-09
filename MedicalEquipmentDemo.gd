# Medical Equipment Patient Proximity Interaction Demo
# This script demonstrates patient proximity interaction using separate bed scenes
# Enhanced with dual-mode lighting control (AUTO/MANUAL)

extends Control

# Preload bed scenes from organized structure - Now using surgical bed menu
@export var patient_bed_scene: PackedScene = preload("res://scenes/beds/PatientBed_Enhanced.tscn")
@export var surgical_bed_scene: PackedScene = preload("res://scenes/beds/surgical_bed_menu.tscn")
@export var hospital_bg_texture: Texture2D = preload("res://assets/medical/hospital_background.svg")

# UI References  
@onready var output_label = $HBoxContainer/ControlsContainer/OutputPanel/ScrollContainer/OutputLabel
@onready var lighting_slider = $HBoxContainer/ControlsContainer/ControlPanel/LightingControl/LightingSlider
@onready var brightness_value = $HBoxContainer/ControlsContainer/ControlPanel/LightingControl/BrightnessValue

# Additional lighting controls (will be created dynamically)
var auto_mode_button: Button
var manual_mode_button: Button

# Visual area references
@onready var medical_equipment_node = $HBoxContainer/VisualArea/HospitalRoom/MedicalEquipment

# Fixed bed positions
var patient_bed_position = Vector2(200, 350)
var surgical_bed_position = Vector2(500, 350)

# Lighting control modes
enum LightingMode { AUTO, MANUAL, OVERRIDE }
var current_lighting_mode = LightingMode.AUTO
var manual_brightness = 50.0

# Patient character for proximity detection
var patient_character: Area2D
var patient_sprite: Sprite2D
var is_dragging_patient = false
var drag_offset = Vector2()

# Bed scene instances
var patient_bed_instance: PatientBedScene
var surgical_bed_instance: SurgicalBedScene

# Medical Equipment References (C++ Extension Objects)
var bed_factory
var custom_window

func _ready():
	print("🏥 Medical Equipment Proximity Interaction Starting...")
	setup_ui()
	setup_hospital_room()
	instantiate_bed_scenes()
	create_patient_character()
	initialize_medical_equipment()
	add_output("=== Medical Equipment Proximity System Initialized ===")
	add_output("✅ Extension loaded successfully!")
	add_output("🏥 Separate bed scenes loaded and ready!")
	add_output("🚶 Patient character ready - drag to move around!")
	add_output("")
	add_output("🔄 === DUAL LIGHTING CONTROL SYSTEM ===")
	add_output("🤖 AUTO MODE: Lights activate automatically when patient approaches")
	add_output("👩‍⚕️ MANUAL MODE: Medical staff controls lighting via slider")
	add_output("🎚️ Switch modes using AUTO/MANUAL buttons")
	add_output("⚠️ Manual mode overrides proximity detection")
	add_output("💡 Perfect for medical environments requiring both automation & control!")

func setup_ui():
	"""Setup basic UI controls and lighting mode controls"""
	set_custom_minimum_size(Vector2(1200, 800))
	
	# Connect lighting slider
	lighting_slider.value_changed.connect(_on_lighting_slider_changed)
	
	# Create lighting mode controls
	create_lighting_mode_controls()
	
	add_output("🎮 Interaction UI initialized with lighting mode controls")

func create_lighting_mode_controls():
	"""Create UI controls for lighting mode switching"""
	var lighting_control_panel = get_node("HBoxContainer/ControlsContainer/ControlPanel/LightingControl")
	
	# Create lighting mode label
	var mode_label = Label.new()
	mode_label.text = "Lighting Mode:"
	mode_label.add_theme_font_size_override("font_size", 14)
	lighting_control_panel.add_child(mode_label)
	
	# Create mode button container
	var mode_container = HBoxContainer.new()
	lighting_control_panel.add_child(mode_container)
	
	# Auto mode button
	auto_mode_button = Button.new()
	auto_mode_button.text = "AUTO"
	auto_mode_button.custom_minimum_size = Vector2(80, 30)
	auto_mode_button.button_pressed = true  # Start in auto mode
	auto_mode_button.toggle_mode = true
	auto_mode_button.button_group = ButtonGroup.new()
	auto_mode_button.pressed.connect(_on_auto_mode_selected)
	mode_container.add_child(auto_mode_button)
	
	# Manual mode button  
	manual_mode_button = Button.new()
	manual_mode_button.text = "MANUAL"
	manual_mode_button.custom_minimum_size = Vector2(80, 30)
	manual_mode_button.toggle_mode = true
	manual_mode_button.button_group = auto_mode_button.button_group
	manual_mode_button.pressed.connect(_on_manual_mode_selected)
	mode_container.add_child(manual_mode_button)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	lighting_control_panel.add_child(spacer)
	
	# Mode status label
	var status_label = Label.new()
	status_label.text = "Status: Auto-proximity lighting active"
	status_label.name = "LightingStatusLabel"
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color.GREEN)
	lighting_control_panel.add_child(status_label)

func _on_auto_mode_selected():
	"""Switch to automatic proximity-based lighting"""
	current_lighting_mode = LightingMode.AUTO
	var status_label = get_node("HBoxContainer/ControlsContainer/ControlPanel/LightingControl/LightingStatusLabel")
	status_label.text = "Status: Auto-proximity lighting active"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	
	# Update bed scenes
	if patient_bed_instance:
		patient_bed_instance.set_lighting_mode(PatientBedScene.LightingMode.AUTO)
	if surgical_bed_instance:
		surgical_bed_instance.set_lighting_mode(SurgicalBedScene.LightingMode.AUTO)
	
	add_output("🔄 Lighting mode switched to AUTO")
	add_output("🤖 Lights will automatically respond to patient proximity")
	add_output("🚶 Move patient near beds to see automatic activation")

func _on_manual_mode_selected():
	"""Switch to manual lighting control"""
	current_lighting_mode = LightingMode.MANUAL
	var status_label = get_node("HBoxContainer/ControlsContainer/ControlPanel/LightingControl/LightingStatusLabel")
	status_label.text = "Status: Manual control - Use slider to adjust"
	status_label.add_theme_color_override("font_color", Color.ORANGE)
	
	# Update bed scenes
	if patient_bed_instance:
		patient_bed_instance.set_lighting_mode(PatientBedScene.LightingMode.MANUAL)
	if surgical_bed_instance:
		surgical_bed_instance.set_lighting_mode(SurgicalBedScene.LightingMode.MANUAL)
	
	add_output("🔧 Lighting mode switched to MANUAL")
	add_output("👩‍⚕️ Medical staff now has full lighting control")
	add_output("🎚️ Use the brightness slider to adjust lighting")
	add_output("⚠️ Proximity detection will be ignored in manual mode")

func setup_hospital_room():
	"""Setup the hospital room background"""
	add_output("🏥 Setting up hospital room...")
	
	# Create hospital background
	var bg_sprite = Sprite2D.new()
	bg_sprite.texture = hospital_bg_texture
	bg_sprite.position = Vector2(400, 300)
	bg_sprite.scale = Vector2(2.0, 1.5)
	bg_sprite.modulate.a = 0.3  # Semi-transparent background
	bg_sprite.z_index = -10
	medical_equipment_node.add_child(bg_sprite)

func instantiate_bed_scenes():
	"""Instantiate the separate bed scenes"""
	add_output("🛏️ Loading separate bed scenes...")
	
	# Instantiate patient bed scene
	if patient_bed_scene:
		patient_bed_instance = patient_bed_scene.instantiate()
		patient_bed_instance.position = patient_bed_position
		patient_bed_instance.name = "PatientBedScene"
		
		# Connect signals
		patient_bed_instance.patient_approached.connect(_on_bed_patient_approached)
		patient_bed_instance.patient_left.connect(_on_bed_patient_left)
		patient_bed_instance.lighting_changed.connect(_on_bed_lighting_changed)
		
		medical_equipment_node.add_child(patient_bed_instance)
		add_output("✅ Patient bed scene loaded at position: " + str(patient_bed_position))
	else:
		add_output("❌ Failed to load patient bed scene")
	
	# Instantiate surgical bed scene
	if surgical_bed_scene:
		surgical_bed_instance = surgical_bed_scene.instantiate()
		surgical_bed_instance.position = surgical_bed_position
		surgical_bed_instance.name = "SurgicalBedScene"
		
		# Connect signals
		surgical_bed_instance.patient_approached.connect(_on_bed_patient_approached)
		surgical_bed_instance.patient_left.connect(_on_bed_patient_left)
		surgical_bed_instance.lighting_changed.connect(_on_bed_lighting_changed)
		
		medical_equipment_node.add_child(surgical_bed_instance)
		add_output("✅ Surgical bed scene loaded at position: " + str(surgical_bed_position))
	else:
		add_output("❌ Failed to load surgical bed scene")
	
	add_output("🏥 All bed scenes ready for patient interaction!")

func create_patient_character():
	"""Create a moveable patient character for proximity testing"""
	# Create patient character as Area2D for collision detection
	patient_character = Area2D.new()
	patient_character.name = "PatientCharacter"
	patient_character.position = Vector2(100, 400)  # Start position
	
	# Create patient sprite (using a simple circle for now)
	patient_sprite = Sprite2D.new()
	# Create a simple colored circle as patient representation
	var image = Image.create(40, 40, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLUE)  # Blue circle for patient
	var texture = ImageTexture.new()
	texture.set_image(image)
	patient_sprite.texture = texture
	patient_sprite.scale = Vector2(0.8, 0.8)
	patient_character.add_child(patient_sprite)
	
	# Add collision shape for proximity detection
	var patient_collision = CollisionShape2D.new()
	var patient_shape = CircleShape2D.new()
	patient_shape.radius = 20
	patient_collision.shape = patient_shape
	patient_character.add_child(patient_collision)
	
	# Make patient draggable
	patient_character.input_pickable = true
	patient_character.input_event.connect(_on_patient_input)
	
	medical_equipment_node.add_child(patient_character)
	
	add_output("🚶 Patient character created - drag to move around hospital!")
	add_output("💙 Blue circle represents the patient")

func _on_patient_input(_viewport, event, _shape_idx):
	"""Handle patient character dragging"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging_patient = true
				drag_offset = patient_character.global_position - event.global_position
				add_output("🚶 Dragging patient...")
			else:
				is_dragging_patient = false
				add_output("🚶 Patient positioned at: " + str(patient_character.position))
	
	elif event is InputEventMouseMotion and is_dragging_patient:
		patient_character.global_position = event.global_position + drag_offset

# Signal handlers from bed scenes
func _on_bed_patient_approached(bed_type: String):
	"""Handle patient approach signal from bed scenes"""
	add_output("🚶➡️🛏️ Patient approaching " + bed_type + " bed! (From bed scene)")
	
	# Update UI based on lighting mode
	if current_lighting_mode == LightingMode.AUTO:
		lighting_slider.value = 100
		brightness_value.text = "100% (Auto)"

func _on_bed_patient_left(bed_type: String):
	"""Handle patient leaving signal from bed scenes"""
	add_output("🚶⬅️🛏️ Patient left " + bed_type + " bed area (From bed scene)")
	
	# Update UI based on lighting mode
	if current_lighting_mode == LightingMode.AUTO:
		lighting_slider.value = 30
		brightness_value.text = "30% (Auto)"

func _on_bed_lighting_changed(bed_type: String, brightness: float):
	"""Handle lighting change signal from bed scenes"""
	add_output("💡 " + bed_type.capitalize() + " bed lighting: " + str(int(brightness)) + "%")

func initialize_medical_equipment():
	"""Initialize C++ extension objects for enhanced functionality"""
	add_output("\n🔧 === MEDICAL EQUIPMENT C++ EXTENSION INITIALIZATION ===")
	
	# Test C++ extension availability
	if ClassDB.class_exists("BedFactory"):
		add_output("✅ C++ Extension Available: BedFactory found")
		bed_factory = ClassDB.instantiate("BedFactory")
		
		if bed_factory:
			add_output("✅ C++ BedFactory instantiated successfully")
			add_output("🏥 Bed scenes will handle their own C++ integration")
		else:
			add_output("❌ Failed to instantiate BedFactory")
	else:
		add_output("ℹ️ C++ Extension not loaded - bed scenes using simulation mode")
	
	# Test CustomWindow
	if ClassDB.class_exists("CustomWindow"):
		add_output("✅ C++ Extension Available: CustomWindow found")
		custom_window = ClassDB.instantiate("CustomWindow")
		if custom_window:
			add_output("✅ C++ CustomWindow instantiated for monitoring")
	
	add_output("🏥 Medical equipment backend ready with separate bed scenes!")

func _on_lighting_slider_changed(value: float):
	"""Handle manual lighting slider changes"""
	brightness_value.text = str(int(value)) + "%"
	manual_brightness = value
	
	# Switch to manual mode when user adjusts slider
	if current_lighting_mode == LightingMode.AUTO:
		current_lighting_mode = LightingMode.MANUAL
		manual_mode_button.button_pressed = true
		auto_mode_button.button_pressed = false
		
		var status_label = get_node("HBoxContainer/ControlsContainer/ControlPanel/LightingControl/LightingStatusLabel")
		status_label.text = "Status: Manual control - Use slider to adjust"
		status_label.add_theme_color_override("font_color", Color.ORANGE)
		
		add_output("🔧 Lighting mode auto-switched to MANUAL (slider used)")
		add_output("💡 Medical staff can now adjust lighting as needed")
	
	# Apply manual brightness to both bed scenes
	if patient_bed_instance:
		patient_bed_instance.set_lighting_mode(PatientBedScene.LightingMode.MANUAL)
		patient_bed_instance.set_manual_brightness(value)
	
	if surgical_bed_instance:
		surgical_bed_instance.set_lighting_mode(SurgicalBedScene.LightingMode.MANUAL)
		surgical_bed_instance.set_manual_brightness(value)
	
	add_output("👩‍⚕️ Manual lighting adjustment: " + str(int(value)) + "% (Medical Override)")

func add_output(text: String):
	"""Add text to the output display"""
	if output_label:
		output_label.text += text + "\n"
		
		# Auto-scroll to bottom
		var scroll_container = output_label.get_parent()
		if scroll_container is ScrollContainer:
			scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
