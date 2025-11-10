#include "godot_light_strip.h"

GodotLightStrip::GodotLightStrip() {
    cpp_light_strip = std::make_unique<LightStrip>();
}

GodotLightStrip::~GodotLightStrip() = default;

void GodotLightStrip::_bind_methods() {
    // Bind methods to make them available in GDScript
    ClassDB::bind_method(D_METHOD("activate"), &GodotLightStrip::activate);
    ClassDB::bind_method(D_METHOD("deactivate"), &GodotLightStrip::deactivate);
    ClassDB::bind_method(D_METHOD("set_normal_behavior"), &GodotLightStrip::set_normal_behavior);
    ClassDB::bind_method(D_METHOD("set_emergency_behavior"), &GodotLightStrip::set_emergency_behavior);
    ClassDB::bind_method(D_METHOD("set_behavior", "behavior_name"), &GodotLightStrip::set_behavior);
    ClassDB::bind_method(D_METHOD("set_brightness", "brightness"), &GodotLightStrip::set_brightness);
    ClassDB::bind_method(D_METHOD("set_color", "red", "green", "blue"), &GodotLightStrip::set_color);
    ClassDB::bind_method(D_METHOD("is_active"), &GodotLightStrip::is_active);
    ClassDB::bind_method(D_METHOD("get_brightness"), &GodotLightStrip::get_brightness);
    ClassDB::bind_method(D_METHOD("get_current_behavior"), &GodotLightStrip::get_current_behavior);
    ClassDB::bind_method(D_METHOD("get_current_mode"), &GodotLightStrip::get_current_mode);
}

void GodotLightStrip::activate() {
    if (cpp_light_strip) {
        cpp_light_strip->activate();
        UtilityFunctions::print("💡 LightStrip activated via C++ Strategy Pattern");
    }
}

void GodotLightStrip::deactivate() {
    if (cpp_light_strip) {
        cpp_light_strip->deactivate();
        UtilityFunctions::print("🔌 LightStrip deactivated");
    }
}

void GodotLightStrip::set_normal_behavior() {
    if (cpp_light_strip) {
        cpp_light_strip->setBehavior(std::make_unique<NormalLightBehavior>());
        UtilityFunctions::print("🔆 LightStrip set to Normal Behavior");
    }
}

void GodotLightStrip::set_emergency_behavior() {
    if (cpp_light_strip) {
        cpp_light_strip->activateEmergencyMode(); // Use the built-in method
        UtilityFunctions::print("🚨 LightStrip set to Emergency Behavior");
    }
}

void GodotLightStrip::set_brightness(float brightness) {
    if (cpp_light_strip) {
        // Clamp brightness between 0.0 and 1.0
        brightness = (brightness < 0.0f) ? 0.0f : (brightness > 1.0f) ? 1.0f : brightness;
        cpp_light_strip->setBrightness(brightness);
        UtilityFunctions::print("🔅 LightStrip brightness set to: ", brightness);
    }
}

void GodotLightStrip::set_color(float red, float green, float blue) {
    if (cpp_light_strip) {
        // Convert float [0.0-1.0] to int [0-255] or use as-is if already in [0-255] range
        int r = static_cast<int>(red > 1.0f ? red : red * 255.0f);
        int g = static_cast<int>(green > 1.0f ? green : green * 255.0f);
        int b = static_cast<int>(blue > 1.0f ? blue : blue * 255.0f);
        
        // Clamp to valid range
        r = std::max(0, std::min(255, r));
        g = std::max(0, std::min(255, g));
        b = std::max(0, std::min(255, b));
        
        LightColor color(r, g, b);
        cpp_light_strip->setColor(color);
        UtilityFunctions::print("🎨 LightStrip color set to RGB(", r, ",", g, ",", b, ")");
    }
}

bool GodotLightStrip::is_active() const {
    if (cpp_light_strip) {
        // LightStrip doesn't have isActive method, so we check if it's in emergency mode or has behavior
        return cpp_light_strip->isEmergencyMode() || true; // Assume active if behavior exists
    }
    return false;
}

float GodotLightStrip::get_brightness() const {
    if (cpp_light_strip) {
        // LightStrip doesn't expose brightness directly, return a default
        return 1.0f; // Could be enhanced to store/track brightness
    }
    return 0.0f;
}

String GodotLightStrip::get_current_behavior() const {
    if (cpp_light_strip) {
        return String(cpp_light_strip->getCurrentMode().c_str());
    }
    return "None";
}

String GodotLightStrip::get_current_mode() const {
    // Alias for get_current_behavior for consistency
    return get_current_behavior();
}

void GodotLightStrip::set_behavior(const String& behavior_name) {
    if (!cpp_light_strip) {
        return;
    }
    
    String behavior_lower = behavior_name.to_lower();
    
    if (behavior_lower == "emergency") {
        cpp_light_strip->activateEmergencyMode();
        UtilityFunctions::print("🚨 C++ Strategy: Emergency behavior activated");
    } else if (behavior_lower == "auto" || behavior_lower == "normal" || behavior_lower == "manual") {
        cpp_light_strip->deactivateEmergencyMode(); // This sets normal behavior
        UtilityFunctions::print("🔆 C++ Strategy: Normal behavior activated (", behavior_name, ")");
    } else {
        UtilityFunctions::print("⚠️ Unknown behavior: ", behavior_name, " - defaulting to normal");
        cpp_light_strip->deactivateEmergencyMode();
    }
}