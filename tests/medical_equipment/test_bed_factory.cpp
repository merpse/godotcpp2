#include <gtest/gtest.h>
#include <memory>
#include <algorithm>

// Include mock header instead of real Godot-dependent headers  
#include "../shared/mocks/bed_test_mock.h"

class BedFactoryTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Test setup - factory should be ready to use
    }
    
    void TearDown() override {
        // Test cleanup
    }
};

// Test factory creation with enum types
TEST_F(BedFactoryTest, CreateBedWithEnumTypes) {
    // Test PatientBed creation
    auto patientBed = MockBedFactory::createBed(MockBedFactory::BedType::PATIENT);
    ASSERT_NE(patientBed, nullptr);
    EXPECT_EQ(patientBed->getClassName(), "PatientBed");
    
    // Test SurgicalBed creation
    auto surgicalBed = MockBedFactory::createBed(MockBedFactory::BedType::SURGICAL);
    ASSERT_NE(surgicalBed, nullptr);
    EXPECT_EQ(surgicalBed->getClassName(), "SurgicalBed");
}

// Test factory creation with string parameters
TEST_F(BedFactoryTest, CreateBedWithStringTypes) {
    // Test exact string matches
    auto patientBed = MockBedFactory::createBedFromString("patient_bed");
    ASSERT_NE(patientBed, nullptr);
    EXPECT_EQ(patientBed->getClassName(), "PatientBed");
    
    auto surgicalBed = MockBedFactory::createBedFromString("surgical_bed");
    ASSERT_NE(surgicalBed, nullptr);
    EXPECT_EQ(surgicalBed->getClassName(), "SurgicalBed");
}

// Test factory with case insensitive strings
TEST_F(BedFactoryTest, CreateBedCaseInsensitive) {
    // Test case variations
    auto patientBed1 = MockBedFactory::createBedFromString("PATIENT_BED");
    ASSERT_NE(patientBed1, nullptr);
    EXPECT_EQ(patientBed1->getClassName(), "PatientBed");
    
    auto patientBed2 = MockBedFactory::createBedFromString("Patient_Bed");
    ASSERT_NE(patientBed2, nullptr);
    EXPECT_EQ(patientBed2->getClassName(), "PatientBed");
    
    auto surgicalBed1 = MockBedFactory::createBedFromString("SURGICAL_BED");
    ASSERT_NE(surgicalBed1, nullptr);
    EXPECT_EQ(surgicalBed1->getClassName(), "SurgicalBed");
}

// Test factory with alias recognition
TEST_F(BedFactoryTest, CreateBedWithAliases) {
    // Test patient bed aliases
    auto patientBed1 = MockBedFactory::createBedFromString("patient");
    ASSERT_NE(patientBed1, nullptr);
    EXPECT_EQ(patientBed1->getClassName(), "PatientBed");
    
    auto patientBed2 = MockBedFactory::createBedFromString("PATIENT");
    ASSERT_NE(patientBed2, nullptr);
    EXPECT_EQ(patientBed2->getClassName(), "PatientBed");
    
    // Test surgical bed aliases  
    auto surgicalBed1 = MockBedFactory::createBedFromString("surgical");
    ASSERT_NE(surgicalBed1, nullptr);
    EXPECT_EQ(surgicalBed1->getClassName(), "SurgicalBed");
    
    auto surgicalBed2 = MockBedFactory::createBedFromString("SURGICAL");
    ASSERT_NE(surgicalBed2, nullptr);
    EXPECT_EQ(surgicalBed2->getClassName(), "SurgicalBed");
}

// Test invalid bed type handling
TEST_F(BedFactoryTest, InvalidBedTypeHandling) {
    // Test invalid string
    auto invalidBed = MockBedFactory::createBedFromString("invalid_bed_type");
    EXPECT_EQ(invalidBed, nullptr);
    
    // Test empty string
    auto emptyBed = MockBedFactory::createBedFromString("");
    EXPECT_EQ(emptyBed, nullptr);
    
    // Test null or unrecognized strings
    auto unknownBed = MockBedFactory::createBedFromString("unknown");
    EXPECT_EQ(unknownBed, nullptr);
}

// Test available bed types functionality
TEST_F(BedFactoryTest, AvailableBedTypes) {
    auto types = MockBedFactory::getAvailableBedTypes();
    
    // Should have exactly 2 types
    EXPECT_EQ(types.size(), 2);
    
    // Should contain both bed types
    EXPECT_NE(std::find(types.begin(), types.end(), "patient_bed"), types.end());
    EXPECT_NE(std::find(types.begin(), types.end(), "surgical_bed"), types.end());
}

// Test multiple bed creation
TEST_F(BedFactoryTest, MultipleBedCreation) {
    // Create multiple beds to ensure factory works repeatedly
    std::vector<std::unique_ptr<TestBed>> beds;
    
    // Create 5 patient beds
    for (int i = 0; i < 5; ++i) {
        auto bed = MockBedFactory::createBed(MockBedFactory::BedType::PATIENT);
        ASSERT_NE(bed, nullptr);
        EXPECT_EQ(bed->getClassName(), "PatientBed");
        beds.push_back(std::move(bed));
    }
    
    // Create 3 surgical beds
    for (int i = 0; i < 3; ++i) {
        auto bed = MockBedFactory::createBed(MockBedFactory::BedType::SURGICAL);
        ASSERT_NE(bed, nullptr);
        EXPECT_EQ(bed->getClassName(), "SurgicalBed");
        beds.push_back(std::move(bed));
    }
    
    // Should have 8 beds total
    EXPECT_EQ(beds.size(), 8);
}

// Test bed functionality after factory creation
TEST_F(BedFactoryTest, BedFunctionalityAfterCreation) {
    // Create beds via factory
    auto patientBed = MockBedFactory::createBed(MockBedFactory::BedType::PATIENT);
    auto surgicalBed = MockBedFactory::createBed(MockBedFactory::BedType::SURGICAL);
    
    ASSERT_NE(patientBed, nullptr);
    ASSERT_NE(surgicalBed, nullptr);
    
    // Test basic functionality works
    EXPECT_NO_THROW(patientBed->powerOn());
    EXPECT_TRUE(patientBed->isPowered());
    
    EXPECT_NO_THROW(surgicalBed->powerOn());
    EXPECT_TRUE(surgicalBed->isPowered());
    
    // Test height adjustment
    patientBed->setHeight(85.0f);
    EXPECT_EQ(patientBed->getHeight(), 85.0f);
    
    surgicalBed->setHeight(100.0f);
    EXPECT_EQ(surgicalBed->getHeight(), 100.0f);
    
    // Test emergency functionality
    EXPECT_NO_THROW(patientBed->triggerEmergency());
    EXPECT_NO_THROW(surgicalBed->triggerEmergency());
}