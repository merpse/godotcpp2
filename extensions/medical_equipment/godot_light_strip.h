#ifndef GODOT_LIGHT_STRIP_H
#define GODOT_LIGHT_STRIP_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "light_strip.h"

using namespace godot;

class GodotLightStrip : public Node {
    GDCLASS(GodotLightStrip, Node)
    
private:
    std::unique_ptr<LightStrip> cpp_light_strip;
    
protected:
    static void _bind_methods();
    
public:
    GodotLightStrip();
    ~GodotLightStrip();
    
    // Expose C++ functionality to GDScript
    void activate();
    void deactivate();
    void set_normal_behavior();
    void set_emergency_behavior();
    void set_behavior(const String& behavior_name);  // String-based behavior setting
    void set_brightness(float brightness);
    void set_color(float red, float green, float blue);  // Changed to float for consistency
    
    // Get current state
    bool is_active() const;
    float get_brightness() const;
    String get_current_behavior() const;
    String get_current_mode() const;  // Alias for get_current_behavior for consistency
};

#endif // GODOT_LIGHT_STRIP_H