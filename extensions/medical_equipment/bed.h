#ifndef BED_H
#define BED_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "light_strip.h"
#include <memory>

using namespace godot;

// Strategy Pattern for Temperature Control
class TemperatureControl {
public:
    enum class Mode { COLD, NEUTRAL, WARM };
    
    virtual ~TemperatureControl() = default;
    virtual void setTemperature(Mode mode) = 0;
    virtual Mode getCurrentTemperature() const = 0;
    virtual float getTemperatureValue() const = 0;
};

class StandardTemperatureControl : public TemperatureControl {
private:
    Mode currentMode;
    float temperature; // Celsius
    
public:
    StandardTemperatureControl() : currentMode(Mode::NEUTRAL), temperature(22.0f) {}
    
    void setTemperature(Mode mode) override {
        currentMode = mode;
        switch (mode) {
            case Mode::COLD:
                temperature = 18.0f;
                UtilityFunctions::print("Temperature set to COLD (18°C)");
                break;
            case Mode::NEUTRAL:
                temperature = 22.0f;
                UtilityFunctions::print("Temperature set to NEUTRAL (22°C)");
                break;
            case Mode::WARM:
                temperature = 26.0f;
                UtilityFunctions::print("Temperature set to WARM (26°C)");
                break;
        }
    }
    
    Mode getCurrentTemperature() const override { return currentMode; }
    float getTemperatureValue() const override { return temperature; }
};

// Template Method Pattern - Base Bed Class
class Bed : public Node, public EmergencyObserver {
    GDCLASS(Bed, Node)

public:
    // Temperature control constants for GDScript binding
    static const int TEMPERATURE_COLD = 0;
    static const int TEMPERATURE_NEUTRAL = 1;
    static const int TEMPERATURE_WARM = 2;

protected:
    std::unique_ptr<LightStrip> lightStrip;
    std::unique_ptr<TemperatureControl> temperatureControl;
    float currentHeight; // in cm
    float minHeight;
    float maxHeight;
    bool isPoweredOn;

public:
    Bed();
    virtual ~Bed() = default;

    // Template Method - defines the algorithm structure
    void performMaintenanceCheck() {
        UtilityFunctions::print("Starting maintenance check for ", getClassName().c_str());
        checkPowerSystem();
        checkHeightMechanism();
        checkLightSystem();
        checkTemperatureSystem();
        performSpecificChecks(); // Hook method for subclasses
        UtilityFunctions::print("Maintenance check completed for ", getClassName().c_str());
    }

    // Common operations for all beds
    virtual void powerOn();
    virtual void powerOff();
    
    // Height control
    void raiseHeight(float amount);
    void lowerHeight(float amount);
    void setHeight(float height);
    float getHeight() const { return currentHeight; }
    
    // Light control
    void activateLights();
    void deactivateLights();
    void setLightBrightness(float intensity);
    void setLightColor(const LightColor& color);
    void triggerEmergency();
    void clearEmergency();
    
    // Temperature control
    void setTemperature(TemperatureControl::Mode mode);
    void setTemperature(int mode); // GDScript wrapper
    TemperatureControl::Mode getCurrentTemperature() const;
    float getTemperatureValue() const;
    
    // Observer pattern implementation
    void onEmergencyActivated() override;
    void onEmergencyDeactivated() override;
    
    // Pure virtual method - must be implemented by subclasses
    virtual std::string getClassName() const = 0;

protected:
    // Hook methods for subclasses to override
    virtual void performSpecificChecks() {} // Empty default implementation
    virtual void onPowerOn() {} // Called when powered on
    virtual void onPowerOff() {} // Called when powered off
    
    // Template method steps
    virtual void checkPowerSystem();
    virtual void checkHeightMechanism();
    virtual void checkLightSystem();
    virtual void checkTemperatureSystem();
    
    static void _bind_methods();

private:
    void initializeComponents();
    bool validateHeightRange(float height) const;
};

#endif // BED_H