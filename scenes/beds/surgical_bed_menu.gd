# Surgical Bed Menu Scene - Interactive Control Interface with C++ GDExtension Integration
# Professional medical equipment menu following Godot UI patterns

extends MarginContainer
class_name SurgicalBedMenuScene

# Surgical bed control states
enum BedHeight { LOW, MEDIUM, HIGH }
enum Temperature { COOL, NORMAL, WARM }
enum LightingMode { AUTO, MANUAL }
enum EmergencyState { NORMAL, EMERGENCY }
enum ScannerState { OFF, ON, SCANNING }
enum ScannerPosition { CENTER, RIGHT }

var current_bed_height = BedHeight.MEDIUM
var current_temperature = Temperature.NORMAL
var current_lighting_mode = LightingMode.AUTO
var current_emergency_state = EmergencyState.NORMAL
var current_scanner_state = ScannerState.OFF
var current_scanner_position = ScannerPosition.CENTER
var manual_brightness = 50.0
var rgb_values = {"red": 100.0, "green": 100.0, "blue": 100.0}
var emergency_blink_timer: Timer
var scanner_move_tween: Tween
var is_blinking = false
var is_scanning = false

# C++ GDExtension Objects
var cpp_surgical_bed = null
var bed_factory = null
var cpp_light_strip = null

# Visual feedback colors for temperature
var temperature_colors = {
	Temperature.COOL: Color(0.7, 0.9, 1.0, 1.0),    # Cool blue
	Temperature.NORMAL: Color(1.0, 1.0, 1.0, 1.0),   # Normal white
	Temperature.WARM: Color(1.0, 0.8, 0.8, 1.0)      # Warm red
}

# Mouse interaction colors
var hover_color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow for hover
var normal_color = Color(1.0, 1.0, 1.0, 1.0)  # White normal
var is_bed_hovered = false
var is_scanner_hovered = false

# Node references (will be set in _ready)
@onready var bed_image = $HBoxContainer/BedDisplay/BedImage
@onready var height_low_btn = $HBoxContainer/ControlsPanel/HeightControls/HeightButtons/LowButton
@onready var height_medium_btn = $HBoxContainer/ControlsPanel/HeightControls/HeightButtons/MediumButton
@onready var height_high_btn = $HBoxContainer/ControlsPanel/HeightControls/HeightButtons/HighButton
@onready var temp_cool_btn = $HBoxContainer/ControlsPanel/TemperatureControls/TempButtons/CoolButton
@onready var temp_normal_btn = $HBoxContainer/ControlsPanel/TemperatureControls/TempButtons/NormalButton
@onready var temp_warm_btn = $HBoxContainer/ControlsPanel/TemperatureControls/TempButtons/WarmButton
@onready var light_auto_btn = $HBoxContainer/ControlsPanel/LightingControls/LightButtons/AutoButton
@onready var light_manual_btn = $HBoxContainer/ControlsPanel/LightingControls/LightButtons/ManualButton
@onready var brightness_slider = $HBoxContainer/ControlsPanel/LightingControls/BrightnessControl/BrightnessSlider
@onready var red_slider = $HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedSlider
@onready var green_slider = $HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenSlider
@onready var blue_slider = $HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueSlider
@onready var red_value_label = $HBoxContainer/ControlsPanel/LightingControls/ColorControls/RedControl/RedValue
@onready var green_value_label = $HBoxContainer/ControlsPanel/LightingControls/ColorControls/GreenControl/GreenValue
@onready var blue_value_label = $HBoxContainer/ControlsPanel/LightingControls/ColorControls/BlueControl/BlueValue
@onready var emergency_btn = $HBoxContainer/ControlsPanel/LightingControls/EmergencyControl/EmergencyButton
@onready var light_bar = $HBoxContainer/BedDisplay/LightBar
@onready var scanner = $HBoxContainer/BedDisplay/Scanner
@onready var scanner_power_btn = $HBoxContainer/ControlsPanel/ScannerControls/ScannerButtons/PowerButton
@onready var scanner_scan_btn = $HBoxContainer/ControlsPanel/ScannerControls/ScannerButtons/ScanButton
@onready var scanner_right_btn = $HBoxContainer/ControlsPanel/ScannerControls/ScannerPosition/PositionButtons/RightButton
@onready var scanner_center_btn = $HBoxContainer/ControlsPanel/ScannerControls/ScannerPosition/PositionButtons/CenterButton
@onready var scanner_status_label = $HBoxContainer/ControlsPanel/ScannerControls/ScannerStatus
@onready var status_label = $HBoxContainer/ControlsPanel/StatusPanel/StatusLabel

# Signals for external communication
signal bed_height_changed(height: BedHeight)
signal bed_temperature_changed(temperature: Temperature)
signal lighting_mode_changed(mode: LightingMode)
signal brightness_changed(value: float)
signal rgb_color_changed(color: String, value: float)
signal emergency_mode_changed(is_emergency: bool)
signal scanner_state_changed(state: ScannerState)
signal scanner_position_changed(position: ScannerPosition)
signal scan_completed(scan_data: Dictionary)

