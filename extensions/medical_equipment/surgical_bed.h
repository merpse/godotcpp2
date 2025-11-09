#ifndef SURGICAL_BED_H
#define SURGICAL_BED_H

#include "bed.h"
#include "medical_devices.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <memory>

using namespace godot;

// Surgical bed specific features
class SurgicalBed : public Bed, public DeviceObserver {
    GDCLASS(SurgicalBed, Bed)

private:
    std::unique_ptr<ScannerDevice> medicalDevice;
    bool sterileMode;
    bool procedureInProgress;
    float maxSurgicalHeight;
    float minSurgicalHeight;
    std::string currentProcedure;

public:
    SurgicalBed();
    virtual ~SurgicalBed() = default;

    // Override base class methods
    std::string getClassName() const override;
    
    // Surgical bed specific functionality
    void enterSterileMode();
    void exitSterileMode();
    bool isSterileMode() const { return sterileMode; }
    
    void startProcedure(const String& procedureType);
    void endProcedure();
    bool isProcedureActive() const { return procedureInProgress; }
    std::string getCurrentProcedure() const { return currentProcedure; }
    
    // Medical device operations
    void startFullBodyScan();
    void startBrainScan();
    void stopScanning();
    void startVitalMonitoring();
    void stopVitalMonitoring();
    void updatePatientVitals();
    
    // Device positioning
    void swivelDeviceLeft(float angle = 45.0f);
    void swivelDeviceRight(float angle = 45.0f);
    void centerDevice();
    void positionForPatientAccess();
    void positionForProcedure();
    
    // Surgical bed positioning
    void setToSurgicalHeight();
    void setToTransferHeight();
    
    // Emergency procedures
    void triggerSurgicalEmergency();
    void activateEmergencyProtocols();
    
    // DeviceObserver implementation
    void onScanCompleted(const ScanData& data) override;
    void onVitalSignsUpdated(const VitalSigns& vitals) override;
    void onDeviceError(const String& error) override;

protected:
    // Override hook methods from base class
    void performSpecificChecks() override;
    void onPowerOn() override;
    void onPowerOff() override;
    
    static void _bind_methods();

private:
    void initializeSurgicalSystems();
    void setupSterileEnvironment();
    void adjustForProcedure(const String& procedureType);
    void validateProcedureRequirements(const String& procedureType);
    void adjustLightingForProcedure();
    void adjustTemperatureForProcedure();
    bool isSurgicalPositioningValid() const;
};

#endif // SURGICAL_BED_H