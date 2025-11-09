#ifndef BED_TEST_MOCK_H
#define BED_TEST_MOCK_H

// Mock bed classes for testing without Godot dependencies
#include <string>
#include <memory>
#include <ctime>
#include <algorithm>

// Mock base classes needed for testing
class MockNode {
public:
    MockNode() = default;
    virtual ~MockNode() = default;
    virtual void _ready() {}
    static void _bind_methods() {}
    
    std::string get_name() const { return "MockNode"; }
    void set_name(const std::string& name) { node_name = name; }
    
private:
    std::string node_name;
};

// Mock utility functions
class MockUtilityFunctions {
public:
    static void print(const std::string& message) {
        // Silent for testing or could log to test output
    }
};

// Mock observer interface
class EmergencyObserver {
public:
    virtual ~EmergencyObserver() = default;
    virtual void onEmergencyActivated() = 0;
    virtual void onEmergencyDeactivated() = 0;
};

// Temperature control mock
namespace TemperatureControl {
    enum Mode {
        COLD = 0,
        NEUTRAL = 1,
        WARM = 2
    };
}

// Mock bed class that provides the interface needed for testing
class TestBed : public MockNode, public EmergencyObserver {
public:
    // Temperature control constants for testing
    static const int TEMPERATURE_COLD = 0;
    static const int TEMPERATURE_NEUTRAL = 1;
    static const int TEMPERATURE_WARM = 2;

protected:
    float currentHeight = 60.0f;
    float minHeight = 40.0f;
    float maxHeight = 120.0f;
    bool isPoweredOn = false;

public:
    // Test tracking flags
    mutable bool checks_performed = false;
    mutable bool power_on_called = false;
    mutable bool power_off_called = false;
    
    TestBed() = default;
    virtual ~TestBed() = default;

    // Core bed operations for testing
    virtual void powerOn() { 
        isPoweredOn = true; 
        power_on_called = true;
    }
    virtual void powerOff() { 
        isPoweredOn = false; 
        power_off_called = true;
    }
    
    bool isPowered() const { return isPoweredOn; }
    bool isOperational() const { return isPowered(); } // Mock operational status
    
    // Add performChecks method that sets the flag
    virtual void performChecks() { 
        checks_performed = true;
    }
    
    virtual void performSpecificChecks() { 
        checks_performed = true;
    }
    
    virtual std::string getClassName() const { return "TestBed"; }
    
    // Height control
    void raiseHeight(float amount) {
        if (isPoweredOn && currentHeight + amount <= maxHeight) {
            currentHeight += amount;
        }
    }
    
    void lowerHeight(float amount) {
        if (isPoweredOn && currentHeight - amount >= minHeight) {
            currentHeight -= amount;
        }
    }
    
    void setHeight(float height) {
        if (isPoweredOn && height >= minHeight && height <= maxHeight) {
            currentHeight = height;
        }
    }
    
    float getHeight() const { return currentHeight; }
    
    // Light control
    void activateLights() { /* Mock implementation */ }
    void deactivateLights() { /* Mock implementation */ }
    void setLightBrightness(float intensity) { /* Mock implementation */ }
    
    // Temperature control
    void setTemperature(int mode) { 
        if (isPoweredOn) {
            current_temperature_mode = mode;
        }
    }
    
    void setTemperature(TemperatureControl::Mode mode) {
        setTemperature(static_cast<int>(mode));
    }
    
    TemperatureControl::Mode getCurrentTemperature() const {
        return static_cast<TemperatureControl::Mode>(current_temperature_mode);
    }
    
    float getTemperatureValue() const { 
        switch (current_temperature_mode) {
            case TEMPERATURE_COLD: return 18.0f;
            case TEMPERATURE_WARM: return 26.0f;
            default: return 22.0f;
        }
    }
    
    // Emergency handling
    void triggerEmergency() { emergency_active = true; }
    void clearEmergency() { emergency_active = false; }
    
    // Maintenance
    void performMaintenanceCheck() {
        MockUtilityFunctions::print("Maintenance check for " + getClassName());
    }
    
    // Observer pattern implementation
    void onEmergencyActivated() override {
        MockUtilityFunctions::print(getClassName() + " responding to emergency activation");
    }
    
    void onEmergencyDeactivated() override {
        MockUtilityFunctions::print(getClassName() + " responding to emergency deactivation");
    }

protected:
    int current_temperature_mode = TEMPERATURE_NEUTRAL;
    bool emergency_active = false;
    
    // Validation methods
    bool validateHeightRange(float height) const {
        return height >= minHeight && height <= maxHeight;
    }
    
    // Hook methods for subclasses (note: performSpecificChecks already defined above)
    virtual void onPowerOn() {}
    virtual void onPowerOff() {}
    virtual void checkPowerSystem() {}
    virtual void checkHeightMechanism() {}
    virtual void checkLightSystem() {}
    virtual void checkTemperatureSystem() {}
};

// Mock patient bed
class MockPatientBed : public TestBed {
public:
    MockPatientBed() {
        currentHeight = 75.0f; // Default patient bed height
        minHeight = 60.0f;
        maxHeight = 90.0f;
    }
    
    std::string getClassName() const override { return "PatientBed"; }
    
    // Patient-specific functionality
    bool isOccupied() const { return occupied; }
    void setOccupied(bool state) { occupied = state; }
    void setComfortMode(bool enabled) { comfort_mode = enabled; }
    bool isComfortMode() const { return comfort_mode; }
    
