#include "surgical_bed.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

SurgicalBed::SurgicalBed() : sterileMode(false), procedureInProgress(false), 
                            maxSurgicalHeight(120.0f), minSurgicalHeight(70.0f), currentProcedure("") {
    // Set surgical bed specific height ranges
    minHeight = 60.0f;   // Higher minimum for surgical procedures
    maxHeight = 120.0f;  // Higher maximum for surgeon access
    currentHeight = 85.0f; // Optimal surgical default
    
    initializeSurgicalSystems();
    
    UtilityFunctions::print("SurgicalBed created with advanced medical systems");
}

std::string SurgicalBed::getClassName() const {
    return "SurgicalBed";
}

void SurgicalBed::initializeSurgicalSystems() {
    // Initialize medical device
    medicalDevice = std::make_unique<ScannerDevice>();
    
    UtilityFunctions::print("🏥 Surgical systems initialized");
}

void SurgicalBed::enterSterileMode() {
    if (!isPoweredOn) {
        UtilityFunctions::print("Cannot enter sterile mode - bed is powered off");
        return;
    }
    
    sterileMode = true;
    UtilityFunctions::print("🔬 STERILE MODE ACTIVATED");
    
    setupSterileEnvironment();
}

void SurgicalBed::exitSterileMode() {
    sterileMode = false;
    UtilityFunctions::print("🔬 Sterile mode deactivated");
    
    // Return to normal settings
    if (lightStrip) {
        lightStrip->setBrightness(0.5f);
        lightStrip->setColor(LightColor(255, 255, 255));
    }
}

void SurgicalBed::setupSterileEnvironment() {
    // Set optimal lighting for sterile procedures
    if (lightStrip) {
        lightStrip->setBrightness(0.9f); // Bright lighting for precision
        lightStrip->setColor(LightColor(255, 255, 255)); // Pure white light
    }
    
    // Set cool temperature for sterile environment
    setTemperature(TemperatureControl::Mode::COLD);
    
    UtilityFunctions::print("✨ Sterile environment configured");
}

void SurgicalBed::startProcedure(const String& procedureType) {
    if (!isPoweredOn) {
        UtilityFunctions::print("Cannot start procedure - bed is powered off");
        return;
    }
    
    if (!sterileMode) {
        UtilityFunctions::print("⚠️  WARNING: Starting procedure without sterile mode!");
    }
    
    procedureInProgress = true;
    currentProcedure = std::string(procedureType.utf8().get_data());
    
    UtilityFunctions::print("🏥 Starting surgical procedure: ", procedureType);
    
    validateProcedureRequirements(procedureType);
    adjustForProcedure(procedureType);
    
    // Start vital monitoring during procedure
    if (medicalDevice) {
        medicalDevice->startVitalMonitoring();
    }
}

void SurgicalBed::endProcedure() {
    if (!procedureInProgress) {
        UtilityFunctions::print("No active procedure to end");
        return;
    }
    
    UtilityFunctions::print("✅ Ending surgical procedure: ", currentProcedure.c_str());
    
    procedureInProgress = false;
    currentProcedure = "";
    
    // Stop monitoring
    if (medicalDevice) {
        medicalDevice->stopVitalMonitoring();
        medicalDevice->stopScan();
    }
    
    // Return to default settings
    setHeight(85.0f);
    exitSterileMode();
}

// Medical device operations
void SurgicalBed::startFullBodyScan() {
    if (medicalDevice) {
        UtilityFunctions::print("🔍 Initiating full body scan...");
        medicalDevice->startFullBodyScan();
    }
}

void SurgicalBed::startBrainScan() {
    if (medicalDevice) {
        UtilityFunctions::print("🧠 Initiating brain scan...");
        medicalDevice->startBrainScan();
    }
}

void SurgicalBed::stopScanning() {
    if (medicalDevice) {
        medicalDevice->stopScan();
    }
}

void SurgicalBed::startVitalMonitoring() {
    if (medicalDevice) {
        medicalDevice->startVitalMonitoring();
    }
}

void SurgicalBed::stopVitalMonitoring() {
    if (medicalDevice) {
        medicalDevice->stopVitalMonitoring();
    }
}

void SurgicalBed::updatePatientVitals() {
    if (medicalDevice) {
        medicalDevice->updateVitals();
    }
}

// Device positioning
void SurgicalBed::swivelDeviceLeft(float angle) {
    if (medicalDevice) {
        medicalDevice->swivelLeft(angle);
    }
}

void SurgicalBed::swivelDeviceRight(float angle) {
    if (medicalDevice) {
        medicalDevice->swivelRight(angle);
    }
}

void SurgicalBed::centerDevice() {
    if (medicalDevice) {
        medicalDevice->centerDevice();
        UtilityFunctions::print("Medical device centered for procedure");
    }
}