func _ready():
	print("🏥 Surgical Bed Menu initialized")
	setup_emergency_timer()
	initialize_cpp_extension()
	setup_controls()
	update_display()

# Clean up resources when scene exits to prevent memory leaks
func _exit_tree():
	print("🧹 Cleaning up Surgical Bed Menu resources...")
	
	# Clean up emergency timer
	if emergency_blink_timer:
		if emergency_blink_timer.timeout.is_connected(_on_emergency_blink):
			emergency_blink_timer.timeout.disconnect(_on_emergency_blink)
		emergency_blink_timer.queue_free()
		emergency_blink_timer = null
	
	# Clean up C++ objects (call queue_free directly)
	if cpp_surgical_bed:
		cpp_surgical_bed.queue_free()
		cpp_surgical_bed = null
	
	if cpp_light_strip:
		cpp_light_strip.queue_free()
		cpp_light_strip = null
	
	print("✅ Surgical Bed Menu cleanup complete")

func initialize_cpp_extension():
	# Initialize C++ GDExtension surgical bed
	print("🔗 Initializing C++ GDExtension...")
	
	if ClassDB.class_exists("BedFactory"):
		bed_factory = ClassDB.instantiate("BedFactory")
		if bed_factory:
			print("✅ BedFactory created successfully")
			cpp_surgical_bed = bed_factory.create_surgical_bed()
			if cpp_surgical_bed:
				print("✅ C++ SurgicalBed created successfully")
				cpp_surgical_bed.set_name("SurgicalBedMenu_CPP")
				
				# Power on the bed for testing
				cpp_surgical_bed.power_on()
				
				# Set initial surgical bed configuration
				cpp_surgical_bed.enter_sterile_mode()
				cpp_surgical_bed.set_height(85.0)  # Optimal surgical height
				
				print("🏥 C++ Surgical Bed initialized and powered on")
				print("🔬 Sterile mode activated")
				
				# Test some functions to verify they work
				test_cpp_functions()
			else:
				print("❌ Failed to create C++ SurgicalBed object")
				setup_fallback_simulation()
		else:
			print("❌ Failed to create BedFactory")
			setup_fallback_simulation()
	
	# Initialize C++ Light Strip with Strategy pattern
	if ClassDB.class_exists("GodotLightStrip"):
		cpp_light_strip = ClassDB.instantiate("GodotLightStrip")
		if cpp_light_strip:
			print("✅ C++ GodotLightStrip created successfully")
			cpp_light_strip.set_name("SurgicalLightStrip")
			add_child(cpp_light_strip)
			
			# Activate the light strip and set initial behavior
			cpp_light_strip.activate()
			cpp_light_strip.set_behavior("auto")  # Start in auto mode
			
			print("💡 C++ Strategy-based Light Strip initialized and activated")
			print("🔆 Initial mode: ", cpp_light_strip.get_current_mode())
		else:
			print("❌ Failed to create GodotLightStrip object")
	else:
		print("⚠️ GodotLightStrip class not available")

func test_cpp_functions():
	# Test C++ functions to verify integration
	if cpp_surgical_bed:
		print("🧪 Testing C++ surgical bed functions...")
		
		# Test height functions
		var current_height = cpp_surgical_bed.get_height()
		print("📏 Current C++ bed height: ", current_height, " cm")
		
		# Test temperature functions  
		var temp_value = cpp_surgical_bed.get_temperature_value()
		print("🌡️ Current C++ temperature: ", temp_value, "°C")
		
		# Test lighting functions
		cpp_surgical_bed.activate_lights()
		cpp_surgical_bed.set_light_brightness(0.8)
		print("💡 C++ lighting system tested")
		
		print("✅ C++ function testing complete")

func setup_fallback_simulation():
	# Setup fallback when C++ extension is not available
	print("🎭 Setting up GDScript simulation mode")
	# Continue with GDScript-only functionality

func setup_controls():
	# Setup all control connections and initial states
	# Height control buttons
	height_low_btn.pressed.connect(_on_height_low_pressed)
	height_medium_btn.pressed.connect(_on_height_medium_pressed)
	height_high_btn.pressed.connect(_on_height_high_pressed)
	
	# Temperature control buttons
	temp_cool_btn.pressed.connect(_on_temperature_cool_pressed)
	temp_normal_btn.pressed.connect(_on_temperature_normal_pressed)
	temp_warm_btn.pressed.connect(_on_temperature_warm_pressed)
	
	# Lighting control buttons
	light_auto_btn.pressed.connect(_on_lighting_auto_pressed)
	light_manual_btn.pressed.connect(_on_lighting_manual_pressed)
	
	# Brightness slider
	brightness_slider.value_changed.connect(_on_brightness_changed)
	brightness_slider.value = manual_brightness
	brightness_slider.editable = false  # Initially disabled in AUTO mode
	
	# RGB Color control sliders
	red_slider.value_changed.connect(_on_red_changed)
	green_slider.value_changed.connect(_on_green_changed)
	blue_slider.value_changed.connect(_on_blue_changed)
	red_slider.value = rgb_values["red"]
	green_slider.value = rgb_values["green"]
	blue_slider.value = rgb_values["blue"]
	
	# Emergency mode button
	emergency_btn.pressed.connect(_on_emergency_pressed)
	
	# Scanner control buttons
	scanner_power_btn.pressed.connect(_on_scanner_power_pressed)
	scanner_scan_btn.pressed.connect(_on_scanner_scan_pressed)
	scanner_right_btn.pressed.connect(_on_scanner_right_pressed)
	scanner_center_btn.pressed.connect(_on_scanner_center_pressed)
	
	# Initialize RGB value labels
	_update_rgb_labels()
	
	# Initialize scanner position
	_update_scanner_display()
	
	# Mouse interaction for bed image (collision detection)
	bed_image.mouse_entered.connect(_on_bed_mouse_entered)
	bed_image.mouse_exited.connect(_on_bed_mouse_exited)
	bed_image.gui_input.connect(_on_bed_clicked)
	
	# Mouse interaction for scanner (collision detection with auto power-on)
	scanner.mouse_entered.connect(_on_scanner_mouse_entered)
	scanner.mouse_exited.connect(_on_scanner_mouse_exited)
	
	print("🎛️ All surgical bed menu controls connected")
	print("🖱️ Mouse collision detection enabled for surgical bed")
	print("🔬 Mouse collision detection enabled for scanner (auto power-on)")

