# Simple Test Runner for Surgical Bed Menu
# Tests basic functionality without external testing framework

extends SceneTree

const SurgicalBedMenuScene = preload("res://scenes/beds/surgical_bed_menu.tscn")

var test_results = []
var tests_passed = 0
var tests_failed = 0

func _init():
	print("🧪 Starting Surgical Bed Menu Tests...")
	run_all_tests()
	print_results()
	quit()

func run_all_tests():
	"""Run all test functions"""
	test_scene_initialization()
	test_height_controls()
	test_temperature_controls() 
	test_lighting_controls()
	test_status_functionality()

func test_scene_initialization():
	"""Test basic scene initialization"""
	print("Testing scene initialization...")
	
	var surgical_bed_menu = SurgicalBedMenuScene.instantiate()
	current_scene = surgical_bed_menu
	
	# Give time for _ready to be called
	await process_frame
	
	# Test default values
	assert_equal("Scene initialization", surgical_bed_menu.get_current_height(), 
		surgical_bed_menu.BedHeight.MEDIUM, "Default height should be MEDIUM")
	assert_equal("Scene initialization", surgical_bed_menu.get_current_temperature(), 
		surgical_bed_menu.Temperature.NORMAL, "Default temperature should be NORMAL")
	assert_equal("Scene initialization", surgical_bed_menu.get_current_lighting_mode(), 
		surgical_bed_menu.LightingMode.AUTO, "Default lighting should be AUTO")
	
	surgical_bed_menu.queue_free()

func test_height_controls():
	"""Test bed height control functionality"""
	print("Testing height controls...")
	
	var surgical_bed_menu = SurgicalBedMenuScene.instantiate()
	current_scene = surgical_bed_menu
	await process_frame
	
	# Test signal emission for height changes
	var signal_received = false
	var received_height = null
	
	surgical_bed_menu.bed_height_changed.connect(func(height):
		signal_received = true
		received_height = height
	)
	
	# Test LOW height
	surgical_bed_menu.set_bed_height(surgical_bed_menu.BedHeight.LOW)
	await process_frame
	
	assert_equal("Height control", surgical_bed_menu.get_current_height(), 
		surgical_bed_menu.BedHeight.LOW, "Height should be set to LOW")
	assert_true("Height signal", signal_received, "Height change signal should be emitted")
	assert_equal("Height signal value", received_height, 
		surgical_bed_menu.BedHeight.LOW, "Signal should contain LOW height")
	
	# Test HIGH height
	signal_received = false
	surgical_bed_menu.set_bed_height(surgical_bed_menu.BedHeight.HIGH)
	await process_frame
	
	assert_equal("Height control", surgical_bed_menu.get_current_height(), 
		surgical_bed_menu.BedHeight.HIGH, "Height should be set to HIGH")
	assert_true("Height signal", signal_received, "Height change signal should be emitted for HIGH")
	
	surgical_bed_menu.queue_free()

func test_temperature_controls():
	"""Test bed temperature control functionality"""
	print("Testing temperature controls...")
	
	var surgical_bed_menu = SurgicalBedMenuScene.instantiate()
	current_scene = surgical_bed_menu
	await process_frame
	
	# Test signal emission for temperature changes
	var signal_received = false
	var received_temp = null
	
	surgical_bed_menu.bed_temperature_changed.connect(func(temp):
		signal_received = true
		received_temp = temp
	)
	
	# Test COOL temperature
	surgical_bed_menu.set_bed_temperature(surgical_bed_menu.Temperature.COOL)
	await process_frame
	
	assert_equal("Temperature control", surgical_bed_menu.get_current_temperature(), 
		surgical_bed_menu.Temperature.COOL, "Temperature should be set to COOL")
	assert_true("Temperature signal", signal_received, "Temperature change signal should be emitted")
	assert_equal("Temperature signal value", received_temp, 
		surgical_bed_menu.Temperature.COOL, "Signal should contain COOL temperature")
	
	# Test WARM temperature
	signal_received = false
	surgical_bed_menu.set_bed_temperature(surgical_bed_menu.Temperature.WARM)
	await process_frame
	
	assert_equal("Temperature control", surgical_bed_menu.get_current_temperature(), 
		surgical_bed_menu.Temperature.WARM, "Temperature should be set to WARM")
	assert_true("Temperature signal", signal_received, "Temperature change signal should be emitted for WARM")
	
	surgical_bed_menu.queue_free()

