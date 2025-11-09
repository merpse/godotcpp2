
#include "shade_state.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

class Opaque : public ShadeState {
public:
    void apply_shade() override {
        UtilityFunctions::print("Window shade is now opaque");
    }
};

// Factory function to create Opaque instances
extern "C" ShadeState* create_opaque_shade() {
    return new Opaque();
}
