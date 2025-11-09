#!/usr/bin/env gdscript
extends SceneTree

# Simple, robust test runner that works in headless mode
# Focuses on testing C++ integration without UI dependencies

const SurgicalBedMenuScene = preload("res://scenes/beds/surgical_bed_menu.gd")

var test_results = []
var tests_passed = 0
var tests_failed = 0

func _init():
	print("🧪 Starting Medical Equipment C++ Integration Tests...")
	run_all_tests()
	print_test_results()
	quit()

func run_all_tests():
	"""Run all tests that work in headless mode"""
	test_cpp_extension_loading()
	test_bed_factory_creation()
	test_surgical_bed_basic_functionality()
	test_mouse_interaction_setup()
	test_ui_configuration()

func test_cpp_extension_loading():
	"""Test that C++ extensions load properly"""
	print("Testing C++ extension loading...")
	
	var has_bed_factory = ClassDB.class_exists("BedFactory")
	var has_custom_window = ClassDB.class_exists("CustomWindow")
	
	assert_test("C++ Extension Loading", has_bed_factory, "BedFactory class should be available")
	assert_test("C++ Extension Loading", has_custom_window, "CustomWindow class should be available")

func test_bed_factory_creation():
	"""Test BedFactory instantiation and basic operations"""
	print("Testing BedFactory creation...")
	
	if not ClassDB.class_exists("BedFactory"):
		assert_test("BedFactory Creation", false, "BedFactory class not available - skipping test")
		return
	
	var bed_factory = ClassDB.instantiate("BedFactory")
	assert_test("BedFactory Creation", bed_factory != null, "BedFactory should instantiate successfully")
	
	if bed_factory:
		# Test basic factory method
		var surgical_bed = bed_factory.create_surgical_bed()
		assert_test("BedFactory Creation", surgical_bed != null, "Should create surgical bed successfully")
		
		# Cleanup
		if surgical_bed:
			surgical_bed.queue_free()
		bed_factory.queue_free()

func test_surgical_bed_basic_functionality():
	"""Test surgical bed C++ functionality without UI"""
	print("Testing surgical bed functionality...")
	
	# Create through script instantiation (no UI dependencies)
	var script = load("res://scenes/beds/surgical_bed_menu.gd")
	if script:
		# Test enum values are properly defined
		assert_test("Surgical Bed", script.BedHeight.LOW == 0, "BedHeight.LOW should be 0")
		assert_test("Surgical Bed", script.BedHeight.MEDIUM == 1, "BedHeight.MEDIUM should be 1")
		assert_test("Surgical Bed", script.BedHeight.HIGH == 2, "BedHeight.HIGH should be 2")
		
		assert_test("Surgical Bed", script.Temperature.COOL == 0, "Temperature.COOL should be 0")
		assert_test("Surgical Bed", script.Temperature.NORMAL == 1, "Temperature.NORMAL should be 1")
		assert_test("Surgical Bed", script.Temperature.WARM == 2, "Temperature.WARM should be 2")

func test_mouse_interaction_setup():
	"""Test mouse interaction system configuration"""
	print("Testing mouse interaction configuration...")
	
	var scene_resource = load("res://scenes/beds/surgical_bed_menu.tscn")
	assert_test("Mouse Interaction", scene_resource != null, "Scene resource should load successfully")
	
	if scene_resource:
		# Test that the scene has the right structure for mouse interaction
		var instance = scene_resource.instantiate()
		if instance:
			# Check if scanner node exists with mouse filter enabled
			var scanner = instance.get_node_or_null("HBoxContainer/BedDisplay/Scanner")
			if scanner:
				# MOUSE_FILTER_PASS is 0 in Godot
				assert_test("Mouse Interaction", scanner.mouse_filter == 0, 
					"Scanner should have mouse filter enabled (value: " + str(scanner.mouse_filter) + ")")
			else:
				assert_test("Mouse Interaction", false, "Scanner node not found in expected location")
			
			# Check if bed image has mouse filter enabled
			var bed_image = instance.get_node_or_null("HBoxContainer/BedDisplay/BedImage")
			if bed_image:
				# MOUSE_FILTER_PASS is 0 in Godot
				assert_test("Mouse Interaction", bed_image.mouse_filter == 0, 
					"Bed image should have mouse filter enabled (value: " + str(bed_image.mouse_filter) + ")")
			else:
				assert_test("Mouse Interaction", false, "Bed image node not found")
			
			instance.queue_free()

func test_ui_configuration():
	"""Test UI configuration and sizing"""
	print("Testing UI configuration...")
	
	var scene_resource = load("res://scenes/beds/surgical_bed_menu.tscn")
	if scene_resource:
		var instance = scene_resource.instantiate()
		if instance:
			# Test window sizing configuration
			var expected_size = Vector2(1600, 1200)
			assert_test("UI Configuration", instance.custom_minimum_size == expected_size, 
				"Window should have minimum size of 1600x1200")
			
			# Test theme application
			assert_test("UI Configuration", instance.theme != null, "Root container should have theme")
			
			# Test scanner custom sizing
			var scanner = instance.get_node_or_null("HBoxContainer/BedDisplay/Scanner")
			if scanner:
				var expected_scanner_size = Vector2(200, 80)
				assert_test("UI Configuration", scanner.custom_minimum_size == expected_scanner_size,
					"Scanner should have custom size of 200x80")
			
			instance.queue_free()

func assert_test(category: String, condition: bool, message: String):
	"""Assert test result and track statistics"""
	if condition:
		tests_passed += 1
		test_results.append("✅ " + category + ": " + message)
	else:
		tests_failed += 1
		test_results.append("❌ " + category + ": " + message)

func print_test_results():
	"""Print comprehensive test results"""
	print("\n" + "=".repeat(60))
	print("🧪 Medical Equipment C++ Integration Test Results")
	print("=".repeat(60))
	print("Tests Passed: " + str(tests_passed))
	print("Tests Failed: " + str(tests_failed))
	print("Total Tests: " + str(tests_passed + tests_failed))
	
	if tests_failed == 0:
		print("🎉 ALL TESTS PASSED! C++ integration working correctly.")
	else:
		print("⚠️  Some tests failed. Check the details below.")
	
	print("=".repeat(60))
	
	for result in test_results:
		print("  " + result)
	
	print("=".repeat(60))

func process_frame():
	"""Simple frame processing for async operations"""
	await process_frame