func update_display():
	# Update visual display based on current settings
	# Update bed image color based on temperature (unless hovering)
	if is_bed_hovered:
		bed_image.modulate = hover_color  # Keep yellow if mouse is hovering
	else:
		bed_image.modulate = temperature_colors[current_temperature]
	
	# Update status label
	var status_text = "Height: %s | Temp: %s | Light: %s" % [
		BedHeight.keys()[current_bed_height],
		Temperature.keys()[current_temperature],
		LightingMode.keys()[current_lighting_mode]
	]
	
	if current_lighting_mode == LightingMode.MANUAL:
		status_text += " (%d%%)" % int(manual_brightness)
	
	# Add hover status if applicable
	if is_bed_hovered:
		status_text += " | HOVER DETECTED"
	
	status_label.text = status_text
	
	# Update button states (visual feedback)
	_update_button_states()

func update_status(message: String):
	# Update status with a temporary message
	print("📊 Status: " + message)
	# You can extend this to show temporary messages in the UI if desired

func _update_button_states():
	# Update button visual states to show current selection
	# Reset all height buttons
	height_low_btn.disabled = false
	height_medium_btn.disabled = false
	height_high_btn.disabled = false
	
	# Disable current selection
	match current_bed_height:
		BedHeight.LOW:
			height_low_btn.disabled = true
		BedHeight.MEDIUM:
			height_medium_btn.disabled = true
		BedHeight.HIGH:
			height_high_btn.disabled = true
	
	# Reset temperature buttons
	temp_cool_btn.disabled = false
	temp_normal_btn.disabled = false
	temp_warm_btn.disabled = false
	
	# Disable current temperature selection
	match current_temperature:
		Temperature.COOL:
			temp_cool_btn.disabled = true
		Temperature.NORMAL:
			temp_normal_btn.disabled = true
		Temperature.WARM:
			temp_warm_btn.disabled = true
	
	# Reset lighting buttons
	light_auto_btn.disabled = false
	light_manual_btn.disabled = false
	
	# Disable current lighting selection and update controls
	match current_lighting_mode:
		LightingMode.AUTO:
			light_auto_btn.disabled = true
			brightness_slider.editable = false
			# Disable RGB controls in AUTO mode
			red_slider.editable = false
			green_slider.editable = false
			blue_slider.editable = false
		LightingMode.MANUAL:
			light_manual_btn.disabled = true
			brightness_slider.editable = true
			# Enable RGB controls in MANUAL mode
			red_slider.editable = true
			green_slider.editable = true
			blue_slider.editable = true
	
	# Update light bar color
	_update_light_bar_color()

# Height control functions
func _on_height_low_pressed():
	set_bed_height(BedHeight.LOW)

func _on_height_medium_pressed():
	set_bed_height(BedHeight.MEDIUM)

func _on_height_high_pressed():
	set_bed_height(BedHeight.HIGH)

func set_bed_height(height: BedHeight):
	# Set bed height and emit signal - integrates with C++ extension
	if current_bed_height == height:
		return
		
	current_bed_height = height
	
	# Map enum to actual height values for C++ extension
	var height_values = {
		BedHeight.LOW: 70.0,      # Surgical minimum  
		BedHeight.MEDIUM: 85.0,   # Optimal surgical height
		BedHeight.HIGH: 110.0     # Maximum access height
	}
	
	var target_height = height_values[height]
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		cpp_surgical_bed.set_height(target_height)
		var actual_height = cpp_surgical_bed.get_height()
		print("🔧 C++ Bed height set to: ", actual_height, " cm (", BedHeight.keys()[height], ")")
	else:
		print("🎭 Simulated bed height set to: ", target_height, " cm (", BedHeight.keys()[height], ")")
	
	bed_height_changed.emit(height)
	update_display()

# Temperature control functions
func _on_temperature_cool_pressed():
	set_bed_temperature(Temperature.COOL)

