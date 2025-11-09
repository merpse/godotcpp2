#include "gtest/gtest.h"
#include "bed.h"
#include "patient_bed.h"
#include "surgical_bed.h"
#include "bed_factory.h"
#include <memory>

// Mock subclass for testing abstract Bed class
class TestBed : public Bed {
public:
    std::string getClassName() const override { return "TestBed"; }
    
    void performSpecificChecks() override {
        // Test implementation
    }
    
    void onPowerOn() override {
        // Test implementation
    }
    
    void onPowerOff() override {
        // Test implementation
    }
};

class MedicalEquipmentTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Test setup
    }
    
    void TearDown() override {
        // Test cleanup
    }
};

// Test Bed base class functionality
TEST_F(MedicalEquipmentTest, BedBasicFunctionality) {
    TestBed bed;
    
    // Test initial state
    EXPECT_FALSE(bed.isPoweredOn());
    EXPECT_EQ(bed.getHeight(), 80.0f); // Default height
    EXPECT_EQ(bed.getClassName(), "TestBed");
    
    // Test power operations
    bed.powerOn();
    EXPECT_TRUE(bed.isPoweredOn());
    
    bed.powerOff();
    EXPECT_FALSE(bed.isPoweredOn());
}

TEST_F(MedicalEquipmentTest, BedHeightControl) {
    TestBed bed;
    bed.powerOn();
    
    // Test height adjustment
    bed.setHeight(90.0f);
    EXPECT_EQ(bed.getHeight(), 90.0f);
    
    // Test height limits
    bed.setHeight(200.0f); // Above max
    EXPECT_EQ(bed.getHeight(), 120.0f); // Should clamp to max
    
    bed.setHeight(30.0f); // Below min
    EXPECT_EQ(bed.getHeight(), 50.0f); // Should clamp to min
}

TEST_F(MedicalEquipmentTest, BedTemperatureControl) {
    TestBed bed;
    bed.powerOn();
    
    // Test temperature settings
    bed.setTemperature(TemperatureControl::Mode::WARM);
    EXPECT_EQ(bed.getCurrentTemperature(), TemperatureControl::Mode::WARM);
    
    bed.setTemperature(TemperatureControl::Mode::COLD);
    EXPECT_EQ(bed.getCurrentTemperature(), TemperatureControl::Mode::COLD);
    
    bed.setTemperature(TemperatureControl::Mode::NEUTRAL);
    EXPECT_EQ(bed.getCurrentTemperature(), TemperatureControl::Mode::NEUTRAL);
}

// Test PatientBed specific functionality
TEST_F(MedicalEquipmentTest, PatientBedOccupancy) {
    PatientBed patientBed;
    patientBed.powerOn();
    
    // Test initial occupancy state
    EXPECT_FALSE(patientBed.isOccupied());
    
    // Test occupancy change
    patientBed.setOccupancy(true);
    EXPECT_TRUE(patientBed.isOccupied());
    
    patientBed.setOccupancy(false);
    EXPECT_FALSE(patientBed.isOccupied());
}

TEST_F(MedicalEquipmentTest, PatientBedComfortMode) {
    PatientBed patientBed;
    patientBed.powerOn();
    
    // Test comfort mode
    EXPECT_FALSE(patientBed.isComfortModeActive());
    
    patientBed.activateComfortMode();
    EXPECT_TRUE(patientBed.isComfortModeActive());
    
    patientBed.deactivateComfortMode();
    EXPECT_FALSE(patientBed.isComfortModeActive());
}

// Test SurgicalBed specific functionality
TEST_F(MedicalEquipmentTest, SurgicalBedSterileMode) {
    SurgicalBed surgicalBed;
    surgicalBed.powerOn();
    
    // Test initial sterile mode state
    EXPECT_FALSE(surgicalBed.isSterileMode());
    
    // Test sterile mode activation
    surgicalBed.enterSterileMode();
    EXPECT_TRUE(surgicalBed.isSterileMode());
    
    surgicalBed.exitSterileMode();
    EXPECT_FALSE(surgicalBed.isSterileMode());
}

