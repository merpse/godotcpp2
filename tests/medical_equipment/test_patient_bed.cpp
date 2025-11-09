#include <gtest/gtest.h>
#include <memory>

// Include mock header instead of real Godot-dependent headers  
#include "../shared/mocks/bed_test_mock.h"

class PatientBedTest : public ::testing::Test {
protected:
    void SetUp() override {
        patient_bed = std::make_unique<MockPatientBed>();
    }
    
    void TearDown() override {
        patient_bed.reset();
    }

    std::unique_ptr<MockPatientBed> patient_bed;
};

// Test PatientBed specific functionality
TEST_F(PatientBedTest, PatientBedCreation) {
    ASSERT_NE(patient_bed, nullptr);
    EXPECT_EQ(patient_bed->getClassName(), "PatientBed");
    EXPECT_FALSE(patient_bed->isPowered());
}

// Test occupancy functionality
TEST_F(PatientBedTest, OccupancyOperations) {
    // Initially should be unoccupied
    EXPECT_FALSE(patient_bed->isOccupied());
    
    // Set occupancy
    patient_bed->setOccupied(true);
    EXPECT_TRUE(patient_bed->isOccupied());
    
    patient_bed->setOccupied(false);
    EXPECT_FALSE(patient_bed->isOccupied());
}

// Test comfort mode functionality
TEST_F(PatientBedTest, ComfortMode) {
    EXPECT_NO_THROW(patient_bed->setComfortMode(true));
    EXPECT_TRUE(patient_bed->isComfortMode());
    
    // Should work with power
    patient_bed->powerOn();
    EXPECT_NO_THROW(patient_bed->setComfortMode(false));
    EXPECT_FALSE(patient_bed->isComfortMode());
}

// Test patient-specific features
TEST_F(PatientBedTest, PatientSpecificFeatures) {
    // Test patient positioning
    EXPECT_NO_THROW(patient_bed->adjustForPatientComfort());
    
    // Test monitoring capabilities
    EXPECT_NO_THROW(patient_bed->startVitalMonitoring());
    EXPECT_NO_THROW(patient_bed->stopVitalMonitoring());
}

// Test emergency scenarios for patient bed
TEST_F(PatientBedTest, PatientEmergencyHandling) {
    // Patient bed emergency should work without power
    EXPECT_NO_THROW(patient_bed->triggerEmergency());
    
    // Should work with patient occupied
    patient_bed->setOccupied(true);
    EXPECT_NO_THROW(patient_bed->triggerEmergency());
}

// Test patient bed height adjustments
TEST_F(PatientBedTest, PatientBedHeightAdjustments) {
    // Test default height (from mock)
    EXPECT_EQ(patient_bed->getHeight(), 75.0f);
    
    // Need to power on for height adjustments in mock
    patient_bed->powerOn();
    
    // Test patient-friendly height adjustments
    patient_bed->setHeight(70.0f); // Lower for easy access
    EXPECT_EQ(patient_bed->getHeight(), 70.0f);
    
    patient_bed->setHeight(85.0f); // Higher for care procedures
    EXPECT_EQ(patient_bed->getHeight(), 85.0f);
}

// Test patient bed safety without power
TEST_F(PatientBedTest, SafetyWithoutPower) {
    // Verify initially powered off
    EXPECT_FALSE(patient_bed->isPowered());
    
    // These operations should be safe for patients
    EXPECT_NO_THROW(patient_bed->setOccupied(true));
    EXPECT_NO_THROW(patient_bed->setComfortMode(true));
    EXPECT_NO_THROW(patient_bed->triggerEmergency());
    EXPECT_NO_THROW(patient_bed->adjustForPatientComfort());
}

// Test patient care workflow
TEST_F(PatientBedTest, PatientCareWorkflow) {
    // Simulate patient admission workflow
    patient_bed->powerOn();
    EXPECT_TRUE(patient_bed->isPowered());
    
    patient_bed->setOccupied(true);
    EXPECT_TRUE(patient_bed->isOccupied());
    
    patient_bed->setComfortMode(true);
    patient_bed->adjustForPatientComfort();
    patient_bed->startVitalMonitoring();
    
    // All should execute without throwing
    EXPECT_NO_THROW(patient_bed->stopVitalMonitoring());
    
    // Patient discharge
    patient_bed->setOccupied(false);
    EXPECT_FALSE(patient_bed->isOccupied());
}