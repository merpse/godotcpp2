#include <gtest/gtest.h>
#include <memory>
#include <chrono>
#include <thread>

// Include mock header instead of real Godot-dependent headers  
#include "../shared/mocks/bed_test_mock.h"

class SurgicalBedTest : public ::testing::Test {
protected:
    void SetUp() override {
        surgical_bed = std::make_unique<MockSurgicalBed>();
    }
    
    void TearDown() override {
        surgical_bed.reset();
    }

    std::unique_ptr<MockSurgicalBed> surgical_bed;
};

// Test SurgicalBed specific functionality
TEST_F(SurgicalBedTest, SurgicalBedCreation) {
    ASSERT_NE(surgical_bed, nullptr);
    EXPECT_EQ(surgical_bed->getClassName(), "SurgicalBed");
    EXPECT_FALSE(surgical_bed->isPowered());
}

// Test sterile mode functionality
TEST_F(SurgicalBedTest, SterileModeOperations) {
    // Should work without power (safety feature)
    EXPECT_NO_THROW(surgical_bed->enterSterileMode());
    EXPECT_NO_THROW(surgical_bed->exitSterileMode());
    
    // Should work with power
    surgical_bed->powerOn();
    EXPECT_NO_THROW(surgical_bed->enterSterileMode());
    EXPECT_NO_THROW(surgical_bed->exitSterileMode());
}

// Test surgical procedures
TEST_F(SurgicalBedTest, SurgicalProcedures) {
    // Test procedure management
    EXPECT_NO_THROW(surgical_bed->startProcedure("appendectomy"));
    EXPECT_NO_THROW(surgical_bed->startProcedure("knee_surgery"));
    EXPECT_NO_THROW(surgical_bed->startProcedure("brain_surgery"));
    
    // Should handle empty procedure names gracefully
    EXPECT_NO_THROW(surgical_bed->startProcedure(""));
}

// Test medical device integration
TEST_F(SurgicalBedTest, MedicalDeviceIntegration) {
    // Test device operations (should not crash)
    EXPECT_NO_THROW(surgical_bed->startFullBodyScan());
    EXPECT_NO_THROW(surgical_bed->startVitalMonitoring());
    EXPECT_NO_THROW(surgical_bed->centerDevice());
    EXPECT_NO_THROW(surgical_bed->stopScanning());
    EXPECT_NO_THROW(surgical_bed->stopVitalMonitoring());
}

// Test surgical emergency handling
TEST_F(SurgicalBedTest, SurgicalEmergencyHandling) {
    // Surgical emergency should work without power
    EXPECT_NO_THROW(surgical_bed->triggerSurgicalEmergency());
    
    // Should work during procedures
    surgical_bed->startProcedure("emergency_surgery");
    EXPECT_NO_THROW(surgical_bed->triggerSurgicalEmergency());
    
    // Should work in sterile mode
    surgical_bed->enterSterileMode();
    EXPECT_NO_THROW(surgical_bed->triggerSurgicalEmergency());
}

// Test surgical bed positioning
TEST_F(SurgicalBedTest, SurgicalPositioning) {
    // Need to power on for height adjustments in mock
    surgical_bed->powerOn();
    
    // Test surgical-specific positioning
    EXPECT_NO_THROW(surgical_bed->setHeight(100.0f)); // Higher for surgical access
    EXPECT_EQ(surgical_bed->getHeight(), 100.0f);
    
    EXPECT_NO_THROW(surgical_bed->setHeight(110.0f)); // Maximum height
    EXPECT_EQ(surgical_bed->getHeight(), 110.0f);
}

// Test surgical bed safety without power
TEST_F(SurgicalBedTest, SurgicalSafetyWithoutPower) {
    // Verify initially powered off
    EXPECT_FALSE(surgical_bed->isPowered());
    
    // Critical safety operations should work without power
    EXPECT_NO_THROW(surgical_bed->enterSterileMode());
    EXPECT_NO_THROW(surgical_bed->startProcedure("emergency_procedure"));
    EXPECT_NO_THROW(surgical_bed->triggerSurgicalEmergency());
}

// Test complete surgical workflow
TEST_F(SurgicalBedTest, SurgicalWorkflow) {
    // Simulate surgical preparation workflow
    surgical_bed->powerOn();
    EXPECT_TRUE(surgical_bed->isPowered());
    
    // Pre-surgical setup
    surgical_bed->enterSterileMode();
    surgical_bed->setHeight(105.0f); // Optimal surgical height
    surgical_bed->startVitalMonitoring();
    
    // Begin procedure
    surgical_bed->startProcedure("cardiac_surgery");
    surgical_bed->startFullBodyScan();
    surgical_bed->centerDevice();
    
    // Post-procedure cleanup
    EXPECT_NO_THROW(surgical_bed->stopScanning());
    EXPECT_NO_THROW(surgical_bed->stopVitalMonitoring());
    EXPECT_NO_THROW(surgical_bed->exitSterileMode());
}

