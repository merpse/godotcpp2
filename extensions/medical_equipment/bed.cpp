#include "bed.h"
#include <godot_cpp/core/class_db.hpp>
#include <algorithm>

using namespace godot;

Bed::Bed() : currentHeight(50.0f), minHeight(30.0f), maxHeight(100.0f), isPoweredOn(false) {
    initializeComponents();
}

void Bed::initializeComponents() {
    lightStrip = std::make_unique<LightStrip>();
    temperatureControl = std::make_unique<StandardTemperatureControl>();
    
    // Register this bed as an observer for emergency events
    if (lightStrip) {
        lightStrip->addObserver(this);
    }
}

void Bed::powerOn() {
    if (!isPoweredOn) {
        isPoweredOn = true;
        UtilityFunctions::print(getClassName().c_str(), " powered ON");
        
        // Initialize default settings
        temperatureControl->setTemperature(TemperatureControl::Mode::NEUTRAL);
        lightStrip->activate();
        
        onPowerOn(); // Hook for subclasses
    }
}

void Bed::powerOff() {
    if (isPoweredOn) {
        isPoweredOn = false;
        UtilityFunctions::print(getClassName().c_str(), " powered OFF");
        
        if (lightStrip) {
            lightStrip->deactivate();
        }
        
        onPowerOff(); // Hook for subclasses
    }
}

void Bed::raiseHeight(float amount) {
    if (!isPoweredOn) {
        UtilityFunctions::print("Cannot adjust height - bed is powered off");
        return;
    }
    
    float newHeight = currentHeight + amount;
    if (validateHeightRange(newHeight)) {
        currentHeight = newHeight;
        UtilityFunctions::print("Height raised to ", currentHeight, " cm");
    } else {
        UtilityFunctions::print("Cannot raise height - would exceed maximum (", maxHeight, " cm)");
    }
}

void Bed::lowerHeight(float amount) {
    if (!isPoweredOn) {
        UtilityFunctions::print("Cannot adjust height - bed is powered off");
        return;
    }
    
    float newHeight = currentHeight - amount;
    if (validateHeightRange(newHeight)) {
        currentHeight = newHeight;
        UtilityFunctions::print("Height lowered to ", currentHeight, " cm");
    } else {
        UtilityFunctions::print("Cannot lower height - would go below minimum (", minHeight, " cm)");
    }
}

void Bed::setHeight(float height) {
    if (!isPoweredOn) {
        UtilityFunctions::print("Cannot set height - bed is powered off");
        return;
    }
    
    if (validateHeightRange(height)) {
        currentHeight = height;
        UtilityFunctions::print("Height set to ", currentHeight, " cm");
    } else {
        UtilityFunctions::print("Invalid height. Range: ", minHeight, " - ", maxHeight, " cm");
    }
}

void Bed::activateLights() {
    if (lightStrip) {
        lightStrip->activate();
    }
}

void Bed::deactivateLights() {
    if (lightStrip) {
        lightStrip->deactivate();
    }
}

void Bed::setLightBrightness(float intensity) {
    if (lightStrip) {
        lightStrip->setBrightness(intensity);
    }
}

void Bed::setLightColor(const LightColor& color) {
    if (lightStrip) {
        lightStrip->setColor(color);
    }
}

void Bed::triggerEmergency() {
    UtilityFunctions::print("🚨 EMERGENCY TRIGGERED on ", getClassName().c_str());
    if (lightStrip) {
        lightStrip->activateEmergencyMode();
    }
}

void Bed::clearEmergency() {
    UtilityFunctions::print("Emergency cleared on ", getClassName().c_str());
    if (lightStrip) {
        lightStrip->deactivateEmergencyMode();
    }
}

void Bed::setTemperature(TemperatureControl::Mode mode) {
    if (!isPoweredOn) {
        UtilityFunctions::print("Cannot set temperature - bed is powered off");
        return;
    }
    
    if (temperatureControl) {
        temperatureControl->setTemperature(mode);
    }
}

