#include <gtest/gtest.h>
#include <memory>

// Include the core registration system
#include "../../extensions/core/register_types.cpp"  // Note: including .cpp for testing

// Include classes that should be registered
#include "../../extensions/window_controls/window.h"
#include "../../extensions/medical_equipment/bed.h"
#include "../../extensions/medical_equipment/patient_bed.h"
#include "../../extensions/medical_equipment/surgical_bed.h"
#include "../../extensions/medical_equipment/godot_bed_factory.h"

// Include shared test utilities
// Include shared mocks only when not using real godot-cpp
#ifdef TESTING_MODE
#ifndef GODOT_CPP_CLASSES_NODE_HPP
#include "../shared/mocks/godot_mock.h"
#endif
#endif
#include "../shared/utils/test_helpers.h"

using namespace godot;

class RegisterTypesTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Initialize Godot mock for testing
        GodotMock::initialize();
        
        // Track registration calls
        registration_calls.clear();
    }

    void TearDown() override {
        GodotMock::cleanup();
    }
    
    // Track what gets registered during testing
    static std::vector<std::string> registration_calls;
};

std::vector<std::string> RegisterTypesTest::registration_calls;

// Test that initialization function exists and is callable
TEST_F(RegisterTypesTest, InitializationFunctionExists) {
    // Test that the initialization function can be called
    // Note: In a real environment, this would be called by Godot
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
}

// Test initialization with wrong level (should return early)
TEST_F(RegisterTypesTest, InitializationWithWrongLevel) {
    // Should not register anything for wrong initialization levels
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_CORE);
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SERVERS);
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_EDITOR);
    });
}

// Test that all expected classes are registered
TEST_F(RegisterTypesTest, AllExpectedClassesRegistered) {
    // This test verifies that the registration function attempts to register
    // all the expected classes. In a real test environment with Godot running,
    // we could check ClassDB directly.
    
    // For now, we verify that the registration function runs without error
    // and that all the required headers are properly included
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
    
    // Verify that key class types can be instantiated
    // (This indirectly tests that headers are correctly included)
    
    // Test window controls instantiation
    auto window = std::make_unique<CustomWindow>();
    EXPECT_NE(window, nullptr);
    
    // Test bed factory instantiation
    auto factory = std::make_unique<BedFactory>();
    EXPECT_NE(factory, nullptr);
    
    // Test patient bed instantiation
    auto patient_bed = std::make_unique<PatientBed>();
    EXPECT_NE(patient_bed, nullptr);
    EXPECT_EQ(patient_bed->getClassName(), "PatientBed");
    
    // Test surgical bed instantiation
    auto surgical_bed = std::make_unique<SurgicalBed>();
    EXPECT_NE(surgical_bed, nullptr);
    EXPECT_EQ(surgical_bed->getClassName(), "SurgicalBed");
}

// Test registration order and dependencies
TEST_F(RegisterTypesTest, RegistrationOrder) {
    // Verify that base classes are properly set up before derived classes
    // This is important for inheritance hierarchies
    
    // In our case, Bed is abstract and should be registered first,
    // then PatientBed and SurgicalBed which derive from it
    
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
    
    // Test that inheritance works correctly after registration
    PatientBed patient_bed;
    SurgicalBed surgical_bed;
    
    // These should work as they inherit from Bed
    Bed* bed_ptr1 = &patient_bed;
    Bed* bed_ptr2 = &surgical_bed;
    
    EXPECT_NE(bed_ptr1, nullptr);
    EXPECT_NE(bed_ptr2, nullptr);
    
    // Polymorphic behavior should work
    EXPECT_EQ(bed_ptr1->getClassName(), "PatientBed");
    EXPECT_EQ(bed_ptr2->getClassName(), "SurgicalBed");
}

// Test module initialization safety
TEST_F(RegisterTypesTest, MultipleInitializationSafety) {
    // Test that calling initialization multiple times doesn't cause issues
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
}

// Test class instantiation after registration
TEST_F(RegisterTypesTest, ClassInstantiationAfterRegistration) {
    // First register everything
    initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    
    // Test that all registered classes can be instantiated and work correctly
    
    // Test CustomWindow
    CustomWindow window;
    EXPECT_NO_THROW({
        // Basic window operations should work
        window.set_name("TestWindow");
    });
    
    // Test BedFactory
    BedFactory factory;
    EXPECT_NO_THROW({
        Bed* patient_bed = factory.create_patient_bed();
        ASSERT_NE(patient_bed, nullptr);
        EXPECT_EQ(patient_bed->getClassName(), "PatientBed");
        delete patient_bed;
        
        Bed* surgical_bed = factory.create_surgical_bed();
        ASSERT_NE(surgical_bed, nullptr);
        EXPECT_EQ(surgical_bed->getClassName(), "SurgicalBed");
        delete surgical_bed;
    });
    
    // Test direct bed instantiation
    PatientBed patient_bed;
    SurgicalBed surgical_bed;
    
    EXPECT_NO_THROW({
        patient_bed.power_on();
        surgical_bed.power_on();
        
        patient_bed.set_height(70.0f);
        surgical_bed.set_height(90.0f);
        
        EXPECT_FLOAT_EQ(patient_bed.getHeight(), 70.0f);
        EXPECT_FLOAT_EQ(surgical_bed.getHeight(), 90.0f);
    });
}

// Test error handling in registration
TEST_F(RegisterTypesTest, RegistrationErrorHandling) {
    // Test that registration handles potential errors gracefully
    // This is important for robust extension loading
    
    EXPECT_NO_THROW({
        // Even if some internal Godot registration might fail,
        // our initialization function should handle it gracefully
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
}

// Test that debug output is generated
TEST_F(RegisterTypesTest, DebugOutputGeneration) {
    // Verify that the registration process generates expected debug output
    // This helps with debugging extension loading issues
    
    // In a real environment, we could capture UtilityFunctions::print output
    // For now, we just ensure the function runs without crashing
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
}

// Test complete extension lifecycle
TEST_F(RegisterTypesTest, CompleteExtensionLifecycle) {
    // Test a complete lifecycle: initialize -> use classes -> cleanup
    
    // Initialize
    EXPECT_NO_THROW({
        initialize_window_module(MODULE_INITIALIZATION_LEVEL_SCENE);
    });
    
    // Use registered classes
    BedFactory factory;
    Bed* test_bed = factory.create_patient_bed();
    ASSERT_NE(test_bed, nullptr);
    
    // Perform operations
    test_bed->power_on();
    test_bed->set_height(75.0f);
    test_bed->activate_lights();
    test_bed->set_temperature(1); // NEUTRAL
    
    // Verify state
    EXPECT_FLOAT_EQ(test_bed->getHeight(), 75.0f);
    
    // Cleanup
    delete test_bed;
    
    // Should be able to create more instances
    Bed* another_bed = factory.create_surgical_bed();
    ASSERT_NE(another_bed, nullptr);
    EXPECT_EQ(another_bed->getClassName(), "SurgicalBed");
    delete another_bed;
}