void SurgicalBed::positionForPatientAccess() {
    UtilityFunctions::print("🚶 Positioning for patient access...");
    
    // Move device out of the way
    if (medicalDevice) {
        medicalDevice->swivelRight(90.0f);
    }
    
    // Lower bed for easy access
    setHeight(70.0f);
}

void SurgicalBed::positionForProcedure() {
    UtilityFunctions::print("🏥 Positioning for surgical procedure...");
    
    // Center device over patient
    centerDevice();
    
    // Set optimal surgical height
    setToSurgicalHeight();
}

// Surgical bed positioning
void SurgicalBed::setToSurgicalHeight() {
    float optimalHeight = 100.0f; // Optimal height for surgeon access
    setHeight(optimalHeight);
    UtilityFunctions::print("⚕️  Set to surgical height: ", optimalHeight, " cm");
}

void SurgicalBed::setToTransferHeight() {
    float transferHeight = 75.0f; // Height for patient transfer
    setHeight(transferHeight);
    UtilityFunctions::print("🏨 Set to transfer height: ", transferHeight, " cm");
}

void SurgicalBed::adjustForProcedure(const String& procedureType) {
    UtilityFunctions::print("⚙️  Adjusting bed configuration for: ", procedureType);
    
    std::string procedure = std::string(procedureType.utf8().get_data());
    
    if (procedure == "brain_surgery") {
        setHeight(110.0f);
        adjustLightingForProcedure();
    } else if (procedure == "cardiac_surgery") {
        setHeight(95.0f);
        adjustLightingForProcedure();
    } else if (procedure == "general_surgery") {
        setHeight(100.0f);
    } else {
        UtilityFunctions::print("Using default surgical configuration");
        setToSurgicalHeight();
    }
    
    adjustTemperatureForProcedure();
}

// Emergency procedures
void SurgicalBed::triggerSurgicalEmergency() {
    UtilityFunctions::print("🚨 SURGICAL EMERGENCY TRIGGERED!");
    
    // Activate emergency lighting
    triggerEmergency();
    
    // Activate emergency protocols
    activateEmergencyProtocols();
}

void SurgicalBed::activateEmergencyProtocols() {
    UtilityFunctions::print("🚨 Activating emergency protocols...");
    
    // Position for emergency access
    positionForPatientAccess();
    
    // Start continuous vital monitoring
    if (medicalDevice) {
        medicalDevice->startVitalMonitoring();
    }
    
    // Set emergency lighting
    if (lightStrip) {
        lightStrip->activateEmergencyMode();
    }
    
    UtilityFunctions::print("🚨 Emergency protocols active - all systems ready");
}

// DeviceObserver implementation
void SurgicalBed::onScanCompleted(const ScanData& data) {
    UtilityFunctions::print("📊 Scan completed on surgical bed: ", data.scanType.c_str());
    UtilityFunctions::print("📈 Scan quality: ", data.quality * 100, "%");
}

void SurgicalBed::onVitalSignsUpdated(const VitalSigns& vitals) {
    // Monitor for critical changes during procedures
    if (procedureInProgress) {
        if (vitals.oxygenLevel < 95.0f || vitals.heartRate > 110.0f) {
            UtilityFunctions::print("⚠️  ALERT: Vital signs require attention during procedure!");
        }
    }
}

void SurgicalBed::onDeviceError(const String& error) {
    UtilityFunctions::print("❌ Medical device error on surgical bed: ", error);
    
    if (procedureInProgress) {
        UtilityFunctions::print("🚨 Device error during procedure - consider emergency protocols");
    }
}

// Hook method implementations
void SurgicalBed::performSpecificChecks() {
    UtilityFunctions::print("Checking surgical systems...");
    
    // Check medical device
    bool deviceOK = medicalDevice != nullptr;
    UtilityFunctions::print("Medical device: ", deviceOK ? "OK" : "ERROR");
    
    // Check sterile mode capability
    UtilityFunctions::print("Sterile mode: ", sterileMode ? "ACTIVE" : "INACTIVE");
    
    // Check procedure status
    if (procedureInProgress) {
        UtilityFunctions::print("Active procedure: ", currentProcedure.c_str());
    }
    
    // Check positioning system
    bool positioningOK = isSurgicalPositioningValid();
    UtilityFunctions::print("Positioning system: ", positioningOK ? "OK" : "ERROR");
}

void SurgicalBed::onPowerOn() {
    UtilityFunctions::print("SurgicalBed advanced systems initializing...");
    
    // Initialize medical device
    if (medicalDevice) {
        UtilityFunctions::print("Medical scanner and monitoring system online");
    }
    
    // Set surgical defaults
    setHeight(85.0f);
    setTemperature(TemperatureControl::Mode::NEUTRAL);
    
    // Position device for standby
    centerDevice();
}

