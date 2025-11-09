#include "patient_bed.h"
#include <godot_cpp/core/class_db.hpp>
#include <ctime>

using namespace godot;

PatientBed::PatientBed() : comfortMode(false), lastOccupancyTime(0.0f) {
    // Set patient bed specific height ranges
    minHeight = 40.0f;   // Lower minimum for patient access
    maxHeight = 90.0f;   // Lower maximum for safety
    currentHeight = 55.0f; // Comfortable default height
    
    // Initialize occupancy sensor
    occupancySensor = std::make_unique<OccupancySensor>();
    occupancySensor->addObserver(this);
    
    UtilityFunctions::print("PatientBed created with occupancy monitoring");
}

std::string PatientBed::getClassName() const {
    return "PatientBed";
}

void PatientBed::simulatePatientEntry() {
    UtilityFunctions::print("Patient entering bed...");
    if (occupancySensor) {
        occupancySensor->setOccupied(true);
    }
}

void PatientBed::simulatePatientExit() {
    UtilityFunctions::print("Patient leaving bed...");
    if (occupancySensor) {
        occupancySensor->setOccupied(false);
    }
}

bool PatientBed::isOccupied() const {
    return occupancySensor ? occupancySensor->getOccupied() : false;
}

void PatientBed::enableComfortMode() {
    comfortMode = true;
    UtilityFunctions::print("Comfort mode ENABLED");
    
    if (isOccupied()) {
        adjustForPatientComfort();
    }
}

void PatientBed::disableComfortMode() {
    comfortMode = false;
    UtilityFunctions::print("Comfort mode DISABLED");
    resetToDefaultSettings();
}

// Occupancy observer implementation
void PatientBed::onPatientEntered() {
    lastOccupancyTime = static_cast<float>(std::time(nullptr));
    UtilityFunctions::print("👤 Patient detected on bed");
    
    // Automatically adjust for patient comfort
    if (comfortMode) {
        adjustForPatientComfort();
    }
    
    // Provide gentle lighting
    if (lightStrip && !lightStrip->isEmergencyMode()) {
        lightStrip->setBrightness(0.3f); // Soft lighting
        lightStrip->setColor(LightColor(255, 248, 220)); // Warm white
    }
}

void PatientBed::onPatientLeft() {
    UtilityFunctions::print("👋 Patient left the bed");
    
    // Reset to default settings when patient leaves
    resetToDefaultSettings();
    
    // Return to normal lighting
    if (lightStrip && !lightStrip->isEmergencyMode()) {
        lightStrip->setBrightness(0.5f);
        lightStrip->setColor(LightColor(255, 255, 255)); // Normal white
    }
}

// Hook method implementations
void PatientBed::performSpecificChecks() {
    // Patient bed specific checks
    UtilityFunctions::print("Checking occupancy sensor...");
    bool sensorOK = occupancySensor != nullptr;
    UtilityFunctions::print("Occupancy sensor: ", sensorOK ? "OK" : "ERROR");
    
    UtilityFunctions::print("Checking comfort settings...");
    UtilityFunctions::print("Comfort mode: ", comfortMode ? "ENABLED" : "DISABLED");
    
    if (isOccupied()) {
        float occupancyDuration = static_cast<float>(std::time(nullptr)) - lastOccupancyTime;
        UtilityFunctions::print("Patient occupancy duration: ", occupancyDuration, " seconds");
    }
}

void PatientBed::onPowerOn() {
    UtilityFunctions::print("PatientBed systems initializing...");
    
    // Initialize occupancy monitoring
    if (occupancySensor) {
        UtilityFunctions::print("Occupancy monitoring activated");
    }
    
    // Set default patient bed settings
    setHeight(55.0f); // Comfortable default
    setTemperature(TemperatureControl::Mode::NEUTRAL);
}

void PatientBed::onPowerOff() {
    UtilityFunctions::print("PatientBed systems shutting down...");
    
    // Ensure patient safety before shutdown
    if (isOccupied()) {
        UtilityFunctions::print("⚠️  WARNING: Patient still on bed during shutdown!");
    }
    
    disableComfortMode();
}

void PatientBed::adjustForPatientComfort() {
    if (!isPoweredOn) return;
    
    UtilityFunctions::print("Adjusting bed for patient comfort...");
    
    // Optimal height for patient comfort
    setHeight(50.0f);
    
    // Set warm temperature for comfort
    setTemperature(TemperatureControl::Mode::WARM);
    
    // Adjust lighting for comfort
    if (lightStrip) {
        lightStrip->setBrightness(0.4f);
        lightStrip->setColor(LightColor(255, 240, 200)); // Soft warm light
    }
}

void PatientBed::resetToDefaultSettings() {
    if (!isPoweredOn) return;
    
    UtilityFunctions::print("Resetting to default settings...");
    
    // Standard height
    setHeight(55.0f);
    
    // Neutral temperature
    setTemperature(TemperatureControl::Mode::NEUTRAL);
    
    // Normal lighting
    if (lightStrip) {
        lightStrip->setBrightness(0.5f);
        lightStrip->setColor(LightColor(255, 255, 255));
    }
}

void PatientBed::_bind_methods() {
    // Bind PatientBed specific methods
    ClassDB::bind_method(D_METHOD("simulate_patient_entry"), &PatientBed::simulatePatientEntry);
    ClassDB::bind_method(D_METHOD("simulate_patient_exit"), &PatientBed::simulatePatientExit);
    ClassDB::bind_method(D_METHOD("is_occupied"), &PatientBed::isOccupied);
    ClassDB::bind_method(D_METHOD("enable_comfort_mode"), &PatientBed::enableComfortMode);
    ClassDB::bind_method(D_METHOD("disable_comfort_mode"), &PatientBed::disableComfortMode);
    ClassDB::bind_method(D_METHOD("is_comfort_mode_enabled"), &PatientBed::isComfortModeEnabled);
}