#ifndef MEDICAL_DEVICES_H
#define MEDICAL_DEVICES_H

#include <godot_cpp/variant/utility_functions.hpp>
#include <memory>
#include <map>
#include <string>

using namespace godot;

// Medical data structures
struct VitalSigns {
    float oxygenLevel;      // %
    float heartRate;        // BPM
    float bloodPressure;    // mmHg
    float temperature;      // °C
    float respirationRate;  // per minute
    
    VitalSigns() : oxygenLevel(98.0f), heartRate(75.0f), bloodPressure(120.0f), 
                   temperature(37.0f), respirationRate(16.0f) {}
};

struct ScanData {
    std::string scanType;
    std::string imageData;
    float quality;
    bool isValid;
    
    ScanData(const std::string& type = "full_body") 
        : scanType(type), imageData(""), quality(0.95f), isValid(true) {}
};

// Observer pattern for device monitoring
class DeviceObserver {
public:
    virtual ~DeviceObserver() = default;
    virtual void onScanCompleted(const ScanData& data) = 0;
    virtual void onVitalSignsUpdated(const VitalSigns& vitals) = 0;
    virtual void onDeviceError(const String& error) = 0;
};

// Scanner component using State pattern
class Scanner {
public:
    enum class ScanType { FULL_BODY, BRAIN, HEART, LUNGS };
    enum class ScanState { IDLE, SCANNING, PROCESSING, COMPLETE, ERROR };

private:
    ScanState currentState;
    ScanType currentScanType;
    float scanProgress;
    std::vector<DeviceObserver*> observers;
    ScanData currentScan;

public:
    Scanner() : currentState(ScanState::IDLE), currentScanType(ScanType::FULL_BODY), scanProgress(0.0f) {}
    
    void startScan(ScanType type) {
        if (currentState != ScanState::IDLE) {
            UtilityFunctions::print("❌ Cannot start scan - scanner busy");
            return;
        }
        
        currentScanType = type;
        currentState = ScanState::SCANNING;
        scanProgress = 0.0f;
        
        std::string scanTypeName = getScanTypeName(type);
        currentScan = scanTypeName;
        UtilityFunctions::print("🔍 Starting ", scanTypeName.c_str(), " scan...");
        
        // Simulate scan process
        processScan();
    }
    
    void stopScan() {
        if (currentState == ScanState::SCANNING || currentState == ScanState::PROCESSING) {
            currentState = ScanState::IDLE;
            scanProgress = 0.0f;
            UtilityFunctions::print("🛑 Scan stopped");
        }
    }
    
    ScanState getState() const { return currentState; }
    float getProgress() const { return scanProgress; }
    ScanType getCurrentScanType() const { return currentScanType; }
    
    void addObserver(DeviceObserver* observer) {
        observers.push_back(observer);
    }
    
    void removeObserver(DeviceObserver* observer) {
        observers.erase(
            std::remove(observers.begin(), observers.end(), observer),
            observers.end()
        );
    }

private:
    void processScan() {
        currentState = ScanState::PROCESSING;
        
        // Simulate scan processing
        for (int i = 0; i <= 100; i += 20) {
            scanProgress = i / 100.0f;
            UtilityFunctions::print("Scan progress: ", i, "%");
        }
        
        // Create scan data
        currentScan = ScanData(getScanTypeName(currentScanType));
        currentScan.imageData = "scan_image_" + getScanTypeName(currentScanType) + "_data";
        
        currentState = ScanState::COMPLETE;
        UtilityFunctions::print("✅ Scan completed successfully");
        
        // Notify observers
        for (auto* observer : observers) {
            if (observer) {
                observer->onScanCompleted(currentScan);
            }
        }
        
        currentState = ScanState::IDLE;
    }
    
    std::string getScanTypeName(ScanType type) const {
        switch (type) {
            case ScanType::FULL_BODY: return "full_body";
            case ScanType::BRAIN: return "brain";
            case ScanType::HEART: return "heart";
            case ScanType::LUNGS: return "lungs";
            default: return "unknown";
        }
    }
};

// Vital Signs Monitor
class VitalSignMonitor {
private:
    VitalSigns currentVitals;
    bool isMonitoring;
    std::vector<DeviceObserver*> observers;
    // Note: updateInterval and lastUpdateTime removed as they were unused

public:
    VitalSignMonitor() : isMonitoring(false) {}
    
    void startMonitoring() {
        if (!isMonitoring) {
            isMonitoring = true;
            UtilityFunctions::print("💓 Vital signs monitoring started");
            updateVitalSigns();
        }
    }
    
    void stopMonitoring() {
        if (isMonitoring) {
            isMonitoring = false;
            UtilityFunctions::print("⏹️  Vital signs monitoring stopped");
        }
    }
    
