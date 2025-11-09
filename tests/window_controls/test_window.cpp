#include <gtest/gtest.h>
#include <memory>

// Include shared mocks only when not using real godot-cpp
#ifdef TESTING_MODE
#ifndef GODOT_CPP_CLASSES_NODE_HPP
#include "../shared/mocks/godot_mock.h"
#endif
#endif

// Include window controls headers
#include "../../extensions/window_controls/window.h"
#include "../../extensions/window_controls/curtain_state.h"
#include "../../extensions/window_controls/shade_state.h"

class WindowTest : public ::testing::Test {
protected:
    void SetUp() override {
        window = std::make_unique<CustomWindow>();
    }
    
    void TearDown() override {
        window.reset();
    }

    std::unique_ptr<CustomWindow> window;
};

// Test window creation and initial state
TEST_F(WindowTest, WindowCreation) {
    ASSERT_NE(window, nullptr);
    EXPECT_EQ(window->get_class_static(), "CustomWindow");
}

// Test window opening and closing
TEST_F(WindowTest, WindowOpenClose) {
    // Test window operations
    EXPECT_NO_THROW(window->open_window());
    EXPECT_NO_THROW(window->close_window());
    
    // Test window state changes
    EXPECT_NO_THROW(window->toggle_window());
}

// Test window state management
TEST_F(WindowTest, WindowStateManagement) {
    // Test state transitions - should not crash
    EXPECT_NO_THROW(window->set_shade_state("opaque"));
    EXPECT_NO_THROW(window->set_shade_state("transparent"));
    EXPECT_NO_THROW(window->set_curtain_state("closed"));
}

// Test window size operations
TEST_F(WindowTest, WindowSizeOperations) {
    // Test window sizing
    EXPECT_NO_THROW(window->set_window_size(800, 600));
    EXPECT_NO_THROW(window->set_window_size(1024, 768));
    EXPECT_NO_THROW(window->set_window_size(1920, 1080));
}

// Test window position operations  
TEST_F(WindowTest, WindowPositionOperations) {
    // Test window positioning
    EXPECT_NO_THROW(window->set_window_position(100, 100));
    EXPECT_NO_THROW(window->set_window_position(0, 0));
    EXPECT_NO_THROW(window->set_window_position(500, 300));
}

// Test window visibility
TEST_F(WindowTest, WindowVisibility) {
    // Test visibility operations
    EXPECT_NO_THROW(window->show_window());
    EXPECT_NO_THROW(window->hide_window());
    EXPECT_NO_THROW(window->toggle_visibility());
}

// Test window properties
TEST_F(WindowTest, WindowProperties) {
    // Test property setting - should not crash
    EXPECT_NO_THROW(window->set_title("Test Window"));
    EXPECT_NO_THROW(window->set_resizable(true));
    EXPECT_NO_THROW(window->set_resizable(false));
}