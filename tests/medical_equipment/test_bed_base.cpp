#include <gtest/gtest.h>
#include <memory>

// Include mock header instead of real Godot-dependent headers  
#include "../shared/mocks/bed_test_mock.h"

class BedBaseTest : public ::testing::Test {
protected:
    void SetUp() override {
        test_bed = std::make_unique<TestBed>();
    }
    
    void TearDown() override {
        test_bed.reset();
    }

    std::unique_ptr<TestBed> test_bed;
};

// Test Bed base class initial state
TEST_F(BedBaseTest, InitialState) {
    EXPECT_FALSE(test_bed->isPowered());
    EXPECT_EQ(test_bed->getHeight(), 60.0f); // Default height from mock
    EXPECT_EQ(test_bed->getClassName(), "TestBed");
    EXPECT_FALSE(test_bed->checks_performed);
    EXPECT_FALSE(test_bed->power_on_called);
    EXPECT_FALSE(test_bed->power_off_called);
}

// Test power operations
TEST_F(BedBaseTest, PowerOperations) {
    // Initially powered off
    EXPECT_FALSE(test_bed->isPowered());
    
    // Power on
    test_bed->powerOn();
    EXPECT_TRUE(test_bed->isPowered());
    EXPECT_TRUE(test_bed->power_on_called);
    
    // Power off
    test_bed->powerOff();
    EXPECT_FALSE(test_bed->isPowered());
    EXPECT_TRUE(test_bed->power_off_called);
}

// Test height operations
TEST_F(BedBaseTest, HeightOperations) {
    // Test default height  
    EXPECT_EQ(test_bed->getHeight(), 60.0f);
    
    // Need to power on for height adjustments to work in the mock
    test_bed->powerOn();
    
    // Test setting height
    test_bed->setHeight(90.0f);
    EXPECT_EQ(test_bed->getHeight(), 90.0f);
    
    test_bed->setHeight(70.0f);
    EXPECT_EQ(test_bed->getHeight(), 70.0f);
    
    // Test height bounds (implementation dependent)
    EXPECT_NO_THROW(test_bed->setHeight(120.0f));
    EXPECT_NO_THROW(test_bed->setHeight(50.0f));
}

// Test temperature control
TEST_F(BedBaseTest, TemperatureControl) {
    // Test temperature settings - should not crash
    EXPECT_NO_THROW(test_bed->setTemperature(TemperatureControl::Mode::WARM));
    EXPECT_NO_THROW(test_bed->setTemperature(TemperatureControl::Mode::COLD));
    EXPECT_NO_THROW(test_bed->setTemperature(TemperatureControl::Mode::NEUTRAL));
}

// Test emergency functionality
TEST_F(BedBaseTest, EmergencyOperations) {
    // Emergency should work regardless of power state
    EXPECT_NO_THROW(test_bed->triggerEmergency());
    
    // Power on and test emergency
    test_bed->powerOn();
    EXPECT_NO_THROW(test_bed->triggerEmergency());
}

// Test safety operations without power
TEST_F(BedBaseTest, SafetyOperationsWithoutPower) {
    // Verify initially powered off
    EXPECT_FALSE(test_bed->isPowered());
    
    // These operations should be safe without power (though they may not change anything in mock)
    EXPECT_NO_THROW(test_bed->setHeight(90.0f));
    EXPECT_NO_THROW(test_bed->setTemperature(TemperatureControl::Mode::WARM));
    EXPECT_NO_THROW(test_bed->triggerEmergency());
}

// Test virtual method calls
TEST_F(BedBaseTest, VirtualMethodCalls) {
    // Test that virtual methods are called correctly
    test_bed->powerOn();
    EXPECT_TRUE(test_bed->power_on_called);
    
    test_bed->powerOff();
    EXPECT_TRUE(test_bed->power_off_called);
    
    // Perform checks should call the virtual method
    test_bed->performChecks();
    EXPECT_TRUE(test_bed->checks_performed);
}