void SurgicalBed::onPowerOff() {
    UtilityFunctions::print("SurgicalBed systems shutting down...");
    
    // Safety checks before shutdown
    if (procedureInProgress) {
        UtilityFunctions::print("⚠️  WARNING: Procedure in progress during shutdown!");
        endProcedure();
    }
    
    if (medicalDevice) {
        medicalDevice->stopVitalMonitoring();
        medicalDevice->stopScan();
    }
    
    exitSterileMode();
}

void SurgicalBed::adjustLightingForProcedure() {
    if (lightStrip) {
        lightStrip->setBrightness(1.0f); // Maximum brightness for precision
        lightStrip->setColor(LightColor(255, 255, 255)); // Pure white light
    }
}

void SurgicalBed::adjustTemperatureForProcedure() {
    // Cool temperature for sterile surgical environment
    setTemperature(TemperatureControl::Mode::COLD);
}

void SurgicalBed::validateProcedureRequirements(const String& procedureType) {
    UtilityFunctions::print("✅ Validating requirements for: ", procedureType);
    
    // Check if bed is in sterile mode for surgery
    if (!sterileMode) {
        UtilityFunctions::print("⚠️  Recommendation: Activate sterile mode for surgery");
    }
    
    // Check height is appropriate
    if (!isSurgicalPositioningValid()) {
        UtilityFunctions::print("⚠️  Adjusting to optimal surgical height");
        setToSurgicalHeight();
    }
    
    UtilityFunctions::print("✅ Procedure requirements validated");
}

bool SurgicalBed::isSurgicalPositioningValid() const {
    return currentHeight >= minSurgicalHeight && currentHeight <= maxSurgicalHeight;
}

void SurgicalBed::_bind_methods() {
    // Bind methods from base Bed class that use pure virtual functions
    // These were not bound at the abstract class level to avoid Windows/MSVC registration issues
    ClassDB::bind_method(D_METHOD("power_on"), &SurgicalBed::powerOn);
    ClassDB::bind_method(D_METHOD("power_off"), &SurgicalBed::powerOff);
    ClassDB::bind_method(D_METHOD("trigger_emergency"), &SurgicalBed::triggerEmergency);
    ClassDB::bind_method(D_METHOD("clear_emergency"), &SurgicalBed::clearEmergency);
    ClassDB::bind_method(D_METHOD("perform_maintenance_check"), &SurgicalBed::performMaintenanceCheck);
    
    // Bind SurgicalBed specific methods
    ClassDB::bind_method(D_METHOD("enter_sterile_mode"), &SurgicalBed::enterSterileMode);
    ClassDB::bind_method(D_METHOD("exit_sterile_mode"), &SurgicalBed::exitSterileMode);
    ClassDB::bind_method(D_METHOD("is_sterile_mode"), &SurgicalBed::isSterileMode);
    ClassDB::bind_method(D_METHOD("start_procedure", "procedure_type"), &SurgicalBed::startProcedure);
    ClassDB::bind_method(D_METHOD("end_procedure"), &SurgicalBed::endProcedure);
    ClassDB::bind_method(D_METHOD("is_procedure_active"), &SurgicalBed::isProcedureActive);
    ClassDB::bind_method(D_METHOD("start_full_body_scan"), &SurgicalBed::startFullBodyScan);
    ClassDB::bind_method(D_METHOD("start_brain_scan"), &SurgicalBed::startBrainScan);
    ClassDB::bind_method(D_METHOD("stop_scanning"), &SurgicalBed::stopScanning);
    ClassDB::bind_method(D_METHOD("start_vital_monitoring"), &SurgicalBed::startVitalMonitoring);
    ClassDB::bind_method(D_METHOD("stop_vital_monitoring"), &SurgicalBed::stopVitalMonitoring);
    ClassDB::bind_method(D_METHOD("update_patient_vitals"), &SurgicalBed::updatePatientVitals);
    ClassDB::bind_method(D_METHOD("swivel_device_left", "angle"), &SurgicalBed::swivelDeviceLeft);
    ClassDB::bind_method(D_METHOD("swivel_device_right", "angle"), &SurgicalBed::swivelDeviceRight);
    ClassDB::bind_method(D_METHOD("center_device"), &SurgicalBed::centerDevice);
    ClassDB::bind_method(D_METHOD("position_for_patient_access"), &SurgicalBed::positionForPatientAccess);
    ClassDB::bind_method(D_METHOD("position_for_procedure"), &SurgicalBed::positionForProcedure);
    ClassDB::bind_method(D_METHOD("set_to_surgical_height"), &SurgicalBed::setToSurgicalHeight);
    ClassDB::bind_method(D_METHOD("trigger_surgical_emergency"), &SurgicalBed::triggerSurgicalEmergency);
}