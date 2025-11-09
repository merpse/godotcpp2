
#ifndef CURTAIN_STATE_H
#define CURTAIN_STATE_H

class CurtainState {
public:
    virtual ~CurtainState() = default;
    virtual void operate_curtain() = 0;
};

#endif // CURTAIN_STATE_H