func _on_temperature_normal_pressed():
	set_bed_temperature(Temperature.NORMAL)

func _on_temperature_warm_pressed():
	set_bed_temperature(Temperature.WARM)

func set_bed_temperature(temperature: Temperature):
	# Set bed temperature and emit signal - integrates with C++ extension
	if current_temperature == temperature:
		return
		
	current_temperature = temperature
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		# Map to C++ temperature modes (from TemperatureControl::Mode)
		match temperature:
			Temperature.COOL:
				# In C++ this would be TemperatureControl::Mode::COLD
				# For now we'll use the temperature value method
				cpp_surgical_bed.set_temperature(0)  # COLD mode
				print("🌡️ C++ Temperature set to COOL (18°C) - Sterile environment")
			Temperature.NORMAL:
				cpp_surgical_bed.set_temperature(1)  # NEUTRAL mode  
				print("🌡️ C++ Temperature set to NORMAL (22°C)")
			Temperature.WARM:
				cpp_surgical_bed.set_temperature(2)  # WARM mode
				print("🌡️ C++ Temperature set to WARM (26°C)")
		
		# Get actual temperature value from C++
		var actual_temp = cpp_surgical_bed.get_temperature_value()
		print("🌡️ C++ Actual temperature: ", actual_temp, "°C")
	else:
		print("🎭 Simulated temperature set to: ", Temperature.keys()[temperature])
	
	bed_temperature_changed.emit(temperature)
	update_display()

# Lighting control functions
func _on_lighting_auto_pressed():
	set_lighting_mode(LightingMode.AUTO)

func _on_lighting_manual_pressed():
	set_lighting_mode(LightingMode.MANUAL)

func set_lighting_mode(mode: LightingMode):
	# Set lighting mode and emit signal - integrates with C++ extension
	if current_lighting_mode == mode:
		return
		
	current_lighting_mode = mode
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		match mode:
			LightingMode.AUTO:
				cpp_surgical_bed.activate_lights()
				cpp_surgical_bed.set_light_brightness(0.9)  # Bright for surgical procedures
				print("💡 C++ Lighting mode set to AUTO (90% brightness for surgery)")
			LightingMode.MANUAL:
				cpp_surgical_bed.activate_lights()
				var brightness = manual_brightness / 100.0
				cpp_surgical_bed.set_light_brightness(brightness)
				print("💡 C++ Lighting mode set to MANUAL (", int(manual_brightness), "% brightness)")
	else:
		print("🎭 Simulated lighting mode set to: ", LightingMode.keys()[mode])
	
	# Update C++ Strategy pattern if available
	if cpp_light_strip:
		match mode:
			LightingMode.AUTO:
				cpp_light_strip.set_behavior("auto")
				print("🔄 C++ Strategy: Switched to Auto lighting behavior")
			LightingMode.MANUAL:
				cpp_light_strip.set_behavior("manual")
				print("🎛️ C++ Strategy: Switched to Manual lighting behavior")
	
	# Update light bar with appropriate color/brightness
	if mode == LightingMode.AUTO:
		# Auto mode: use standard white light at high brightness
		light_bar.modulate = Color(0.9, 0.9, 0.9, 1.0)
	else:
		# Manual mode: use current RGB settings
		_update_light_bar_color()
	
	lighting_mode_changed.emit(mode)
	update_display()

func _on_brightness_changed(value: float):
	# Handle brightness slider changes - integrates with C++ extension
	if current_lighting_mode == LightingMode.MANUAL:
		manual_brightness = value
		
		# Update C++ extension if available
		if cpp_surgical_bed:
			var brightness = value / 100.0
			cpp_surgical_bed.set_light_brightness(brightness)
			print("🔆 C++ Manual brightness: ", int(value), "%")
		else:
			print("🎭 Simulated manual brightness: ", int(value), "%")
		
		brightness_changed.emit(value)
		_update_light_bar_color()

# RGB Color control functions
func _on_red_changed(value: float):
	# Handle red color intensity changes
	rgb_values["red"] = value
	red_value_label.text = str(int(value)) + "%"
	rgb_color_changed.emit("red", value)
	_update_light_bar_color()
	
	# Update C++ extension if available
	if cpp_surgical_bed and current_lighting_mode == LightingMode.MANUAL:
		var color = Color(value/100.0, rgb_values["green"]/100.0, rgb_values["blue"]/100.0)
		print("🔴 C++ Red intensity: ", int(value), "%")

func _on_green_changed(value: float):
	# Handle green color intensity changes
	rgb_values["green"] = value
	green_value_label.text = str(int(value)) + "%"
	rgb_color_changed.emit("green", value)
	_update_light_bar_color()
	
	# Update C++ extension if available
	if cpp_surgical_bed and current_lighting_mode == LightingMode.MANUAL:
		var color = Color(rgb_values["red"]/100.0, value/100.0, rgb_values["blue"]/100.0)
		print("🟢 C++ Green intensity: ", int(value), "%")

