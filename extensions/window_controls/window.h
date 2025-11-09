
#ifndef WINDOW_H
#define WINDOW_H

#include <godot_cpp/classes/node.hpp>
#include "shade_state.h"
#include "curtain_state.h"

using namespace godot;

class CustomWindow : public Node {
    GDCLASS(CustomWindow, Node)

private:
    ShadeState* shade;
    CurtainState* curtain;

public:
    CustomWindow();
    ~CustomWindow();

    void set_shade(ShadeState* s);
    void set_curtain(CurtainState* c);
    void apply_shade();
    void operate_curtain();

protected:
    static void _bind_methods();
};

#endif // WINDOW_H
