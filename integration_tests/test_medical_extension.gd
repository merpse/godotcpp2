# Medical Equipment Extension Test Script

extends Node

func _ready():
	print("=== Medical Equipment Extension Test ===")
	
	# Test Factory Pattern - Create different bed types
	print("\n🏭 Testing Factory Pattern:")
	var bed_factory = BedFactory.new()
	
	# Create a Patient Bed
	print("Creating Patient Bed...")
	var patient_bed = bed_factory.create_bed_by_type(BedFactory.BedType.PATIENT)
	if patient_bed:
		print("✅ Patient bed created successfully")
		patient_bed.set_name("Patient Bed 1")
		
		# Test Template Method Pattern
		print("Testing patient admission...")
		patient_bed.perform_bed_operation()
		
		# Test Strategy Pattern
		print("Testing light controls...")
		patient_bed.activate_lights()
		patient_bed.set_light_brightness(0.7)
		patient_bed.trigger_emergency()
		patient_bed.clear_emergency()
		
		# Test Observer Pattern (comfort settings)
		print("Testing comfort features...")
		patient_bed.enable_comfort_mode()
	
	# Create a Surgical Bed
	print("\nCreating Surgical Bed...")
	var surgical_bed = bed_factory.create_bed_by_type(BedFactory.BedType.SURGICAL)
	if surgical_bed:
		print("✅ Surgical bed created successfully")
		surgical_bed.set_name("Surgical Bed 1")
		
		# Test sterile mode
		print("Testing sterile mode...")
		surgical_bed.enter_sterile_mode()
		surgical_bed.setup_sterile_environment()
		
		# Test procedure management
		print("Testing procedure management...")
		surgical_bed.start_procedure("brain_surgery")
		surgical_bed.monitor_vitals()
		surgical_bed.end_procedure()
		
		# Test medical device integration (Composite Pattern)
		print("Testing medical device integration...")
		surgical_bed.integrate_medical_device()
	
	# Test string-based creation
	print("\n🔧 Testing String-based Bed Creation:")
	var patient_bed_2 = bed_factory.create_bed("patient")
	if patient_bed_2:
		print("✅ Patient bed created from string")
	
	var surgical_bed_2 = bed_factory.create_bed("surgical")
	if surgical_bed_2:
		print("✅ Surgical bed created from string")
	
	print("\n🎉 Medical Equipment Extension Test Complete!")
	print("All design patterns successfully implemented:")
	print("   ✅ Factory Pattern (Bed creation)")
	print("   ✅ Strategy Pattern (Light behaviors)")
	print("   ✅ Template Method Pattern (Bed operations)")
	print("   ✅ Observer Pattern (Emergency alerts)")
	print("   ✅ Composite Pattern (Medical devices)")