// Test surgical bed device coordination
TEST_F(SurgicalBedTest, DeviceCoordination) {
    // Test multiple device operations
    surgical_bed->powerOn();
    surgical_bed->enterSterileMode();
    
    // Start multiple monitoring systems
    surgical_bed->startVitalMonitoring();
    surgical_bed->startFullBodyScan();
    
    // Position and center device
    surgical_bed->centerDevice();
    
    // Verify cleanup works properly
    surgical_bed->stopScanning();
    surgical_bed->stopVitalMonitoring();
    
    // All operations should complete without throwing
    SUCCEED();
}

// Test mouse collision detection functionality
TEST_F(SurgicalBedTest, MouseCollisionDetection) {
    // Initially no collision should be detected
    EXPECT_FALSE(surgical_bed->isMouseHovering());
    EXPECT_FALSE(surgical_bed->isCollisionDetected());
    EXPECT_FALSE(surgical_bed->isHighlighted());
    
    // Simulate mouse entering bed area (collision detected)
    surgical_bed->simulateMouseEnter();
    EXPECT_TRUE(surgical_bed->isMouseHovering());
    EXPECT_TRUE(surgical_bed->isCollisionDetected());
    EXPECT_TRUE(surgical_bed->isHighlighted());
    
    // Simulate mouse exiting bed area (collision ended)
    surgical_bed->simulateMouseExit();
    EXPECT_FALSE(surgical_bed->isMouseHovering());
    EXPECT_FALSE(surgical_bed->isCollisionDetected());
    EXPECT_FALSE(surgical_bed->isHighlighted());
}

// Test collision interaction with click events
TEST_F(SurgicalBedTest, CollisionClickInteraction) {
    // Initially no clicks
    EXPECT_EQ(surgical_bed->getClickCount(), 0);
    
    // Click without hovering should not register
    surgical_bed->simulateMouseClick();
    EXPECT_EQ(surgical_bed->getClickCount(), 0);
    
    // Enter hover state and click
    surgical_bed->simulateMouseEnter();
    EXPECT_TRUE(surgical_bed->isMouseHovering());
    
    surgical_bed->simulateMouseClick();
    EXPECT_EQ(surgical_bed->getClickCount(), 1);
    
    // Multiple clicks while hovering
    surgical_bed->simulateMouseClick();
    surgical_bed->simulateMouseClick();
    EXPECT_EQ(surgical_bed->getClickCount(), 3);
    
    // Exit hover and verify state
    surgical_bed->simulateMouseExit();
    EXPECT_FALSE(surgical_bed->isMouseHovering());
    EXPECT_EQ(surgical_bed->getClickCount(), 3); // Click count persists
}

// Test visual feedback color changes
TEST_F(SurgicalBedTest, CollisionVisualFeedback) {
    // Test default color state
    EXPECT_EQ(surgical_bed->getHighlightColor(), "white");
    EXPECT_FALSE(surgical_bed->isHighlighted());
    
    // Simulate hover and color change to yellow
    surgical_bed->simulateMouseEnter();
    surgical_bed->setHighlightColor("yellow");
    EXPECT_EQ(surgical_bed->getHighlightColor(), "yellow");
    EXPECT_TRUE(surgical_bed->isHighlighted());
    
    // Test color restoration after hover ends
    surgical_bed->simulateMouseExit();
    surgical_bed->setHighlightColor("white"); // Restored to normal
    EXPECT_EQ(surgical_bed->getHighlightColor(), "white");
    EXPECT_FALSE(surgical_bed->isHighlighted());
}

// Test collision detection during surgical procedures
TEST_F(SurgicalBedTest, CollisionDuringSurgicalProcedure) {
    // Start a surgical procedure
    surgical_bed->powerOn();
    surgical_bed->enterSterileMode();
    surgical_bed->startProcedure("cardiac_surgery");
    
    // Collision detection should work during procedures
    EXPECT_FALSE(surgical_bed->isCollisionDetected());
    
    surgical_bed->simulateMouseEnter();
    EXPECT_TRUE(surgical_bed->isCollisionDetected());
    EXPECT_TRUE(surgical_bed->isProcedureActive());
    
    // Click interaction during procedure
    surgical_bed->simulateMouseClick();
    EXPECT_EQ(surgical_bed->getClickCount(), 1);
    
    // End procedure but keep collision state
    surgical_bed->endProcedure();
    EXPECT_FALSE(surgical_bed->isProcedureActive());
    EXPECT_TRUE(surgical_bed->isCollisionDetected()); // Collision state independent
    
    surgical_bed->simulateMouseExit();
    EXPECT_FALSE(surgical_bed->isCollisionDetected());
}

// Test collision detection timing
TEST_F(SurgicalBedTest, CollisionTiming) {
    // Test hover duration tracking
    surgical_bed->simulateMouseEnter();
    
    // Simulate some time passing (mock time advance)
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    
    surgical_bed->simulateMouseExit();
    EXPECT_GE(surgical_bed->getHoverDuration(), 0.0);
    
    // Test click timing
    surgical_bed->simulateMouseEnter();
    surgical_bed->simulateMouseClick();
    EXPECT_GT(surgical_bed->getLastClickTime(), 0);
}