func _on_blue_changed(value: float):
	# Handle blue color intensity changes
	rgb_values["blue"] = value
	blue_value_label.text = str(int(value)) + "%"
	rgb_color_changed.emit("blue", value)
	_update_light_bar_color()
	
	# Update C++ extension if available
	if cpp_surgical_bed and current_lighting_mode == LightingMode.MANUAL:
		var color = Color(rgb_values["red"]/100.0, rgb_values["green"]/100.0, value/100.0)
		print("🔵 C++ Blue intensity: ", int(value), "%")

# Emergency mode functions
func _on_emergency_pressed():
	# Toggle emergency mode with blinking light bar
	if current_emergency_state == EmergencyState.NORMAL:
		start_emergency_mode()
	else:
		stop_emergency_mode()

func start_emergency_mode():
	# Start emergency mode with blinking light bar using C++ Strategy pattern
	current_emergency_state = EmergencyState.EMERGENCY
	emergency_btn.text = "STOP EMERGENCY"
	emergency_btn.modulate = Color(1.0, 0.5, 0.5)  # Red tint
	
	# Start blinking
	is_blinking = true
	emergency_blink_timer.start()
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		print("🚨 C++ Emergency mode ACTIVATED")
	else:
		print("🎭 Simulated Emergency mode ACTIVATED")
	
	# Switch C++ Light Strip to Emergency behavior
	if cpp_light_strip:
		cpp_light_strip.set_behavior("emergency")
		print("💡 C++ Strategy: Switched to Emergency lighting behavior")
		print("🔆 Emergency mode: ", cpp_light_strip.get_current_mode())
		
		# Set initial emergency color using C++ brightness
		_set_emergency_light_color()
	else:
		print("⚠️ C++ Light Strip not available - using manual emergency mode")
		# Set emergency colors manually (bright red)
		_set_emergency_light_color()
		# Set emergency colors manually (bright red)
		_set_emergency_light_color()
	
	emergency_mode_changed.emit(true)

func stop_emergency_mode():
	# Stop emergency mode and return to normal lighting
	current_emergency_state = EmergencyState.NORMAL
	emergency_btn.text = "EMERGENCY MODE"
	emergency_btn.modulate = Color(1.0, 1.0, 1.0)  # Normal color
	
	# Stop blinking
	is_blinking = false
	emergency_blink_timer.stop()
	
	# Return to normal colors
	_update_light_bar_color()
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		print("✅ C++ Emergency mode DEACTIVATED")
	else:
		print("🎭 Simulated Emergency mode DEACTIVATED")
	
	# Switch C++ Light Strip back to normal behavior
	if cpp_light_strip:
		if current_lighting_mode == LightingMode.AUTO:
			cpp_light_strip.set_behavior("auto")
			print("💡 C++ Strategy: Returned to auto lighting behavior")
		else:
			cpp_light_strip.set_behavior("manual")
			print("💡 C++ Strategy: Returned to manual lighting behavior")
	
	emergency_mode_changed.emit(false)

func setup_emergency_timer():
	# Setup the emergency blinking timer
	if emergency_blink_timer:
		emergency_blink_timer.queue_free()
	
	emergency_blink_timer = Timer.new()
	emergency_blink_timer.wait_time = 0.5  # Blink every 500ms
	emergency_blink_timer.timeout.connect(_on_emergency_blink)
	emergency_blink_timer.autostart = false
	emergency_blink_timer.one_shot = false
	add_child(emergency_blink_timer)

func _on_emergency_blink():
	# Handle emergency blinking animation using C++ Strategy pattern
	if not is_blinking:
		return
		
	# Safety check for light_bar node
	if not light_bar:
		print("⚠️ Light bar node not found - cannot blink")
		return
	
	if cpp_light_strip:
		# Use C++ Strategy pattern for emergency blinking
		var current_brightness_raw = cpp_light_strip.get_brightness()
		var current_mode = cpp_light_strip.get_current_mode()
		
		# Ensure current_brightness is a float (convert from String if needed)
		var current_brightness = float(current_brightness_raw)
		
		# The C++ emergency behavior handles the blinking logic
		# We just need to sync the SVG visual with the C++ state
		if current_brightness > 0.5:
			# C++ is in bright phase, make SVG bright red
			light_bar.modulate = Color(1.0, 0.2, 0.2, current_brightness)
		else:
			# C++ is in dim phase, make SVG dim red  
			light_bar.modulate = Color(0.3, 0.0, 0.0, current_brightness)
		
		print("💡 Emergency blink - Mode: ", current_mode, " Brightness: ", current_brightness)
	else:
		# Fallback to manual blinking if C++ not available
		if light_bar.modulate.r > 0.5:
			light_bar.modulate = Color(0.3, 0.0, 0.0, 1.0)  # Dim red
		else:
			_set_emergency_light_color()  # Bright red

func _set_emergency_light_color():
	# Set light bar to emergency red color, coordinated with C++ Strategy
	if not light_bar:
		print("⚠️ Light bar node not found - cannot set emergency color")
		return
		
	if cpp_light_strip:
		# Get brightness from C++ Strategy pattern
		var cpp_brightness_raw = cpp_light_strip.get_brightness()
		var cpp_brightness = float(cpp_brightness_raw)
		light_bar.modulate = Color(1.0, 0.2, 0.2, cpp_brightness)
		print("🚨 Emergency color set - C++ brightness: ", cpp_brightness)
	else:
		# Fallback without C++ extension
		light_bar.modulate = Color(1.0, 0.2, 0.2, 1.0)  # Bright emergency red

