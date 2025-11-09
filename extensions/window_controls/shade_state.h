
#ifndef SHADE_STATE_H
#define SHADE_STATE_H

class ShadeState {
public:
    virtual ~ShadeState() = default;
    virtual void apply_shade() = 0;
};

#endif // SHADE_STATE_H
