#ifndef LIGHT_STRIP_TEST_MOCK_H
#define LIGHT_STRIP_TEST_MOCK_H

// Mock light strip classes for testing without Godot dependencies
#include <string>
#include <memory>
#include <algorithm>

// Mock color structure
struct LightColor {
    float r, g, b;
    LightColor() : r(1.0f), g(1.0f), b(1.0f) {}
    LightColor(float red, float green, float blue) : r(red), g(green), b(blue) {}
};

// Forward declarations for Strategy pattern
class LightBehavior;
class NormalLightBehavior;
class EmergencyLightBehavior;

// Light behavior interface (Strategy pattern)
class LightBehavior {
public:
    virtual ~LightBehavior() = default;
    virtual void apply_behavior() = 0;
    virtual bool is_emergency_mode() const = 0;
    virtual float get_base_brightness() const { return 1.0f; }
};

// Normal lighting behavior
class NormalLightBehavior : public LightBehavior {
public:
    void apply_behavior() override {
        // Normal lighting logic
    }
    
    bool is_emergency_mode() const override {
        return false;
    }
    
    float get_base_brightness() const override {
        return 1.0f;
    }
};

// Emergency lighting behavior  
class EmergencyLightBehavior : public LightBehavior {
public:
    void apply_behavior() override {
        // Emergency lighting logic - blinking, high brightness
    }
    
    bool is_emergency_mode() const override {
        return true;
    }
    
    float get_base_brightness() const override {
        return 1.0f;  // Maximum brightness for emergency
    }
};

// Core LightStrip class (Strategy pattern + Observer pattern)
class LightStrip {
private:
    std::unique_ptr<LightBehavior> current_behavior;
    LightColor color;
    float brightness;
    bool powered_on;

public:
    LightStrip() 
        : current_behavior(std::make_unique<NormalLightBehavior>())
        , color(1.0f, 1.0f, 1.0f)
        , brightness(1.0f)
        , powered_on(true)
    {}

    virtual ~LightStrip() = default;

    // Strategy pattern - behavior switching
    void set_behavior(std::unique_ptr<LightBehavior> behavior) {
        if (behavior) {
            current_behavior = std::move(behavior);
        }
    }

    // Core lighting operations
    void set_brightness(float value) {
        brightness = std::clamp(value, 0.0f, 1.0f);
    }

    float get_brightness() const {
        return brightness;
    }

    void set_color(float r, float g, float b) {
        color = LightColor(r, g, b);
    }

    LightColor get_color() const {
        return color;
    }

    // Power control
    void turn_on() {
        powered_on = true;
    }

    void turn_off() {
        powered_on = false;
    }

    bool is_powered_on() const {
        return powered_on;
    }

    // Emergency mode operations
    bool is_emergency_mode() const {
        return current_behavior ? current_behavior->is_emergency_mode() : false;
    }

    void activate_emergency_mode() {
        set_behavior(std::make_unique<EmergencyLightBehavior>());
    }

    void deactivate_emergency_mode() {
        set_behavior(std::make_unique<NormalLightBehavior>());
    }

    // Apply current behavior
    void update() {
        if (current_behavior && powered_on) {
            current_behavior->apply_behavior();
        }
    }
};

// Mock Godot wrapper (without actual Godot dependencies)
class GodotLightStrip {
private:
    std::unique_ptr<LightStrip> light_strip;

public:
    GodotLightStrip() : light_strip(std::make_unique<LightStrip>()) {}

    virtual ~GodotLightStrip() = default;

    // Wrapper methods that delegate to core LightStrip
    void set_brightness(float value) {
        if (light_strip) {
            light_strip->set_brightness(value);
        }
    }

    float get_brightness() const {
        return light_strip ? light_strip->get_brightness() : 0.0f;
    }

    void set_color(float r, float g, float b) {
        if (light_strip) {
            light_strip->set_color(r, g, b);
        }
    }

    bool is_emergency_mode() const {
        return light_strip ? light_strip->is_emergency_mode() : false;
    }

    void activate_emergency_mode() {
        if (light_strip) {
            light_strip->activate_emergency_mode();
        }
    }

    void deactivate_emergency_mode() {
        if (light_strip) {
            light_strip->deactivate_emergency_mode();
        }
    }

    // String-based behavior interface for GDScript compatibility
    void set_behavior(const std::string& behavior_name) {
        if (!light_strip) return;

        if (behavior_name == "emergency") {
            light_strip->set_behavior(std::make_unique<EmergencyLightBehavior>());
        } else if (behavior_name == "normal") {
            light_strip->set_behavior(std::make_unique<NormalLightBehavior>());
        }
    }

    std::string get_current_mode() const {
        if (!light_strip) return "unknown";
        return light_strip->is_emergency_mode() ? "emergency" : "normal";
    }

    void activate() {
        if (light_strip) {
            light_strip->turn_on();
        }
    }

    void deactivate() {
        if (light_strip) {
            light_strip->turn_off();
        }
    }
};

#endif // LIGHT_STRIP_TEST_MOCK_H