    // Additional patient methods
    void adjustForPatientComfort() { /* Mock implementation */ }
    void startVitalMonitoring() { vital_monitoring = true; }
    void stopVitalMonitoring() { vital_monitoring = false; }
    bool isVitalMonitoring() const { return vital_monitoring; }

protected:
    bool occupied = false;
    bool comfort_mode = false;
    bool vital_monitoring = false;
    
    void performSpecificChecks() override {
        MockUtilityFunctions::print("Patient bed specific checks completed");
    }
};

// Mock surgical bed
class MockSurgicalBed : public TestBed {
public:
    MockSurgicalBed() {
        currentHeight = 85.0f; // Default surgical bed height
        minHeight = 70.0f;
        maxHeight = 120.0f;
    }
    
    std::string getClassName() const override { return "SurgicalBed"; }
    
    // Surgical-specific methods
    void enterSterileMode() { sterile_mode = true; }
    void exitSterileMode() { sterile_mode = false; }
    bool isSterileMode() const { return sterile_mode; }
    
    void startProcedure(const std::string& procedure_type) {
        if (sterile_mode) {
            current_procedure = procedure_type;
            procedure_active = true;
        }
    }
    
    void endProcedure() {
        current_procedure.clear();
        procedure_active = false;
    }
    
    bool isProcedureActive() const { return procedure_active; }
    
    // Medical device integration methods
    void startFullBodyScan() { scanning_active = true; }
    void stopScanning() { scanning_active = false; }
    void startVitalMonitoring() { vital_monitoring = true; }
    void stopVitalMonitoring() { vital_monitoring = false; }
    void centerDevice() { device_centered = true; }
    
    // Surgical emergency handling
    void triggerSurgicalEmergency() { surgical_emergency_active = true; }
    
    // Mouse collision detection methods
    void simulateMouseEnter() { 
        mouse_hovering = true; 
        collision_detected = true;
        hover_start_time = std::time(nullptr);
    }
    
    void simulateMouseExit() { 
        mouse_hovering = false; 
        collision_detected = false;
        hover_duration = std::time(nullptr) - hover_start_time;
    }
    
    void simulateMouseClick() { 
        if (mouse_hovering) {
            click_count++;
            last_click_time = std::time(nullptr);
        }
    }
    
    // Collision detection query methods
    bool isMouseHovering() const { return mouse_hovering; }
    bool isCollisionDetected() const { return collision_detected; }
    int getClickCount() const { return click_count; }
    time_t getLastClickTime() const { return last_click_time; }
    double getHoverDuration() const { return hover_duration; }
    
    // Color state methods for visual feedback testing
    void setHighlightColor(const std::string& color) { current_highlight_color = color; }
    std::string getHighlightColor() const { return current_highlight_color; }
    bool isHighlighted() const { return mouse_hovering; }

protected:
    void performSpecificChecks() override {
        MockUtilityFunctions::print("Surgical bed specific checks completed");
    }

private:
    bool sterile_mode = false;
    bool procedure_active = false;
    std::string current_procedure;
    bool scanning_active = false;
    bool vital_monitoring = false;
    bool device_centered = false;
    bool surgical_emergency_active = false;
    
    // Collision detection state
    bool mouse_hovering = false;
    bool collision_detected = false;
    int click_count = 0;
    time_t last_click_time = 0;
    time_t hover_start_time = 0;
    double hover_duration = 0.0;
    std::string current_highlight_color = "white";
};

// Mock bed factory
class MockBedFactory {
public:
    enum class BedType {
        PATIENT = 0,
        SURGICAL = 1
    };
    
    static std::unique_ptr<TestBed> createBed(BedType type) {
        switch (type) {
            case BedType::PATIENT:
                return std::make_unique<MockPatientBed>();
            case BedType::SURGICAL:
                return std::make_unique<MockSurgicalBed>();
            default:
                return nullptr;
        }
    }
    
    static std::unique_ptr<TestBed> createBedFromString(const std::string& bedTypeName) {
        std::string lowerTypeName = bedTypeName;
        
        // Convert to lowercase for case-insensitive comparison
        std::transform(lowerTypeName.begin(), lowerTypeName.end(), lowerTypeName.begin(),
                       [](unsigned char c) { return std::tolower(c); });
        
        // Handle patient bed variations
        if (lowerTypeName == "patient_bed" || lowerTypeName == "patient" || 
            lowerTypeName == "patientbed" || lowerTypeName == "patient-bed") {
            return createBed(BedType::PATIENT);
        } 
        // Handle surgical bed variations  
        else if (lowerTypeName == "surgical_bed" || lowerTypeName == "surgical" || 
                 lowerTypeName == "surgicalbed" || lowerTypeName == "surgical-bed" ||
                 lowerTypeName == "surgery") {
            return createBed(BedType::SURGICAL);
        }
        return nullptr;
    }
    
    static std::vector<std::string> getAvailableBedTypes() {
        return {"patient_bed", "surgical_bed"};
    }
    
    static std::unique_ptr<MockPatientBed> createPatientBed() {
        return std::make_unique<MockPatientBed>();
    }
    
    static std::unique_ptr<MockSurgicalBed> createSurgicalBed() {
        return std::make_unique<MockSurgicalBed>();
    }
};

#endif // BED_TEST_MOCK_H