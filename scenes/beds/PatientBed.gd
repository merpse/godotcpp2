# Enhanced Patient Bed Scene with Height Animation and Temperature Control
# Following Godot UI tutorial patterns for modular scene design

extends Area2D
class_name PatientBedScene

@export var light_strip_texture: Texture2D = preload("res://assets/medical/light_strip.svg")

# Lighting control modes
enum LightingMode { AUTO, MANUAL, OVERRIDE }
var current_lighting_mode = LightingMode.AUTO
var manual_brightness = 50.0

# Bed control states
enum BedHeight { LOW, MEDIUM, HIGH }
enum Temperature { COOL, NORMAL, WARM }

var current_bed_height = BedHeight.MEDIUM
var current_temperature = Temperature.NORMAL
var base_bed_position: Vector2

# Animation properties
var is_animating = false
var height_offset = 0.0
var target_height = 0.0

# Temperature colors
var temperature_colors = {
	Temperature.COOL: Color(0.7, 0.9, 1.0, 1.0),    # Cool blue tint
	Temperature.NORMAL: Color(1.0, 1.0, 1.0, 1.0),   # Normal white
	Temperature.WARM: Color(1.0, 0.7, 0.7, 1.0)      # Warm red tint
}

# Node references
@onready var bed_sprite = $BedSprite
@onready var light_strip = $LightStrip
@onready var proximity_area = $ProximityArea
@onready var proximity_collision = $ProximityCollision
@onready var animation_player = $AnimationPlayer
@onready var bed_controls = $BedControls

# Medical Equipment References (C++ Extension Objects)
var cpp_patient_bed
var bed_factory

# Signals for communication with main demo
signal patient_approached(bed_type: String)
signal patient_left(bed_type: String)
signal lighting_changed(bed_type: String, brightness: float)
signal bed_height_changed(bed_type: String, height: BedHeight)
signal temperature_changed(bed_type: String, temp: Temperature)

func _ready():
	print("🛏️ Enhanced Patient Bed scene initialized")
	base_bed_position = position
	setup_bed()
	setup_proximity_detection()
	setup_bed_controls()
	setup_animations()
	initialize_cpp_extension()

func setup_bed():
	"""Setup the patient bed visual elements"""
	# Setup light strip
	light_strip.texture = light_strip_texture
	light_strip.modulate = Color(1.0, 0.9, 0.7, 0.3)  # Warm, dim initially
	
	# Setup collision shape for the bed itself
	var bed_collision = CollisionShape2D.new()
	var bed_shape = RectangleShape2D.new()
	bed_shape.size = Vector2(100, 60)
	bed_collision.shape = bed_shape
	add_child(bed_collision)
	
	# Set initial temperature appearance
	update_temperature_appearance()

func setup_bed_controls():
	"""Setup UI controls for bed height and temperature following tutorial pattern"""
	# Create bed controls container
	var controls_container = VBoxContainer.new()
	controls_container.name = "BedControls"
	controls_container.position = Vector2(-60, -100)
	add_child(controls_container)
	
	# Height control section
	var height_label = Label.new()
	height_label.text = "Bed Height"
	height_label.add_theme_font_size_override("font_size", 12)
	controls_container.add_child(height_label)
	
	var height_buttons = HBoxContainer.new()
	controls_container.add_child(height_buttons)
	
	# Height buttons
	var low_button = Button.new()
	low_button.text = "Low"
	low_button.custom_minimum_size = Vector2(40, 25)
	low_button.pressed.connect(_on_height_button_pressed.bind(BedHeight.LOW))
	height_buttons.add_child(low_button)
	
	var med_button = Button.new()
	med_button.text = "Med"
	med_button.custom_minimum_size = Vector2(40, 25)
	med_button.pressed.connect(_on_height_button_pressed.bind(BedHeight.MEDIUM))
	height_buttons.add_child(med_button)
	
	var high_button = Button.new()
	high_button.text = "High"
	high_button.custom_minimum_size = Vector2(40, 25)
	high_button.pressed.connect(_on_height_button_pressed.bind(BedHeight.HIGH))
	height_buttons.add_child(high_button)
	
	# Temperature control section
	var temp_label = Label.new()
	temp_label.text = "Temperature"
	temp_label.add_theme_font_size_override("font_size", 12)
	controls_container.add_child(temp_label)
	
	var temp_buttons = HBoxContainer.new()
	controls_container.add_child(temp_buttons)
	
	# Temperature buttons
	var cool_button = Button.new()
	cool_button.text = "Cool"
	cool_button.custom_minimum_size = Vector2(40, 25)
	cool_button.modulate = Color(0.7, 0.9, 1.0, 1.0)
	cool_button.pressed.connect(_on_temperature_button_pressed.bind(Temperature.COOL))
	temp_buttons.add_child(cool_button)
	
	var normal_button = Button.new()
	normal_button.text = "Normal"
	normal_button.custom_minimum_size = Vector2(40, 25)
	normal_button.pressed.connect(_on_temperature_button_pressed.bind(Temperature.NORMAL))
	temp_buttons.add_child(normal_button)
	
	var warm_button = Button.new()
	warm_button.text = "Warm"
	warm_button.custom_minimum_size = Vector2(40, 25)
	warm_button.modulate = Color(1.0, 0.7, 0.7, 1.0)
	warm_button.pressed.connect(_on_temperature_button_pressed.bind(Temperature.WARM))
	temp_buttons.add_child(warm_button)

