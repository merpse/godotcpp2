#ifndef LIGHT_STRIP_H
#define LIGHT_STRIP_H

#include <godot_cpp/variant/utility_functions.hpp>
#include <memory>

using namespace godot;

// Color structure for RGB values
struct LightColor {
    int red, green, blue;
    LightColor(int r = 255, int g = 255, int b = 255) : red(r), green(g), blue(b) {}
};

// Strategy Pattern Interface for Light Behaviors
class LightBehavior {
public:
    virtual ~LightBehavior() = default;
    virtual void activate() = 0;
    virtual void deactivate() = 0;
    virtual void setBrightness(float intensity) = 0;
    virtual void setColor(const LightColor& color) = 0;
    virtual bool isEmergencyMode() const = 0;
    virtual std::string getBehaviorType() const = 0;
};

// Concrete Light Behaviors
class NormalLightBehavior : public LightBehavior {
private:
    float brightness;
    LightColor currentColor;
    bool isActive;

public:
    NormalLightBehavior() : brightness(0.5f), currentColor(255, 255, 255), isActive(false) {}
    
    void activate() override {
        isActive = true;
        UtilityFunctions::print("Normal lights activated");
    }
    
    void deactivate() override {
        isActive = false;
        UtilityFunctions::print("Normal lights deactivated - gentle glow mode");
    }
    
    void setBrightness(float intensity) override {
        brightness = std::max(0.0f, std::min(1.0f, intensity));
        UtilityFunctions::print("Brightness set to: ", brightness);
    }
    
    void setColor(const LightColor& color) override {
        currentColor = color;
        UtilityFunctions::print("Color set to RGB(", color.red, ",", color.green, ",", color.blue, ")");
    }
    
    bool isEmergencyMode() const override { return false; }
    std::string getBehaviorType() const override { return "Normal"; }
};

class EmergencyLightBehavior : public LightBehavior {
private:
    bool isBlinking;
    bool isActive;

public:
    EmergencyLightBehavior() : isBlinking(false), isActive(false) {}
    
    void activate() override {
        isActive = true;
        isBlinking = true;
        UtilityFunctions::print("🚨 EMERGENCY LIGHTS ACTIVATED - RED BLINKING!");
    }
    
    void deactivate() override {
        isActive = false;
        isBlinking = false;
        UtilityFunctions::print("Emergency lights deactivated");
    }
    
    void setBrightness(float intensity) override {
        UtilityFunctions::print("Emergency mode - brightness locked to maximum");
    }
    
    void setColor(const LightColor& color) override {
        UtilityFunctions::print("Emergency mode - color locked to red");
    }
    
    bool isEmergencyMode() const override { return true; }
    std::string getBehaviorType() const override { return "Emergency"; }
};

// Observer Pattern Interface for Emergency Notifications
class EmergencyObserver {
public:
    virtual ~EmergencyObserver() = default;
    virtual void onEmergencyActivated() = 0;
    virtual void onEmergencyDeactivated() = 0;
};

// Main LightStrip class using Strategy Pattern
class LightStrip {
private:
    std::unique_ptr<LightBehavior> lightBehavior;
    std::vector<EmergencyObserver*> observers;
    
public:
    LightStrip() : lightBehavior(std::make_unique<NormalLightBehavior>()) {}
    
    virtual ~LightStrip() = default;
    
    void setBehavior(std::unique_ptr<LightBehavior> behavior) {
        lightBehavior = std::move(behavior);
    }
    
    void activate() {
        if (lightBehavior) {
            lightBehavior->activate();
        }
    }
    
    void deactivate() {
        if (lightBehavior) {
            lightBehavior->deactivate();
        }
    }
    
    void setBrightness(float intensity) {
        if (lightBehavior) {
            lightBehavior->setBrightness(intensity);
        }
    }
    
    void setColor(const LightColor& color) {
        if (lightBehavior) {
            lightBehavior->setColor(color);
        }
    }
    
    void activateEmergencyMode() {
        setBehavior(std::make_unique<EmergencyLightBehavior>());
        activate();
        notifyEmergencyActivated();
    }
    
    void deactivateEmergencyMode() {
        setBehavior(std::make_unique<NormalLightBehavior>());
        notifyEmergencyDeactivated();
    }
    
    bool isEmergencyMode() const {
        return lightBehavior && lightBehavior->isEmergencyMode();
    }
    
    std::string getCurrentMode() const {
        return lightBehavior ? lightBehavior->getBehaviorType() : "None";
    }
    
    // Observer pattern methods
    void addObserver(EmergencyObserver* observer) {
        observers.push_back(observer);
    }
    
    void removeObserver(EmergencyObserver* observer) {
        observers.erase(
            std::remove(observers.begin(), observers.end(), observer),
            observers.end()
        );
    }

private:
    void notifyEmergencyActivated() {
        for (auto* observer : observers) {
            if (observer) {
                observer->onEmergencyActivated();
            }
        }
    }
    
    void notifyEmergencyDeactivated() {
        for (auto* observer : observers) {
            if (observer) {
                observer->onEmergencyDeactivated();
            }
        }
    }
};

#endif // LIGHT_STRIP_H