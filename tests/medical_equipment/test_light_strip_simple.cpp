#include <gtest/gtest.h>
#include "../shared/mocks/light_strip_test_mock.h"

// Simple test for LightStrip core functionality
class LightStripTest : public ::testing::Test {
protected:
    void SetUp() override {
        lightStrip = std::make_unique<LightStrip>();
    }

    void TearDown() override {
        lightStrip.reset();
    }

    std::unique_ptr<LightStrip> lightStrip;
};

// Test basic LightStrip creation and initial state
TEST_F(LightStripTest, LightStripCreation) {
    EXPECT_NE(lightStrip, nullptr);
    EXPECT_EQ(lightStrip->get_brightness(), 1.0f);  // Default brightness
    EXPECT_FALSE(lightStrip->is_emergency_mode());  // Should start in normal mode
}

// Test brightness control
TEST_F(LightStripTest, BrightnessControl) {
    lightStrip->set_brightness(0.5f);
    EXPECT_FLOAT_EQ(lightStrip->get_brightness(), 0.5f);
    
    lightStrip->set_brightness(0.0f);
    EXPECT_FLOAT_EQ(lightStrip->get_brightness(), 0.0f);
    
    lightStrip->set_brightness(1.0f);
    EXPECT_FLOAT_EQ(lightStrip->get_brightness(), 1.0f);
}

// Test color control
TEST_F(LightStripTest, ColorControl) {
    lightStrip->set_color(1.0f, 0.5f, 0.25f);
    auto color = lightStrip->get_color();
    EXPECT_FLOAT_EQ(color.r, 1.0f);
    EXPECT_FLOAT_EQ(color.g, 0.5f);
    EXPECT_FLOAT_EQ(color.b, 0.25f);
}

// Test emergency mode activation
TEST_F(LightStripTest, EmergencyModeActivation) {
    EXPECT_FALSE(lightStrip->is_emergency_mode());
    
    lightStrip->activate_emergency_mode();
    EXPECT_TRUE(lightStrip->is_emergency_mode());
    
    lightStrip->deactivate_emergency_mode();
    EXPECT_FALSE(lightStrip->is_emergency_mode());
}

// Test Strategy pattern behavior switching
TEST_F(LightStripTest, BehaviorSwitching) {
    // Start with normal behavior
    EXPECT_FALSE(lightStrip->is_emergency_mode());
    
    // Switch to emergency behavior
    lightStrip->set_behavior(std::make_unique<EmergencyLightBehavior>());
    EXPECT_TRUE(lightStrip->is_emergency_mode());
    
    // Switch back to normal behavior
    lightStrip->set_behavior(std::make_unique<NormalLightBehavior>());
    EXPECT_FALSE(lightStrip->is_emergency_mode());
}

// Test power operations
TEST_F(LightStripTest, PowerOperations) {
    // Test turning on/off
    lightStrip->turn_on();
    EXPECT_TRUE(lightStrip->is_powered_on());
    
    lightStrip->turn_off();
    EXPECT_FALSE(lightStrip->is_powered_on());
}

// GodotLightStrip wrapper tests
class GodotLightStripTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Note: In real Godot environment, this would be properly initialized
        godotLightStrip = std::make_unique<GodotLightStrip>();
    }

    void TearDown() override {
        godotLightStrip.reset();
    }

    std::unique_ptr<GodotLightStrip> godotLightStrip;
};

// Test GodotLightStrip creation
TEST_F(GodotLightStripTest, GodotLightStripCreation) {
    EXPECT_NE(godotLightStrip, nullptr);
}

// Test wrapper methods
TEST_F(GodotLightStripTest, WrapperMethods) {
    // Test brightness wrapper
    godotLightStrip->set_brightness(0.8f);
    EXPECT_FLOAT_EQ(godotLightStrip->get_brightness(), 0.8f);
    
    // Test color wrapper
    godotLightStrip->set_color(1.0f, 0.0f, 0.0f);  // Red
    // Note: get_color() would need to be implemented in GodotLightStrip
}

// Test emergency activation through wrapper
TEST_F(GodotLightStripTest, EmergencyActivationWrapper) {
    EXPECT_FALSE(godotLightStrip->is_emergency_mode());
    
    godotLightStrip->activate_emergency_mode();
    EXPECT_TRUE(godotLightStrip->is_emergency_mode());
    
    godotLightStrip->deactivate_emergency_mode();
    EXPECT_FALSE(godotLightStrip->is_emergency_mode());
}

// Test behavior setting through string interface
TEST_F(GodotLightStripTest, BehaviorStringInterface) {
    // Test setting behavior via string (GDScript interface)
    godotLightStrip->set_behavior("emergency");
    EXPECT_TRUE(godotLightStrip->is_emergency_mode());
    
    godotLightStrip->set_behavior("normal");
    EXPECT_FALSE(godotLightStrip->is_emergency_mode());
}

// Test getting current mode string
TEST_F(GodotLightStripTest, GetCurrentModeString) {
    // Test normal mode string
    godotLightStrip->set_behavior("normal");
    // Note: get_current_mode() implementation would return appropriate string
    
    // Test emergency mode string
    godotLightStrip->set_behavior("emergency");
    // Note: get_current_mode() implementation would return appropriate string
}