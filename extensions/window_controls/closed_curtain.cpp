
#include "curtain_state.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

class ClosedCurtain : public CurtainState {
public:
    void operate_curtain() override {
        UtilityFunctions::print("Curtain is now closed");
    }
};

// Factory function to create ClosedCurtain instances
extern "C" CurtainState* create_closed_curtain() {
    return new ClosedCurtain();
}