// GDScript wrapper method for temperature control
void Bed::setTemperature(int mode) {
    TemperatureControl::Mode tempMode;
    switch (mode) {
        case TEMPERATURE_COLD:
            tempMode = TemperatureControl::Mode::COLD;
            break;
        case TEMPERATURE_WARM:
            tempMode = TemperatureControl::Mode::WARM;
            break;
        case TEMPERATURE_NEUTRAL:
        default:
            tempMode = TemperatureControl::Mode::NEUTRAL;
            break;
    }
    setTemperature(tempMode);
}

TemperatureControl::Mode Bed::getCurrentTemperature() const {
    return temperatureControl ? temperatureControl->getCurrentTemperature() : TemperatureControl::Mode::NEUTRAL;
}

float Bed::getTemperatureValue() const {
    return temperatureControl ? temperatureControl->getTemperatureValue() : 22.0f;
}

// Observer pattern implementation
void Bed::onEmergencyActivated() {
    UtilityFunctions::print("🚨 ", getClassName().c_str(), " responding to emergency activation");
    // Additional emergency response can be added here
}

void Bed::onEmergencyDeactivated() {
    UtilityFunctions::print("✅ ", getClassName().c_str(), " emergency response deactivated");
}

// Template method implementation
void Bed::checkPowerSystem() {
    UtilityFunctions::print("Checking power system... ", isPoweredOn ? "OK" : "OFF");
}

void Bed::checkHeightMechanism() {
    bool heightOK = currentHeight >= minHeight && currentHeight <= maxHeight;
    UtilityFunctions::print("Checking height mechanism... ", heightOK ? "OK" : "ERROR");
}

void Bed::checkLightSystem() {
    bool lightOK = lightStrip != nullptr;
    UtilityFunctions::print("Checking light system... ", lightOK ? "OK" : "ERROR");
}

void Bed::checkTemperatureSystem() {
    bool tempOK = temperatureControl != nullptr;
    UtilityFunctions::print("Checking temperature system... ", tempOK ? "OK" : "ERROR");
}

bool Bed::validateHeightRange(float height) const {
    return height >= minHeight && height <= maxHeight;
}

void Bed::_bind_methods() {
    // Bind common bed methods to Godot
    ClassDB::bind_method(D_METHOD("power_on"), &Bed::powerOn);
    ClassDB::bind_method(D_METHOD("power_off"), &Bed::powerOff);
    ClassDB::bind_method(D_METHOD("raise_height", "amount"), &Bed::raiseHeight);
    ClassDB::bind_method(D_METHOD("lower_height", "amount"), &Bed::lowerHeight);
    ClassDB::bind_method(D_METHOD("set_height", "height"), &Bed::setHeight);
    ClassDB::bind_method(D_METHOD("get_height"), &Bed::getHeight);
    ClassDB::bind_method(D_METHOD("activate_lights"), &Bed::activateLights);
    ClassDB::bind_method(D_METHOD("deactivate_lights"), &Bed::deactivateLights);
    ClassDB::bind_method(D_METHOD("set_light_brightness", "intensity"), &Bed::setLightBrightness);
    ClassDB::bind_method(D_METHOD("set_temperature", "mode"), static_cast<void (Bed::*)(int)>(&Bed::setTemperature));
    ClassDB::bind_method(D_METHOD("trigger_emergency"), &Bed::triggerEmergency);
    ClassDB::bind_method(D_METHOD("clear_emergency"), &Bed::clearEmergency);
    ClassDB::bind_method(D_METHOD("perform_maintenance_check"), &Bed::performMaintenanceCheck);
    ClassDB::bind_method(D_METHOD("get_temperature_value"), &Bed::getTemperatureValue);
    
    // Temperature control constants
    BIND_CONSTANT(TEMPERATURE_COLD);
    BIND_CONSTANT(TEMPERATURE_NEUTRAL);
    BIND_CONSTANT(TEMPERATURE_WARM);
}