func _update_light_bar_color():
	# Update light bar color based on current RGB values and emergency state
	if current_emergency_state == EmergencyState.EMERGENCY:
		return  # Don't update color during emergency mode
	
	# Use C++ Strategy pattern for light mode calculation if available
	if cpp_light_strip:
		# Get current mode from C++ Strategy pattern
		var cpp_mode = cpp_light_strip.get_current_mode()
		var cpp_brightness_raw = cpp_light_strip.get_brightness()
		
		# Ensure cpp_brightness is a float (convert from String if needed)
		var cpp_brightness = float(cpp_brightness_raw)
		
		# Apply C++ Strategy pattern brightness to our calculations
		var strategy_brightness = manual_brightness / 100.0 * cpp_brightness
		print("💡 C++ Strategy Mode: ", cpp_mode, " Brightness: ", cpp_brightness)
		
		# Calculate color from RGB sliders with C++ Strategy influence
		var red = rgb_values["red"] / 100.0
		var green = rgb_values["green"] / 100.0
		var blue = rgb_values["blue"] / 100.0
		
		# Apply strategy-based brightness to RGB values
		var final_color = Color(red * strategy_brightness, green * strategy_brightness, blue * strategy_brightness, 1.0)
		light_bar.modulate = final_color
	else:
		# Fallback to original behavior without C++ Strategy
		var red = rgb_values["red"] / 100.0
		var green = rgb_values["green"] / 100.0
		var blue = rgb_values["blue"] / 100.0
		var brightness = manual_brightness / 100.0
		
		# Apply brightness to RGB values
		var final_color = Color(red * brightness, green * brightness, blue * brightness, 1.0)
		light_bar.modulate = final_color

func _update_rgb_labels():
	# Update RGB value labels
	red_value_label.text = str(int(rgb_values["red"])) + "%"
	green_value_label.text = str(int(rgb_values["green"])) + "%"
	blue_value_label.text = str(int(rgb_values["blue"])) + "%"

# Scanner Control Functions
func _on_scanner_power_pressed():
	# Toggle scanner power on/off
	if current_scanner_state == ScannerState.OFF:
		turn_scanner_on()
	else:
		turn_scanner_off()

# Alias function for compatibility (in case editor is looking for this name)
func _toggle_scanner_power():
	# Alias for _on_scanner_power_pressed() - toggles scanner power
	_on_scanner_power_pressed()

func turn_scanner_on():
	# Turn scanner on and enable controls
	current_scanner_state = ScannerState.ON
	scanner_power_btn.text = "POWER OFF"
	scanner_scan_btn.disabled = false
	scanner_right_btn.disabled = false
	scanner_center_btn.disabled = false
	
	# Visual feedback - make scanner more visible
	scanner.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full opacity
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		print("🔬 C++ Scanner powered ON")
	else:
		print("🎭 Simulated Scanner powered ON")
	
	scanner_state_changed.emit(current_scanner_state)
	_update_scanner_status()

func turn_scanner_off():
	# Turn scanner off and disable controls
	if is_scanning:
		_stop_scanning()  # Stop any ongoing scan
	
	current_scanner_state = ScannerState.OFF
	scanner_power_btn.text = "POWER ON"
	scanner_scan_btn.disabled = true
	scanner_right_btn.disabled = true
	scanner_center_btn.disabled = true
	
	# Return to center position when turning off
	if current_scanner_position != ScannerPosition.CENTER:
		_move_scanner_to_center()
	
	# Visual feedback - dim scanner
	scanner.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Dimmed
	
	# Update C++ extension if available
	if cpp_surgical_bed:
		print("🔬 C++ Scanner powered OFF")
	else:
		print("🎭 Simulated Scanner powered OFF")
	
	scanner_state_changed.emit(current_scanner_state)
	_update_scanner_status()

func _on_scanner_scan_pressed():
	# Start or stop scanning operation
	if not is_scanning:
		start_scan()
	else:
		stop_scan()

func start_scan():
	# Start scanning operation with right movement
	if current_scanner_state != ScannerState.ON:
		print("❌ Scanner must be powered on to scan")
		return
	
	is_scanning = true
	current_scanner_state = ScannerState.SCANNING
	scanner_scan_btn.text = "STOP SCAN"
	
	# Disable position buttons during scan
	scanner_right_btn.disabled = true
	scanner_center_btn.disabled = true
	
	print("🔍 Starting scan sequence...")
	
	# Start scan sequence: move to right, then back to center
	_perform_scan_sequence()
	
	scanner_state_changed.emit(current_scanner_state)
	_update_scanner_status()

func stop_scan():
	# Stop scanning operation
	_stop_scanning()

