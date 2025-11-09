#include <gtest/gtest.h>
#include <memory>

// Include shared mocks
// Include shared mocks only when not using real godot-cpp
#ifdef TESTING_MODE
#ifndef GODOT_CPP_CLASSES_NODE_HPP
#include "../shared/mocks/godot_mock.h"
#endif
#endif

// Abstract base classes for the State pattern
class ShadeState {
public:
    virtual ~ShadeState() = default;
    virtual void apply_shade() = 0;
    virtual std::string get_state_name() const = 0;
};

class CurtainState {
public:
    virtual ~CurtainState() = default;
    virtual void operate_curtain() = 0;
    virtual std::string get_state_name() const = 0;
};

// Concrete shade state implementations
class OpaqueShadeState : public ShadeState {
public:
    void apply_shade() override {
        godot::UtilityFunctions::print("Applying opaque shade - blocking all light");
    }
    
    std::string get_state_name() const override {
        return "OpaqueShade";
    }
};

class TransparentShadeState : public ShadeState {
public:
    void apply_shade() override {
        godot::UtilityFunctions::print("Applying transparent shade - letting light through");
    }
    
    std::string get_state_name() const override {
        return "TransparentShade";
    }
};

// Concrete curtain state implementations
class ClosedCurtainState : public CurtainState {
public:
    void operate_curtain() override {
        godot::UtilityFunctions::print("Operating closed curtain - privacy mode");
    }
    
    std::string get_state_name() const override {
        return "ClosedCurtain";
    }
};

// Context class that uses the State pattern
class WindowStateContext {
private:
    std::unique_ptr<ShadeState> shade_state;
    std::unique_ptr<CurtainState> curtain_state;

public:
    WindowStateContext() = default;
    ~WindowStateContext() = default;

    void set_shade_state(std::unique_ptr<ShadeState> new_state) {
        shade_state = std::move(new_state);
    }

    void set_curtain_state(std::unique_ptr<CurtainState> new_state) {
        curtain_state = std::move(new_state);
    }

    void apply_shade() {
        if (shade_state) {
            shade_state->apply_shade();
        }
    }

    void operate_curtain() {
        if (curtain_state) {
            curtain_state->operate_curtain();
        }
    }

    std::string get_shade_state_name() const {
        return shade_state ? shade_state->get_state_name() : "NoState";
    }

    std::string get_curtain_state_name() const {
        return curtain_state ? curtain_state->get_state_name() : "NoState";
    }
};

class StatePatternTest : public ::testing::Test {
protected:
    void SetUp() override {
        context = std::make_unique<WindowStateContext>();
    }
    
    void TearDown() override {
        context.reset();
    }

    std::unique_ptr<WindowStateContext> context;
};

// Test shade state changes
TEST_F(StatePatternTest, ShadeStateChanges) {
    // Test initial state
    EXPECT_EQ(context->get_shade_state_name(), "NoState");

    // Set opaque state
    context->set_shade_state(std::make_unique<OpaqueShadeState>());
    EXPECT_EQ(context->get_shade_state_name(), "OpaqueShade");
    EXPECT_NO_THROW(context->apply_shade());

    // Set transparent state
    context->set_shade_state(std::make_unique<TransparentShadeState>());
    EXPECT_EQ(context->get_shade_state_name(), "TransparentShade");
    EXPECT_NO_THROW(context->apply_shade());
}

// Test curtain state changes
TEST_F(StatePatternTest, CurtainStateChanges) {
    // Test initial state
    EXPECT_EQ(context->get_curtain_state_name(), "NoState");

    // Set closed curtain state
    context->set_curtain_state(std::make_unique<ClosedCurtainState>());
    EXPECT_EQ(context->get_curtain_state_name(), "ClosedCurtain");
    EXPECT_NO_THROW(context->operate_curtain());
}

// Test multiple state transitions
TEST_F(StatePatternTest, MultipleStateTransitions) {
    // Start with no states
    EXPECT_EQ(context->get_shade_state_name(), "NoState");
    EXPECT_EQ(context->get_curtain_state_name(), "NoState");

    // Set both states
    context->set_shade_state(std::make_unique<OpaqueShadeState>());
    context->set_curtain_state(std::make_unique<ClosedCurtainState>());

    EXPECT_EQ(context->get_shade_state_name(), "OpaqueShade");
    EXPECT_EQ(context->get_curtain_state_name(), "ClosedCurtain");

    // Apply both operations
    EXPECT_NO_THROW(context->apply_shade());
    EXPECT_NO_THROW(context->operate_curtain());

    // Change shade state while keeping curtain state
    context->set_shade_state(std::make_unique<TransparentShadeState>());
    EXPECT_EQ(context->get_shade_state_name(), "TransparentShade");
    EXPECT_EQ(context->get_curtain_state_name(), "ClosedCurtain");
}

// Test state operations without state set
TEST_F(StatePatternTest, OperationsWithoutState) {
    // Should handle gracefully when no state is set
    EXPECT_NO_THROW(context->apply_shade());
    EXPECT_NO_THROW(context->operate_curtain());
}

// Test state pattern polymorphism
TEST_F(StatePatternTest, StatePolymorphism) {
    // Create states via base class pointers
    std::unique_ptr<ShadeState> opaque = std::make_unique<OpaqueShadeState>();
    std::unique_ptr<ShadeState> transparent = std::make_unique<TransparentShadeState>();
    std::unique_ptr<CurtainState> closed = std::make_unique<ClosedCurtainState>();

    // Verify polymorphism works
    EXPECT_EQ(opaque->get_state_name(), "OpaqueShade");
    EXPECT_EQ(transparent->get_state_name(), "TransparentShade");
    EXPECT_EQ(closed->get_state_name(), "ClosedCurtain");

    // Verify virtual method calls work
    EXPECT_NO_THROW(opaque->apply_shade());
    EXPECT_NO_THROW(transparent->apply_shade());
    EXPECT_NO_THROW(closed->operate_curtain());
}