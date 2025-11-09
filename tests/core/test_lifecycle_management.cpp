#include <gtest/gtest.h>
#include <memory>

// Include shared mocks
// Include shared mocks only when not using real godot-cpp
#ifdef TESTING_MODE
#ifndef GODOT_CPP_CLASSES_NODE_HPP
#include "../shared/mocks/godot_mock.h"
#endif
#endif

// Mock lifecycle manager for testing
class MockLifecycleManager {
public:
    enum class State {
        UNINITIALIZED,
        INITIALIZING,
        INITIALIZED,
        TERMINATING,
        TERMINATED,
        ERROR
    };

private:
    State current_state = State::UNINITIALIZED;
    std::vector<std::string> initialization_order;
    std::vector<std::string> termination_order;
    bool error_occurred = false;

public:
    State get_state() const { return current_state; }
    
    bool initialize() {
        if (current_state != State::UNINITIALIZED) {
            return false;
        }
        
        current_state = State::INITIALIZING;
        
        // Simulate initialization steps
        initialization_order.push_back("core_system");
        initialization_order.push_back("extension_registry");
        initialization_order.push_back("medical_equipment");
        initialization_order.push_back("window_controls");
        
        current_state = State::INITIALIZED;
        return true;
    }
    
    bool terminate() {
        if (current_state != State::INITIALIZED) {
            return false;
        }
        
        current_state = State::TERMINATING;
        
        // Simulate termination steps (reverse order)
        termination_order.push_back("window_controls");
        termination_order.push_back("medical_equipment");
        termination_order.push_back("extension_registry");
        termination_order.push_back("core_system");
        
        current_state = State::TERMINATED;
        return true;
    }
    
    void trigger_error() {
        current_state = State::ERROR;
        error_occurred = true;
    }
    
    bool has_error() const { return error_occurred; }
    
    const std::vector<std::string>& get_initialization_order() const {
        return initialization_order;
    }
    
    const std::vector<std::string>& get_termination_order() const {
        return termination_order;
    }
    
    void reset() {
        current_state = State::UNINITIALIZED;
        initialization_order.clear();
        termination_order.clear();
        error_occurred = false;
    }
};

class LifecycleManagementTest : public ::testing::Test {
protected:
    void SetUp() override {
        lifecycle_manager = std::make_unique<MockLifecycleManager>();
    }
    
    void TearDown() override {
        if (lifecycle_manager && lifecycle_manager->get_state() == MockLifecycleManager::State::INITIALIZED) {
            lifecycle_manager->terminate();
        }
        lifecycle_manager.reset();
    }

    std::unique_ptr<MockLifecycleManager> lifecycle_manager;
};

// Test initial state
TEST_F(LifecycleManagementTest, InitialState) {
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::UNINITIALIZED);
    EXPECT_FALSE(lifecycle_manager->has_error());
    EXPECT_TRUE(lifecycle_manager->get_initialization_order().empty());
    EXPECT_TRUE(lifecycle_manager->get_termination_order().empty());
}

// Test normal initialization
TEST_F(LifecycleManagementTest, NormalInitialization) {
    // Should start uninitialized
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::UNINITIALIZED);
    
    // Initialize should succeed
    EXPECT_TRUE(lifecycle_manager->initialize());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::INITIALIZED);
    
    // Check initialization order
    auto init_order = lifecycle_manager->get_initialization_order();
    EXPECT_EQ(init_order.size(), 4);
    EXPECT_EQ(init_order[0], "core_system");
    EXPECT_EQ(init_order[1], "extension_registry");
    EXPECT_EQ(init_order[2], "medical_equipment");
    EXPECT_EQ(init_order[3], "window_controls");
}

// Test normal termination
TEST_F(LifecycleManagementTest, NormalTermination) {
    // Initialize first
    EXPECT_TRUE(lifecycle_manager->initialize());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::INITIALIZED);
    
    // Terminate should succeed
    EXPECT_TRUE(lifecycle_manager->terminate());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::TERMINATED);
    
    // Check termination order (should be reverse of initialization)
    auto term_order = lifecycle_manager->get_termination_order();
    EXPECT_EQ(term_order.size(), 4);
    EXPECT_EQ(term_order[0], "window_controls");
    EXPECT_EQ(term_order[1], "medical_equipment");
    EXPECT_EQ(term_order[2], "extension_registry");
    EXPECT_EQ(term_order[3], "core_system");
}

// Test double initialization prevention
TEST_F(LifecycleManagementTest, DoubleInitializationPrevention) {
    // First initialization should succeed
    EXPECT_TRUE(lifecycle_manager->initialize());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::INITIALIZED);
    
    // Second initialization should fail
    EXPECT_FALSE(lifecycle_manager->initialize());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::INITIALIZED);
}

// Test termination without initialization
TEST_F(LifecycleManagementTest, TerminationWithoutInitialization) {
    // Should start uninitialized
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::UNINITIALIZED);
    
    // Termination should fail
    EXPECT_FALSE(lifecycle_manager->terminate());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::UNINITIALIZED);
}

// Test error handling
TEST_F(LifecycleManagementTest, ErrorHandling) {
    // Initialize normally
    EXPECT_TRUE(lifecycle_manager->initialize());
    EXPECT_FALSE(lifecycle_manager->has_error());
    
    // Trigger error
    lifecycle_manager->trigger_error();
    EXPECT_TRUE(lifecycle_manager->has_error());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::ERROR);
    
    // Should not be able to terminate from error state
    EXPECT_FALSE(lifecycle_manager->terminate());
}

// Test lifecycle reset
TEST_F(LifecycleManagementTest, LifecycleReset) {
    // Go through full lifecycle
    lifecycle_manager->initialize();
    lifecycle_manager->terminate();
    
    // Verify state
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::TERMINATED);
    EXPECT_FALSE(lifecycle_manager->get_initialization_order().empty());
    EXPECT_FALSE(lifecycle_manager->get_termination_order().empty());
    
    // Reset
    lifecycle_manager->reset();
    
    // Should be back to initial state
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::UNINITIALIZED);
    EXPECT_FALSE(lifecycle_manager->has_error());
    EXPECT_TRUE(lifecycle_manager->get_initialization_order().empty());
    EXPECT_TRUE(lifecycle_manager->get_termination_order().empty());
    
    // Should be able to initialize again
    EXPECT_TRUE(lifecycle_manager->initialize());
}

// Test complete lifecycle flow
TEST_F(LifecycleManagementTest, CompleteLifecycleFlow) {
    // Start uninitialized
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::UNINITIALIZED);
    
    // Initialize
    EXPECT_TRUE(lifecycle_manager->initialize());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::INITIALIZED);
    
    // Verify initialization happened in correct order
    auto init_order = lifecycle_manager->get_initialization_order();
    EXPECT_EQ(init_order.size(), 4);
    
    // Terminate
    EXPECT_TRUE(lifecycle_manager->terminate());
    EXPECT_EQ(lifecycle_manager->get_state(), MockLifecycleManager::State::TERMINATED);
    
    // Verify termination happened in reverse order
    auto term_order = lifecycle_manager->get_termination_order();
    EXPECT_EQ(term_order.size(), 4);
    
    // No errors should have occurred
    EXPECT_FALSE(lifecycle_manager->has_error());
}