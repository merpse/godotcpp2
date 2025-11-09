# Enhanced Surgical Bed Scene with Height Animation and Temperature Control
# Following Godot UI tutorial patterns for modular scene design

extends Area2D
class_name SurgicalBedScene

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

# Temperature colors (sterile environment focused)
var temperature_colors = {
	Temperature.COOL: Color(0.8, 0.95, 1.0, 1.0),   # Cool sterile blue
	Temperature.NORMAL: Color(1.0, 1.0, 1.0, 1.0),   # Sterile white
	Temperature.WARM: Color(1.0, 0.8, 0.8, 1.0)      # Warm sterile red
}

# Node references
@onready var bed_sprite = $BedSprite
@onready var light_strip = $LightStrip
@onready var proximity_area = $ProximityArea
@onready var proximity_collision = $ProximityCollision
@onready var animation_player = $AnimationPlayer
@onready var control_panel = $ControlPanel

# Medical Equipment References (C++ Extension Objects)
var cpp_surgical_bed
var bed_factory

# Signals for communication with main demo
signal patient_approached(bed_type: String)
signal patient_left(bed_type: String)
signal lighting_changed(bed_type: String, brightness: float)
signal bed_height_changed(bed_type: String, height: BedHeight)
signal temperature_changed(bed_type: String, temperature: Temperature)

func _ready():
	print("🔬 Surgical Bed scene initialized")
	base_bed_position = bed_sprite.position
	setup_bed()
	setup_proximity_detection()
	setup_control_panel()
	initialize_cpp_extension()

func setup_control_panel():
	"""Setup the surgical bed control panel UI"""
	# Connect animation player signal
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# Setup height control buttons
	var height_low_btn = control_panel.get_node("HeightControls/LowButton")
	var height_med_btn = control_panel.get_node("HeightControls/MediumButton")
	var height_high_btn = control_panel.get_node("HeightControls/HighButton")
	
	height_low_btn.pressed.connect(_on_height_low_pressed)
	height_med_btn.pressed.connect(_on_height_medium_pressed)
	height_high_btn.pressed.connect(_on_height_high_pressed)
	
	# Setup temperature control buttons
	var temp_cool_btn = control_panel.get_node("TemperatureControls/CoolButton")
	var temp_normal_btn = control_panel.get_node("TemperatureControls/NormalButton")
	var temp_warm_btn = control_panel.get_node("TemperatureControls/WarmButton")
	
	temp_cool_btn.pressed.connect(_on_temperature_cool_pressed)
	temp_normal_btn.pressed.connect(_on_temperature_normal_pressed)
	temp_warm_btn.pressed.connect(_on_temperature_warm_pressed)
	
	# Setup lighting control buttons
	var light_auto_btn = control_panel.get_node("LightingControls/AutoButton")
	var light_manual_btn = control_panel.get_node("LightingControls/ManualButton")
	
	light_auto_btn.pressed.connect(_on_lighting_auto_pressed)
	light_manual_btn.pressed.connect(_on_lighting_manual_pressed)
	
	print("🎛️ Surgical bed control panel setup complete")

# Height control functions
func _on_height_low_pressed():
	set_bed_height(BedHeight.LOW)

func _on_height_medium_pressed():
	set_bed_height(BedHeight.MEDIUM)

func _on_height_high_pressed():
	set_bed_height(BedHeight.HIGH)

func set_bed_height(height: BedHeight):
	"""Set bed height with smooth animation"""
	if is_animating or current_bed_height == height:
		return
	
	current_bed_height = height
	is_animating = true
	
	# Calculate target position
	var height_offsets = {
		BedHeight.LOW: -20.0,
		BedHeight.MEDIUM: 0.0,
		BedHeight.HIGH: 20.0
	}
	
	target_height = height_offsets[height]
	
	# Play height animation
	match height:
		BedHeight.LOW:
			animation_player.play("height_low")
		BedHeight.MEDIUM:
			animation_player.play("height_medium")
		BedHeight.HIGH:
			animation_player.play("height_high")
	
	# Emit signal
	bed_height_changed.emit("surgical", height)
	
	print("🏥 Surgical bed height set to: ", BedHeight.keys()[height])

# Temperature control functions
func _on_temperature_cool_pressed():
	set_bed_temperature(Temperature.COOL)

func _on_temperature_normal_pressed():
	set_bed_temperature(Temperature.NORMAL)

func _on_temperature_warm_pressed():
	set_bed_temperature(Temperature.WARM)

func set_bed_temperature(temperature: Temperature):
	"""Set bed temperature with visual feedback"""
	if current_temperature == temperature:
		return
	
	current_temperature = temperature
	var color = temperature_colors[temperature]
	bed_sprite.modulate = color
	
	# Update C++ extension
	if cpp_surgical_bed:
		match temperature:
			Temperature.COOL:
				cpp_surgical_bed.set_temperature(18.0)  # 18°C
			Temperature.NORMAL:
				cpp_surgical_bed.set_temperature(22.0)  # 22°C
			Temperature.WARM:
				cpp_surgical_bed.set_temperature(26.0)  # 26°C
	
	temperature_changed.emit("surgical", temperature)
	print("🌡️ Surgical bed temperature: ", Temperature.keys()[temperature], " - Color: ", color)

