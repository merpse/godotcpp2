
#include "shade_state.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

class Transparent : public ShadeState {
public:
    void apply_shade() override {
        UtilityFunctions::print("Window shade is now transparent");
    }
};

// Factory function to create Transparent instances
extern "C" ShadeState* create_transparent_shade() {
    return new Transparent();
}