func setup_animations():
	"""Setup animation player for bed height transitions"""
	var anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)
	
	# Create height animations
	create_height_animations(anim_player)

func create_height_animations(anim_player: AnimationPlayer):
	"""Create smooth height transition animations"""
	var library = AnimationLibrary.new()
	
	# Animation for going to low height
	var low_anim = Animation.new()
	low_anim.length = 0.5
	low_anim.loop_mode = Animation.LOOP_NONE
	
	var position_track = low_anim.add_track(Animation.TYPE_POSITION_3D)
	low_anim.track_set_path(position_track, NodePath("BedSprite"))
	low_anim.track_insert_key(position_track, 0.0, Vector3(0, 0, 0))
	low_anim.track_insert_key(position_track, 0.5, Vector3(0, 10, 0))  # Lower position
	
	library.add_animation("height_low", low_anim)
	
	# Animation for going to medium height
	var med_anim = Animation.new()
	med_anim.length = 0.5
	med_anim.loop_mode = Animation.LOOP_NONE
	
	position_track = med_anim.add_track(Animation.TYPE_POSITION_3D)
	med_anim.track_set_path(position_track, NodePath("BedSprite"))
	med_anim.track_insert_key(position_track, 0.0, Vector3(0, bed_sprite.position.y, 0))
	med_anim.track_insert_key(position_track, 0.5, Vector3(0, 0, 0))  # Normal position
	
	library.add_animation("height_medium", med_anim)
	
	# Animation for going to high height
	var high_anim = Animation.new()
	high_anim.length = 0.5
	high_anim.loop_mode = Animation.LOOP_NONE
	
	position_track = high_anim.add_track(Animation.TYPE_POSITION_3D)
	high_anim.track_set_path(position_track, NodePath("BedSprite"))
	high_anim.track_insert_key(position_track, 0.0, Vector3(0, bed_sprite.position.y, 0))
	high_anim.track_insert_key(position_track, 0.5, Vector3(0, -10, 0))  # Higher position
	
	library.add_animation("height_high", high_anim)
	
	anim_player.add_animation_library("bed_animations", library)

func _on_height_button_pressed(height: BedHeight):
	"""Handle bed height button press"""
	if is_animating:
		return
		
	current_bed_height = height
	is_animating = true
	
	var anim_player = get_node("AnimationPlayer")
	var anim_name = ""
	
	match height:
		BedHeight.LOW:
			anim_name = "bed_animations/height_low"
			print("🛏️ Patient bed height: LOW")
		BedHeight.MEDIUM:
			anim_name = "bed_animations/height_medium"
			print("🛏️ Patient bed height: MEDIUM")
		BedHeight.HIGH:
			anim_name = "bed_animations/height_high"
			print("🛏️ Patient bed height: HIGH")
	
	anim_player.play(anim_name)
	anim_player.animation_finished.connect(_on_height_animation_finished, CONNECT_ONE_SHOT)
	
	bed_height_changed.emit("patient", height)

func _on_height_animation_finished(_anim_name: String):
	"""Handle height animation completion"""
	is_animating = false
	print("✅ Patient bed height animation completed")