func _stop_scanning():
	# Internal function to stop scanning
	is_scanning = false
	current_scanner_state = ScannerState.ON
	scanner_scan_btn.text = "START SCAN"
	
	# Re-enable position buttons
	scanner_right_btn.disabled = false
	scanner_center_btn.disabled = false
	
	# Stop any ongoing tweens
	if scanner_move_tween:
		scanner_move_tween.kill()
	
	print("🔍 Scan stopped")
	
	scanner_state_changed.emit(current_scanner_state)
	_update_scanner_status()

func _perform_scan_sequence():
	# Perform the scanning sequence: right -> center
	print("🔍 Scan sequence: Moving to right position...")
	
	# Move to right first
	_move_scanner_to_right()
	
	# Wait 2 seconds, then move back to center
	await get_tree().create_timer(2.0).timeout
	
	if is_scanning:  # Check if scan wasn't cancelled
		print("🔍 Scan sequence: Returning to center...")
		_move_scanner_to_center()
		
		# Wait for movement to complete, then finish scan
		await get_tree().create_timer(1.5).timeout
		
		if is_scanning:  # Check again if scan wasn't cancelled
			_complete_scan()

func _complete_scan():
	# Complete the scanning operation
	print("✅ Scan completed successfully!")
	
	# Generate scan data
	var scan_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"patient_height": current_bed_height,
		"scan_quality": "HIGH",
		"anomalies_detected": false,
		"scan_duration": 3.5
	}
	
	scan_completed.emit(scan_data)
	
	# Stop scanning
	_stop_scanning()

func _on_scanner_right_pressed():
	# Move scanner to right position
	_move_scanner_to_right()

func _on_scanner_center_pressed():
	# Move scanner to center position
	_move_scanner_to_center()

func _move_scanner_to_right():
	# Move scanner to right position with animation and boundary checking
	if current_scanner_position == ScannerPosition.RIGHT:
		return
	
	print("🔄 Moving scanner to RIGHT position")
	current_scanner_position = ScannerPosition.RIGHT
	
	# Kill existing tween to prevent conflicts
	if scanner_move_tween:
		scanner_move_tween.kill()
	
	# Store original position if not already stored
	if not scanner.has_meta("original_position"):
		scanner.set_meta("original_position", scanner.position)
	
	# Calculate container bounds to ensure scanner stays within bounds
	var container = scanner.get_parent()  # BedDisplay container
	var scanner_size = scanner.size
	var container_size = container.size
	var original_pos = scanner.get_meta("original_position")
	
	# Calculate target position (move to right side of container with margin)
	var margin = 20.0  # 20px margin from edge
	var available_space = container_size.x - scanner_size.x
	var target_x = max(original_pos.x, available_space - margin)  # Ensure we don't go past the container
	var target_position = Vector2(target_x, original_pos.y)
	
	# Create smooth movement animation to right position
	scanner_move_tween = create_tween()
	scanner_move_tween.tween_property(scanner, "position", target_position, 1.5)
	scanner_move_tween.tween_callback(_on_scanner_movement_complete)
	
	scanner_position_changed.emit(current_scanner_position)
	_update_scanner_status()

func _move_scanner_to_center():
	# Move scanner to center position with animation
	if current_scanner_position == ScannerPosition.CENTER:
		return
	
	print("🔄 Moving scanner to CENTER position")
	current_scanner_position = ScannerPosition.CENTER
	
	# Kill existing tween to prevent conflicts
	if scanner_move_tween:
		scanner_move_tween.kill()
	
	# Get original position
	var original_position = Vector2.ZERO
	if scanner.has_meta("original_position"):
		original_position = scanner.get_meta("original_position")
	
	# Create smooth movement animation back to original position
	scanner_move_tween = create_tween()
	scanner_move_tween.tween_property(scanner, "position", original_position, 1.5)
	scanner_move_tween.tween_callback(_on_scanner_movement_complete)
	
	scanner_position_changed.emit(current_scanner_position)
	_update_scanner_status()

func _on_scanner_movement_complete():
	# Called when scanner movement animation completes
	print("✅ Scanner movement complete")

func _update_scanner_status():
	# Update scanner status label
	var state_text = ScannerState.keys()[current_scanner_state]
	var position_text = ScannerPosition.keys()[current_scanner_position]
	scanner_status_label.text = "Status: %s | Position: %s" % [state_text, position_text]

func _update_scanner_display():
	# Update scanner visual display based on current state and hover state
	if is_scanner_hovered:
		scanner.modulate = hover_color  # Yellow when hovered
	elif current_scanner_state == ScannerState.OFF:
		scanner.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Dimmed when off
	else:
		scanner.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full visibility when on
	
	_update_scanner_status()

# Public interface functions
func get_current_height() -> BedHeight:
	return current_bed_height

func get_current_temperature() -> Temperature:
	return current_temperature

func get_current_lighting_mode() -> LightingMode:
	return current_lighting_mode

func get_manual_brightness() -> float:
	return manual_brightness

func get_current_emergency_state() -> EmergencyState:
	return current_emergency_state

func get_rgb_values() -> Dictionary:
	return rgb_values.duplicate()

func is_emergency_blinking() -> bool:
	return is_blinking

func get_current_scanner_state() -> ScannerState:
	return current_scanner_state