# Lighting control functions
func _on_lighting_auto_pressed():
	set_lighting_mode(LightingMode.AUTO)

func _on_lighting_manual_pressed():
	set_lighting_mode(LightingMode.MANUAL)

func _on_animation_finished(anim_name: String):
	"""Called when bed height animation completes"""
	is_animating = false
	print("✅ Surgical bed animation completed: ", anim_name)
	setup_bed()
	setup_proximity_detection()
	initialize_cpp_extension()

func setup_bed():
	"""Setup the surgical bed visual elements"""
	# Setup light strip
	light_strip.texture = light_strip_texture
	light_strip.modulate = Color(1.0, 1.0, 1.0, 0.3)  # Pure white, dim initially
	
	# Setup collision shape for the bed itself
	var bed_collision = CollisionShape2D.new()
	var bed_shape = RectangleShape2D.new()
	bed_shape.size = Vector2(100, 60)
	bed_collision.shape = bed_shape
	add_child(bed_collision)

func setup_proximity_detection():
	"""Setup proximity detection for automatic lighting"""
	# Setup proximity area collision
	var proximity_shape = CircleShape2D.new()
	proximity_shape.radius = 80  # Detection radius
	proximity_collision.shape = proximity_shape
	
	# Connect proximity signals
	proximity_area.area_entered.connect(_on_proximity_entered)
	proximity_area.area_exited.connect(_on_proximity_exited)
	
	print("🔍 Surgical bed proximity detection active (80px radius)")

func initialize_cpp_extension():
	"""Initialize C++ extension integration"""
	if ClassDB.class_exists("BedFactory"):
		bed_factory = ClassDB.instantiate("BedFactory")
		if bed_factory:
			cpp_surgical_bed = bed_factory.create_surgical_bed()
			if cpp_surgical_bed:
				cpp_surgical_bed.set_name("Scene Surgical Bed")
				print("✅ C++ SurgicalBed extension integrated")
			else:
				print("⚠️ Failed to create C++ SurgicalBed object")
	else:
		print("ℹ️ C++ Extension not available - using GDScript simulation")

func _on_proximity_entered(area: Area2D):
	"""Called when something enters proximity detection area"""
	if area.name == "PatientCharacter":
		print("🚶➡️🔬 Patient approaching surgical bed!")
		patient_approached.emit("surgical")
		
		# Auto-activate lights if in auto mode
		if current_lighting_mode == LightingMode.AUTO:
			activate_lights()

func _on_proximity_exited(area: Area2D):
	"""Called when something exits proximity detection area"""
	if area.name == "PatientCharacter":
		print("🚶⬅️🔬 Patient leaving surgical bed area")
		patient_left.emit("surgical")
		
		# Auto-dim lights if in auto mode
		if current_lighting_mode == LightingMode.AUTO:
			dim_lights()

func activate_lights():
	"""Activate bright sterile lighting for surgical bed"""
	light_strip.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Bright white light
	lighting_changed.emit("surgical", 100.0)
	
	# Trigger C++ extension if available
	if cpp_surgical_bed:
		cpp_surgical_bed.activate_lights()
		cpp_surgical_bed.set_light_brightness(1.0)
		cpp_surgical_bed.enter_sterile_mode()
		print("✅ C++ SurgicalBed lighting and sterile systems activated")
	
	print("💡 Surgical bed lights ACTIVATED - Bright sterile lighting!")

func dim_lights():
	"""Dim lights to standby mode"""
	light_strip.modulate = Color(1.0, 1.0, 1.0, 0.3)  # Dim white light
	lighting_changed.emit("surgical", 30.0)
	
	print("💡 Surgical bed lights dimmed to standby mode")

func set_lighting_mode(mode: LightingMode):
	"""Set the lighting control mode"""
	current_lighting_mode = mode
	print("🔧 Surgical bed lighting mode: ", LightingMode.keys()[mode])

func set_manual_brightness(brightness: float):
	"""Set manual brightness (0-100)"""
	if current_lighting_mode == LightingMode.MANUAL:
		var alpha = brightness / 100.0
		light_strip.modulate = Color(1.0, 1.0, 1.0, alpha)
		lighting_changed.emit("surgical", brightness)
		
		# Update C++ extension
		if cpp_surgical_bed:
			cpp_surgical_bed.set_light_brightness(alpha)
		
		print("👩‍⚕️ Surgical bed manual brightness: ", int(brightness), "%")

func get_bed_type() -> String:
	return "surgical"

func get_lighting_info() -> Dictionary:
	return {
		"bed_type": "surgical",
		"lighting_mode": current_lighting_mode,
		"current_brightness": light_strip.modulate.a * 100.0,
		"light_color": "sterile_white",
		"cpp_extension": cpp_surgical_bed != null
	}