TEST_F(MedicalEquipmentTest, SurgicalBedProcedureManagement) {
    SurgicalBed surgicalBed;
    surgicalBed.powerOn();
    
    // Test initial procedure state
    EXPECT_FALSE(surgicalBed.isProcedureActive());
    
    // Test procedure start/end
    surgicalBed.startProcedure("brain_surgery");
    EXPECT_TRUE(surgicalBed.isProcedureActive());
    
    surgicalBed.endProcedure();
    EXPECT_FALSE(surgicalBed.isProcedureActive());
}

TEST_F(MedicalEquipmentTest, SurgicalBedMedicalDeviceIntegration) {
    SurgicalBed surgicalBed;
    surgicalBed.powerOn();
    
    // Test device operations (should not crash)
    EXPECT_NO_THROW(surgicalBed.startFullBodyScan());
    EXPECT_NO_THROW(surgicalBed.startVitalMonitoring());
    EXPECT_NO_THROW(surgicalBed.centerDevice());
    EXPECT_NO_THROW(surgicalBed.stopScanning());
    EXPECT_NO_THROW(surgicalBed.stopVitalMonitoring());
}

// Test BedFactory
TEST_F(MedicalEquipmentTest, BedFactoryCreation) {
    // Test PatientBed creation
    auto patientBed = BedFactory::createBed(BedFactory::BedType::PATIENT_BED);
    ASSERT_NE(patientBed, nullptr);
    EXPECT_EQ(patientBed->getClassName(), "PatientBed");
    
    // Test SurgicalBed creation
    auto surgicalBed = BedFactory::createBed(BedFactory::BedType::SURGICAL_BED);
    ASSERT_NE(surgicalBed, nullptr);
    EXPECT_EQ(surgicalBed->getClassName(), "SurgicalBed");
}

TEST_F(MedicalEquipmentTest, BedFactoryStringCreation) {
    // Test string-based creation
    auto patientBed = BedFactory::createBedFromString("patient_bed");
    ASSERT_NE(patientBed, nullptr);
    EXPECT_EQ(patientBed->getClassName(), "PatientBed");
    
    auto surgicalBed = BedFactory::createBedFromString("surgical_bed");
    ASSERT_NE(surgicalBed, nullptr);
    EXPECT_EQ(surgicalBed->getClassName(), "SurgicalBed");
    
    // Test case insensitive
    auto patientBed2 = BedFactory::createBedFromString("PATIENT_BED");
    ASSERT_NE(patientBed2, nullptr);
    EXPECT_EQ(patientBed2->getClassName(), "PatientBed");
    
    // Test alias recognition
    auto patientBed3 = BedFactory::createBedFromString("patient");
    ASSERT_NE(patientBed3, nullptr);
    EXPECT_EQ(patientBed3->getClassName(), "PatientBed");
}

TEST_F(MedicalEquipmentTest, BedFactoryAvailableTypes) {
    auto types = BedFactory::getAvailableBedTypes();
    EXPECT_EQ(types.size(), 2);
    EXPECT_NE(std::find(types.begin(), types.end(), "patient_bed"), types.end());
    EXPECT_NE(std::find(types.begin(), types.end(), "surgical_bed"), types.end());
}

// Test bed safety and error handling
TEST_F(MedicalEquipmentTest, BedSafetyChecks) {
    TestBed bed;
    
    // Test operations without power (should be safe)
    EXPECT_NO_THROW(bed.setHeight(90.0f));
    EXPECT_NO_THROW(bed.setTemperature(TemperatureControl::Mode::WARM));
    EXPECT_NO_THROW(bed.triggerEmergency());
}

TEST_F(MedicalEquipmentTest, PatientBedSafetyWithoutPower) {
    PatientBed patientBed;
    
    // Test safety operations without power
    EXPECT_NO_THROW(patientBed.setOccupancy(true));
    EXPECT_NO_THROW(patientBed.activateComfortMode());
    EXPECT_NO_THROW(patientBed.triggerEmergency());
}

TEST_F(MedicalEquipmentTest, SurgicalBedSafetyWithoutPower) {
    SurgicalBed surgicalBed;
    
    // Test safety operations without power
    EXPECT_NO_THROW(surgicalBed.enterSterileMode());
    EXPECT_NO_THROW(surgicalBed.startProcedure("test_procedure"));
    EXPECT_NO_THROW(surgicalBed.triggerSurgicalEmergency());
}