    void simulateVitalSigns() {
        if (!isMonitoring) return;
        
        // Simulate realistic vital signs with small variations
        currentVitals.heartRate += (rand() % 10 - 5);        // ±5 BPM
        currentVitals.oxygenLevel += (rand() % 4 - 2) * 0.1f; // ±0.2%
        currentVitals.bloodPressure += (rand() % 6 - 3);     // ±3 mmHg
        currentVitals.temperature += (rand() % 2 - 1) * 0.1f; // ±0.1°C
        currentVitals.respirationRate += (rand() % 4 - 2);    // ±2 per min
        
        // Ensure values stay in normal ranges
        currentVitals.heartRate = std::max(60.0f, std::min(100.0f, currentVitals.heartRate));
        currentVitals.oxygenLevel = std::max(95.0f, std::min(100.0f, currentVitals.oxygenLevel));
        currentVitals.bloodPressure = std::max(110.0f, std::min(140.0f, currentVitals.bloodPressure));
        currentVitals.temperature = std::max(36.5f, std::min(37.5f, currentVitals.temperature));
        currentVitals.respirationRate = std::max(12.0f, std::min(20.0f, currentVitals.respirationRate));
        
        updateVitalSigns();
    }
    
    VitalSigns getCurrentVitals() const { return currentVitals; }
    bool getMonitoringStatus() const { return isMonitoring; }
    
    void addObserver(DeviceObserver* observer) {
        observers.push_back(observer);
    }
    
    void removeObserver(DeviceObserver* observer) {
        observers.erase(
            std::remove(observers.begin(), observers.end(), observer),
            observers.end()
        );
    }

private:
    void updateVitalSigns() {
        UtilityFunctions::print("💓 Vitals: HR=", currentVitals.heartRate, 
                              " O2=", currentVitals.oxygenLevel, "%",
                              " BP=", currentVitals.bloodPressure,
                              " Temp=", currentVitals.temperature, "°C");
        
        // Notify observers
        for (auto* observer : observers) {
            if (observer) {
                observer->onVitalSignsUpdated(currentVitals);
            }
        }
    }
};

// Composite pattern - Combines Scanner and Monitor into one device
class ScannerDevice : public DeviceObserver {
private:
    std::unique_ptr<Scanner> scanner;
    std::unique_ptr<VitalSignMonitor> vitalMonitor;
    bool canSwivel;
    float swivelAngle; // degrees from center
    std::map<std::string, ScanData> storedScans;
    VitalSigns lastVitals;

public:
    ScannerDevice() : canSwivel(true), swivelAngle(0.0f) {
        scanner = std::make_unique<Scanner>();
        vitalMonitor = std::make_unique<VitalSignMonitor>();
        
        // Register as observer for both components
        scanner->addObserver(this);
        vitalMonitor->addObserver(this);
        
        UtilityFunctions::print("🏥 Medical scanner device initialized");
    }
    
    // Scanner operations
    void startFullBodyScan() { scanner->startScan(Scanner::ScanType::FULL_BODY); }
    void startBrainScan() { scanner->startScan(Scanner::ScanType::BRAIN); }
    void stopScan() { scanner->stopScan(); }
    
    // Vital signs operations
    void startVitalMonitoring() { vitalMonitor->startMonitoring(); }
    void stopVitalMonitoring() { vitalMonitor->stopMonitoring(); }
    void updateVitals() { vitalMonitor->simulateVitalSigns(); }
    
    // Swivel functionality
    void swivelLeft(float angle = 45.0f) {
        if (canSwivel) {
            swivelAngle = std::max(-90.0f, swivelAngle - angle);
            UtilityFunctions::print("🔄 Device swiveled left to ", swivelAngle, "°");
        }
    }
    
    void swivelRight(float angle = 45.0f) {
        if (canSwivel) {
            swivelAngle = std::min(90.0f, swivelAngle + angle);
            UtilityFunctions::print("🔄 Device swiveled right to ", swivelAngle, "°");
        }
    }
    
    void centerDevice() {
        swivelAngle = 0.0f;
        UtilityFunctions::print("📍 Device centered");
    }
    
    // Device status
    float getSwivelAngle() const { return swivelAngle; }
    bool isScannerBusy() const { return scanner->getState() != Scanner::ScanState::IDLE; }
    bool isMonitoringVitals() const { return vitalMonitor->getMonitoringStatus(); }
    VitalSigns getLastVitals() const { return lastVitals; }
    
    // DeviceObserver implementation
    void onScanCompleted(const ScanData& data) override {
        UtilityFunctions::print("📊 Scan completed: ", data.scanType.c_str());
        storedScans[data.scanType] = data;
    }
    
    void onVitalSignsUpdated(const VitalSigns& vitals) override {
        lastVitals = vitals;
        // Check for critical values
        checkCriticalVitals(vitals);
    }
    
    void onDeviceError(const String& error) override {
        UtilityFunctions::print("❌ ScannerDevice error: ", error);
    }

private:
    void checkCriticalVitals(const VitalSigns& vitals) {
        bool critical = false;
        
        if (vitals.oxygenLevel < 90.0f) {
            UtilityFunctions::print("🚨 CRITICAL: Low oxygen level!");
            critical = true;
        }
        
        if (vitals.heartRate < 50.0f || vitals.heartRate > 120.0f) {
            UtilityFunctions::print("🚨 CRITICAL: Abnormal heart rate!");
            critical = true;
        }
        
        if (vitals.temperature > 38.5f || vitals.temperature < 36.0f) {
            UtilityFunctions::print("⚠️  WARNING: Abnormal temperature!");
        }
        
        // Log critical status for monitoring purposes
        if (critical) {
            UtilityFunctions::print("🚨 CRITICAL STATUS: Patient requires immediate attention!");
        }
    }
};

#endif // MEDICAL_DEVICES_H