func _on_temperature_button_pressed(temp: Temperature):
	"""Handle temperature button press"""
	current_temperature = temp
	update_temperature_appearance()
	
	var temp_name = ""
	match temp:
		Temperature.COOL:
			temp_name = "COOL (Blue)"
		Temperature.NORMAL:
			temp_name = "NORMAL"
		Temperature.WARM:
			temp_name = "WARM (Red)"
	
	print("🌡️ Patient bed temperature: ", temp_name)
	temperature_changed.emit("patient", temp)

func update_temperature_appearance():
	"""Update bed appearance based on temperature"""
	var color = temperature_colors[current_temperature]
	bed_sprite.modulate = color

func setup_proximity_detection():
	"""Setup proximity detection for automatic lighting"""
	# Setup proximity area collision
	var proximity_shape = CircleShape2D.new()
	proximity_shape.radius = 80  # Detection radius
	proximity_collision.shape = proximity_shape
	
	# Connect proximity signals
	proximity_area.area_entered.connect(_on_proximity_entered)
	proximity_area.area_exited.connect(_on_proximity_exited)
	
	print("🔍 Patient bed proximity detection active (80px radius)")

func initialize_cpp_extension():
	"""Initialize C++ extension integration"""
	if ClassDB.class_exists("BedFactory"):
		bed_factory = ClassDB.instantiate("BedFactory")
		if bed_factory:
			cpp_patient_bed = bed_factory.create_patient_bed()
			if cpp_patient_bed:
				cpp_patient_bed.set_name("Scene Patient Bed")
				print("✅ C++ PatientBed extension integrated")
			else:
				print("⚠️ Failed to create C++ PatientBed object")
	else:
		print("ℹ️ C++ Extension not available - using GDScript simulation")

func _on_proximity_entered(area: Area2D):
	"""Called when something enters proximity detection area"""
	if area.name == "PatientCharacter":
		print("🚶➡️🛏️ Patient approaching patient bed!")
		patient_approached.emit("patient")
		
		# Auto-activate lights if in auto mode
		if current_lighting_mode == LightingMode.AUTO:
			activate_lights()

func _on_proximity_exited(area: Area2D):
	"""Called when something exits proximity detection area"""
	if area.name == "PatientCharacter":
		print("🚶⬅️🛏️ Patient leaving patient bed area")
		patient_left.emit("patient")
		
		# Auto-dim lights if in auto mode
		if current_lighting_mode == LightingMode.AUTO:
			dim_lights()

func activate_lights():
	"""Activate bright comfortable lighting for patient bed"""
	light_strip.modulate = Color(1.0, 0.9, 0.7, 1.0)  # Bright warm light
	lighting_changed.emit("patient", 100.0)
	
	# Trigger C++ extension if available
	if cpp_patient_bed:
		cpp_patient_bed.activate_lights()
		cpp_patient_bed.set_light_brightness(1.0)
		print("✅ C++ PatientBed lighting activated")
	
	print("💡 Patient bed lights ACTIVATED - Warm comfortable lighting!")

func dim_lights():
	"""Dim lights to standby mode"""
	light_strip.modulate = Color(1.0, 0.9, 0.7, 0.3)  # Dim warm light
	lighting_changed.emit("patient", 30.0)
	
	print("💡 Patient bed lights dimmed to standby mode")

func set_lighting_mode(mode: LightingMode):
	"""Set the lighting control mode"""
	current_lighting_mode = mode
	print("🔧 Patient bed lighting mode: ", LightingMode.keys()[mode])

func set_manual_brightness(brightness: float):
	"""Set manual brightness (0-100)"""
	if current_lighting_mode == LightingMode.MANUAL:
		var alpha = brightness / 100.0
		light_strip.modulate = Color(1.0, 0.9, 0.7, alpha)
		lighting_changed.emit("patient", brightness)
		
		# Update C++ extension
		if cpp_patient_bed:
			cpp_patient_bed.set_light_brightness(alpha)
		
		print("👩‍⚕️ Patient bed manual brightness: ", int(brightness), "%")

func get_bed_type() -> String:
	return "patient"

func get_bed_status() -> Dictionary:
	"""Get comprehensive bed status following tutorial pattern"""
	return {
		"bed_type": "patient",
		"lighting_mode": current_lighting_mode,
		"current_brightness": light_strip.modulate.a * 100.0,
		"light_color": "warm",
		"height": current_bed_height,
		"temperature": current_temperature,
		"temperature_color": temperature_colors[current_temperature],
		"is_animating": is_animating,
		"cpp_extension": cpp_patient_bed != null
	}
