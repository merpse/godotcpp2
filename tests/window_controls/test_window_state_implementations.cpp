#include <gtest/gtest.h>
#include <memory>

// Include window control headers
#include "../../extensions/window_controls/curtain_state.h"
#include "../../extensions/window_controls/shade_state.h"

// We need to declare the factory functions that are in the .cpp files
extern "C" {
    CurtainState* create_closed_curtain();
    CurtainState* create_open_curtain(); // If this exists
    ShadeState* create_opaque_shade();
    ShadeState* create_transparent_shade();
}

// Include shared test utilities
// Include shared mocks only when not using real godot-cpp
#ifdef TESTING_MODE
#ifndef GODOT_CPP_CLASSES_NODE_HPP
#include "../shared/mocks/godot_mock.h"
#endif
#endif
#include "../shared/utils/test_helpers.h"

class WindowStateImplementationsTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Initialize Godot mock for testing
        GodotMock::initialize();
    }

    void TearDown() override {
        GodotMock::cleanup();
    }
};

// Test ClosedCurtain implementation
TEST_F(WindowStateImplementationsTest, ClosedCurtainOperation) {
    CurtainState* closed_curtain = create_closed_curtain();
    
    ASSERT_NE(closed_curtain, nullptr);
    
    // Test that operate_curtain doesn't crash and can be called
    EXPECT_NO_THROW({
        closed_curtain->operate_curtain();
    });
    
    // Test multiple calls
    EXPECT_NO_THROW({
        closed_curtain->operate_curtain();
        closed_curtain->operate_curtain();
    });
    
    delete closed_curtain;
}

// Test ClosedCurtain memory management
TEST_F(WindowStateImplementationsTest, ClosedCurtainMemoryManagement) {
    const int num_instances = 10;
    std::vector<CurtainState*> curtains;
    
    // Create multiple instances
    for (int i = 0; i < num_instances; i++) {
        CurtainState* curtain = create_closed_curtain();
        ASSERT_NE(curtain, nullptr);
        curtains.push_back(curtain);
    }
    
    // Test that all instances work
    for (auto& curtain : curtains) {
        EXPECT_NO_THROW({
            curtain->operate_curtain();
        });
    }
    
    // Clean up
    for (auto& curtain : curtains) {
        delete curtain;
    }
}

// Test OpaqueLState implementation  
TEST_F(WindowStateImplementationsTest, OpaqueShadeOperation) {
    ShadeState* opaque_shade = create_opaque_shade();
    
    ASSERT_NE(opaque_shade, nullptr);
    
    // Test that operate_shade doesn't crash and can be called
    EXPECT_NO_THROW({
        opaque_shade->operate_shade();
    });
    
    // Test multiple calls
    EXPECT_NO_THROW({
        opaque_shade->operate_shade();
        opaque_shade->operate_shade();
    });
    
    delete opaque_shade;
}

// Test TransparentShade implementation
TEST_F(WindowStateImplementationsTest, TransparentShadeOperation) {
    ShadeState* transparent_shade = create_transparent_shade();
    
    ASSERT_NE(transparent_shade, nullptr);
    
    // Test that operate_shade doesn't crash and can be called
    EXPECT_NO_THROW({
        transparent_shade->operate_shade();
    });
    
    // Test multiple calls
    EXPECT_NO_THROW({
        transparent_shade->operate_shade();
        transparent_shade->operate_shade();
    });
    
    delete transparent_shade;
}

// Test shade state polymorphism
TEST_F(WindowStateImplementationsTest, ShadeStatePolymorphism) {
    ShadeState* opaque = create_opaque_shade();
    ShadeState* transparent = create_transparent_shade();
    
    ASSERT_NE(opaque, nullptr);
    ASSERT_NE(transparent, nullptr);
    
    // Both should implement the same interface
    std::vector<ShadeState*> shades = {opaque, transparent};
    
    for (auto& shade : shades) {
        EXPECT_NO_THROW({
            shade->operate_shade();
        });
    }
    
    delete opaque;
    delete transparent;
}

// Test curtain state factory functions
TEST_F(WindowStateImplementationsTest, CurtainStateFactoryFunctions) {
    // Test that factory functions return valid instances
    CurtainState* curtain1 = create_closed_curtain();
    CurtainState* curtain2 = create_closed_curtain();
    
    ASSERT_NE(curtain1, nullptr);
    ASSERT_NE(curtain2, nullptr);
    
    // Should be different instances
    EXPECT_NE(curtain1, curtain2);
    
    // Both should work independently
    EXPECT_NO_THROW({
        curtain1->operate_curtain();
        curtain2->operate_curtain();
    });
    
    delete curtain1;
    delete curtain2;
}

// Test shade state factory functions
TEST_F(WindowStateImplementationsTest, ShadeStateFactoryFunctions) {
    // Test that factory functions return valid instances
    ShadeState* opaque1 = create_opaque_shade();
    ShadeState* opaque2 = create_opaque_shade();
    ShadeState* transparent1 = create_transparent_shade();
    ShadeState* transparent2 = create_transparent_shade();
    
    ASSERT_NE(opaque1, nullptr);
    ASSERT_NE(opaque2, nullptr);
    ASSERT_NE(transparent1, nullptr);
    ASSERT_NE(transparent2, nullptr);
    
    // Should be different instances
    EXPECT_NE(opaque1, opaque2);
    EXPECT_NE(transparent1, transparent2);
    EXPECT_NE(opaque1, transparent1);
    
    // All should work independently
    std::vector<ShadeState*> all_shades = {opaque1, opaque2, transparent1, transparent2};
    for (auto& shade : all_shades) {
        EXPECT_NO_THROW({
            shade->operate_shade();
        });
    }
    
    for (auto& shade : all_shades) {
        delete shade;
    }
}

// Test state pattern interface compliance
TEST_F(WindowStateImplementationsTest, StatePatternInterfaceCompliance) {
    // Test that all implementations properly implement their interfaces
    
    CurtainState* closed_curtain = create_closed_curtain();
    ASSERT_NE(closed_curtain, nullptr);
    
    // Virtual destructor should work correctly
    EXPECT_NO_THROW({
        delete closed_curtain; // Should call virtual destructor
    });
    
    ShadeState* opaque_shade = create_opaque_shade();
    ShadeState* transparent_shade = create_transparent_shade();
    
    ASSERT_NE(opaque_shade, nullptr);
    ASSERT_NE(transparent_shade, nullptr);
    
    // Virtual destructors should work correctly
    EXPECT_NO_THROW({
        delete opaque_shade;
        delete transparent_shade;
    });
}

// Test concurrent state operations
TEST_F(WindowStateImplementationsTest, ConcurrentStateOperations) {
    // Create multiple state instances
    CurtainState* curtain = create_closed_curtain();
    ShadeState* opaque = create_opaque_shade();
    ShadeState* transparent = create_transparent_shade();
    
    ASSERT_NE(curtain, nullptr);
    ASSERT_NE(opaque, nullptr);
    ASSERT_NE(transparent, nullptr);
    
    // Test that they can all operate concurrently without interference
    EXPECT_NO_THROW({
        curtain->operate_curtain();
        opaque->operate_shade();
        transparent->operate_shade();
        
        curtain->operate_curtain();
        opaque->operate_shade();
        transparent->operate_shade();
    });
    
    delete curtain;
    delete opaque;
    delete transparent;
}