func get_current_scanner_position() -> ScannerPosition:
	return current_scanner_position

func is_scanner_scanning() -> bool:
	return is_scanning

func get_status_info() -> Dictionary:
	# Get complete status information for testing/debugging - includes C++ extension data
	var status = {
		"height": BedHeight.keys()[current_bed_height],
		"temperature": Temperature.keys()[current_temperature],
		"lighting_mode": LightingMode.keys()[current_lighting_mode],
		"emergency_state": EmergencyState.keys()[current_emergency_state],
		"scanner_state": ScannerState.keys()[current_scanner_state],
		"scanner_position": ScannerPosition.keys()[current_scanner_position],
		"manual_brightness": manual_brightness,
		"rgb_values": rgb_values.duplicate(),
		"is_blinking": is_blinking,
		"is_scanning": is_scanning,
		"temperature_color": temperature_colors[current_temperature],
		"cpp_extension_available": cpp_surgical_bed != null
	}
	
	# Add C++ extension specific data if available
	if cpp_surgical_bed:
		status["cpp_height"] = cpp_surgical_bed.get_height()
		status["cpp_temperature"] = cpp_surgical_bed.get_temperature_value()
		status["cpp_sterile_mode"] = true  # We activate sterile mode on startup
	
	return status

# Additional surgical-specific functions that use C++ extension
func start_surgical_procedure(procedure_name: String):
	# Start a surgical procedure using C++ extension
	if cpp_surgical_bed:
		print("🏥 Starting surgical procedure: ", procedure_name)
		# Set optimal surgical configuration
		cpp_surgical_bed.enter_sterile_mode()
		cpp_surgical_bed.set_height(85.0)  # Optimal surgical height
		cpp_surgical_bed.activate_lights()
		cpp_surgical_bed.set_light_brightness(0.95)  # Maximum brightness for surgery
		print("✅ Surgical environment configured via C++ extension")
	else:
		print("🎭 Simulated surgical procedure start: ", procedure_name)

func perform_maintenance_check():
	# Perform maintenance check using C++ extension
	if cpp_surgical_bed:
		print("🔧 Performing C++ surgical bed maintenance check...")
		cpp_surgical_bed.perform_maintenance_check()
		print("✅ C++ Maintenance check complete")
	else:
		print("🎭 Simulated maintenance check complete")

func trigger_emergency_mode():
	# Trigger emergency mode using C++ extension
	if cpp_surgical_bed:
		print("🚨 Activating C++ emergency mode...")
		cpp_surgical_bed.trigger_emergency()
		print("🚨 C++ Emergency mode activated")
	else:
		print("🎭 Simulated emergency mode activated")

func clear_emergency_mode():
	# Clear emergency mode using C++ extension
	if cpp_surgical_bed:
		print("✅ Clearing C++ emergency mode...")
		cpp_surgical_bed.clear_emergency()
		print("✅ C++ Emergency mode cleared")
	else:
		print("🎭 Simulated emergency mode cleared")

# Mouse collision detection functions
func _on_bed_mouse_entered():
	# Called when mouse enters the surgical bed area (collision detected)
	is_bed_hovered = true
	bed_image.modulate = hover_color  # Turn bed yellow
	print("🖱️ Mouse collision detected - Surgical bed highlighted")
	update_status("Mouse hover detected on surgical bed")

func _on_bed_mouse_exited():
	# Called when mouse exits the surgical bed area (collision ended)
	is_bed_hovered = false
	# Restore original color based on current temperature
	var original_color = temperature_colors.get(current_temperature, normal_color)
	bed_image.modulate = original_color
	print("🖱️ Mouse collision ended - Surgical bed color restored")
	update_status("Mouse hover ended")

func _on_bed_clicked(event: InputEvent):
	# Called when surgical bed is clicked (enhanced collision interaction)
	if event is InputEventMouseButton and event.pressed:
		print("🖱️ Surgical bed clicked! Button: " + str(event.button_index))
		update_status("Surgical bed clicked - Interaction detected")
		
		# Optional: Add click visual feedback (brief flash)
		var tween = create_tween()
		tween.tween_property(bed_image, "modulate", Color.WHITE, 0.1)
		tween.tween_property(bed_image, "modulate", hover_color if is_bed_hovered else temperature_colors[current_temperature], 0.1)

# Scanner mouse collision detection functions
func _on_scanner_mouse_entered():
	# Called when mouse enters the scanner area (collision detected) - Auto power on
	is_scanner_hovered = true
	scanner.modulate = hover_color  # Turn scanner yellow
	print("🔬 Mouse collision detected - Scanner highlighted and auto-powered ON")
	
	# Automatically turn scanner power ON when mouse hovers
	if current_scanner_state == ScannerState.OFF:
		_on_scanner_power_pressed()  # Turn on the scanner
	
	update_status("Scanner hover detected - Auto power ON activated")

func _on_scanner_mouse_exited():
	# Called when mouse exits the scanner area (collision ended)
	is_scanner_hovered = false
	# Restore scanner visual state based on current power state
	_update_scanner_display()
	print("🔬 Mouse collision ended - Scanner color restored")
	update_status("Scanner hover ended")
