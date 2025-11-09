
#include "window.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

CustomWindow::CustomWindow() : shade(nullptr), curtain(nullptr) {
    UtilityFunctions::print("CustomWindow created");
}

CustomWindow::~CustomWindow() {
    if (shade) delete shade;
    if (curtain) delete curtain;
}

void CustomWindow::set_shade(ShadeState* s) { 
    if (shade) delete shade;
    shade = s; 
}

void CustomWindow::set_curtain(CurtainState* c) { 
    if (curtain) delete curtain;
    curtain = c; 
}

void CustomWindow::apply_shade() { 
    if (shade) {
        shade->apply_shade();
    } else {
        UtilityFunctions::print("No shade state set");
    }
}

void CustomWindow::operate_curtain() { 
    if (curtain) {
        curtain->operate_curtain();
    } else {
        UtilityFunctions::print("No curtain state set");
    }
}

void CustomWindow::_bind_methods() {
    ClassDB::bind_method(D_METHOD("apply_shade"), &CustomWindow::apply_shade);
    ClassDB::bind_method(D_METHOD("operate_curtain"), &CustomWindow::operate_curtain);
}