func test_lighting_controls():
	"""Test lighting control functionality"""
	print("Testing lighting controls...")
	
	var surgical_bed_menu = SurgicalBedMenuScene.instantiate()
	current_scene = surgical_bed_menu
	await process_frame
	
	# Test signal emission for lighting changes
	var signal_received = false
	var received_mode = null
	
	surgical_bed_menu.lighting_mode_changed.connect(func(mode):
		signal_received = true
		received_mode = mode
	)
	
	# Test MANUAL lighting
	surgical_bed_menu.set_lighting_mode(surgical_bed_menu.LightingMode.MANUAL)
	await process_frame
	
	assert_equal("Lighting control", surgical_bed_menu.get_current_lighting_mode(), 
		surgical_bed_menu.LightingMode.MANUAL, "Lighting should be set to MANUAL")
	assert_true("Lighting signal", signal_received, "Lighting change signal should be emitted")
	assert_equal("Lighting signal value", received_mode, 
		surgical_bed_menu.LightingMode.MANUAL, "Signal should contain MANUAL mode")
	
	# Test AUTO lighting
	signal_received = false
	surgical_bed_menu.set_lighting_mode(surgical_bed_menu.LightingMode.AUTO)
	await process_frame
	
	assert_equal("Lighting control", surgical_bed_menu.get_current_lighting_mode(), 
		surgical_bed_menu.LightingMode.AUTO, "Lighting should be set to AUTO")
	assert_true("Lighting signal", signal_received, "Lighting change signal should be emitted for AUTO")
	
	surgical_bed_menu.queue_free()

func test_status_functionality():
	"""Test status reporting functionality"""
	print("Testing status functionality...")
	
	var surgical_bed_menu = SurgicalBedMenuScene.instantiate()
	current_scene = surgical_bed_menu
	await process_frame
	
	# Set some values
	surgical_bed_menu.set_bed_height(surgical_bed_menu.BedHeight.HIGH)
	surgical_bed_menu.set_bed_temperature(surgical_bed_menu.Temperature.WARM)
	surgical_bed_menu.set_lighting_mode(surgical_bed_menu.LightingMode.MANUAL)
	await process_frame
	
	# Get status info
	var status = surgical_bed_menu.get_status_info()
	
	assert_true("Status info exists", status != null, "Status info should be available")
	assert_true("Status has height", status.has("height"), "Status should include height")
	assert_true("Status has temperature", status.has("temperature"), "Status should include temperature")
	assert_true("Status has lighting_mode", status.has("lighting_mode"), "Status should include lighting_mode")
	
	assert_equal("Status height", status["height"], "HIGH", "Status should show HIGH height")
	assert_equal("Status temperature", status["temperature"], "WARM", "Status should show WARM temperature")
	assert_equal("Status lighting", status["lighting_mode"], "MANUAL", "Status should show MANUAL lighting")
	
	surgical_bed_menu.queue_free()

func assert_equal(test_name: String, actual, expected, message: String):
	"""Simple assertion for equality"""
	var passed = (actual == expected)
	record_test(test_name, passed, message + " (Expected: " + str(expected) + ", Got: " + str(actual) + ")")

func assert_true(test_name: String, condition: bool, message: String):
	"""Simple assertion for true condition"""
	record_test(test_name, condition, message)

func record_test(test_name: String, passed: bool, message: String):
	"""Record test result"""
	if passed:
		tests_passed += 1
		print("  ✅ " + test_name + ": " + message)
	else:
		tests_failed += 1
		print("  ❌ " + test_name + ": " + message)
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"message": message
	})

func print_results():
	"""Print final test results"""
	var separator = "============================================================"
	print("\n" + separator)
	print("🧪 Surgical Bed Menu Test Results")
	print(separator)
	print("Tests Passed: " + str(tests_passed))
	print("Tests Failed: " + str(tests_failed))
	print("Total Tests: " + str(tests_passed + tests_failed))
	
	if tests_failed == 0:
		print("🎉 ALL TESTS PASSED! Surgical bed menu is working correctly.")
	else:
		print("⚠️ " + str(tests_failed) + " test(s) failed. Check the output above for details.")
	
	print(separator)