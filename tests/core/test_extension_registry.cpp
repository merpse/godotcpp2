#include <gtest/gtest.h>
#include <memory>

// Include shared mocks
// Include shared mocks only when not using real godot-cpp
#ifdef TESTING_MODE
#ifndef GODOT_CPP_CLASSES_NODE_HPP
#include "../shared/mocks/godot_mock.h"
#endif
#endif

// Mock classes to test extension registration
class MockExtensionInterface {
public:
    virtual ~MockExtensionInterface() = default;
    virtual bool initialize() = 0;
    virtual void terminate() = 0;
    virtual std::string get_extension_name() const = 0;
    virtual std::string get_version() const = 0;
};

class MockMedicalEquipmentExtension : public MockExtensionInterface {
public:
    bool initialize() override {
        initialized = true;
        return true;
    }
    
    void terminate() override {
        initialized = false;
    }
    
    std::string get_extension_name() const override {
        return "MedicalEquipment";
    }
    
    std::string get_version() const override {
        return "1.0.0";
    }
    
    bool is_initialized() const { return initialized; }

private:
    bool initialized = false;
};

class MockWindowControlsExtension : public MockExtensionInterface {
public:
    bool initialize() override {
        initialized = true;
        return true;
    }
    
    void terminate() override {
        initialized = false;
    }
    
    std::string get_extension_name() const override {
        return "WindowControls";
    }
    
    std::string get_version() const override {
        return "1.0.0";
    }
    
    bool is_initialized() const { return initialized; }

private:
    bool initialized = false;
};

// Mock extension registry
class MockExtensionRegistry {
private:
    std::vector<std::unique_ptr<MockExtensionInterface>> extensions;
    bool registry_initialized = false;

public:
    void register_extension(std::unique_ptr<MockExtensionInterface> extension) {
        extensions.push_back(std::move(extension));
    }
    
    bool initialize_all_extensions() {
        registry_initialized = true;
        for (auto& extension : extensions) {
            if (!extension->initialize()) {
                return false;
            }
        }
        return true;
    }
    
    void terminate_all_extensions() {
        for (auto& extension : extensions) {
            extension->terminate();
        }
        registry_initialized = false;
    }
    
    size_t get_extension_count() const {
        return extensions.size();
    }
    
    bool is_registry_initialized() const {
        return registry_initialized;
    }
    
    std::vector<std::string> get_extension_names() const {
        std::vector<std::string> names;
        for (const auto& extension : extensions) {
            names.push_back(extension->get_extension_name());
        }
        return names;
    }
};

class CoreFrameworkTest : public ::testing::Test {
protected:
    void SetUp() override {
        registry = std::make_unique<MockExtensionRegistry>();
    }
    
    void TearDown() override {
        if (registry) {
            registry->terminate_all_extensions();
        }
        registry.reset();
    }

    std::unique_ptr<MockExtensionRegistry> registry;
};

// Test extension registration
TEST_F(CoreFrameworkTest, ExtensionRegistration) {
    // Initially no extensions
    EXPECT_EQ(registry->get_extension_count(), 0);
    
    // Register medical equipment extension
    auto medical_ext = std::make_unique<MockMedicalEquipmentExtension>();
    EXPECT_EQ(medical_ext->get_extension_name(), "MedicalEquipment");
    registry->register_extension(std::move(medical_ext));
    
    EXPECT_EQ(registry->get_extension_count(), 1);
    
    // Register window controls extension
    auto window_ext = std::make_unique<MockWindowControlsExtension>();
    EXPECT_EQ(window_ext->get_extension_name(), "WindowControls");
    registry->register_extension(std::move(window_ext));
    
    EXPECT_EQ(registry->get_extension_count(), 2);
}

// Test extension initialization
TEST_F(CoreFrameworkTest, ExtensionInitialization) {
    // Register extensions
    auto medical_ext = std::make_unique<MockMedicalEquipmentExtension>();
    auto window_ext = std::make_unique<MockWindowControlsExtension>();
    
    // Verify initial state
    EXPECT_FALSE(medical_ext->is_initialized());
    EXPECT_FALSE(window_ext->is_initialized());
    
    registry->register_extension(std::move(medical_ext));
    registry->register_extension(std::move(window_ext));
    
    // Initialize all extensions
    EXPECT_TRUE(registry->initialize_all_extensions());
    EXPECT_TRUE(registry->is_registry_initialized());
}

// Test extension termination
TEST_F(CoreFrameworkTest, ExtensionTermination) {
    // Register and initialize extensions
    registry->register_extension(std::make_unique<MockMedicalEquipmentExtension>());
    registry->register_extension(std::make_unique<MockWindowControlsExtension>());
    
    EXPECT_TRUE(registry->initialize_all_extensions());
    EXPECT_TRUE(registry->is_registry_initialized());
    
    // Terminate all extensions
    registry->terminate_all_extensions();
    EXPECT_FALSE(registry->is_registry_initialized());
}

// Test extension name retrieval
TEST_F(CoreFrameworkTest, ExtensionNameRetrieval) {
    // Register extensions
    registry->register_extension(std::make_unique<MockMedicalEquipmentExtension>());
    registry->register_extension(std::make_unique<MockWindowControlsExtension>());
    
    auto names = registry->get_extension_names();
    EXPECT_EQ(names.size(), 2);
    
    // Check that both extensions are present
    EXPECT_NE(std::find(names.begin(), names.end(), "MedicalEquipment"), names.end());
    EXPECT_NE(std::find(names.begin(), names.end(), "WindowControls"), names.end());
}

// Test extension lifecycle management
TEST_F(CoreFrameworkTest, ExtensionLifecycleManagement) {
    // Test complete lifecycle
    auto medical_ext = std::make_unique<MockMedicalEquipmentExtension>();
    auto* medical_ptr = medical_ext.get(); // Keep pointer for testing
    
    // Initial state
    EXPECT_FALSE(medical_ptr->is_initialized());
    
    // Register
    registry->register_extension(std::move(medical_ext));
    EXPECT_EQ(registry->get_extension_count(), 1);
    
    // Initialize
    EXPECT_TRUE(registry->initialize_all_extensions());
    EXPECT_TRUE(registry->is_registry_initialized());
    
    // Terminate
    registry->terminate_all_extensions();
    EXPECT_FALSE(registry->is_registry_initialized());
}

// Test multiple extension coordination
TEST_F(CoreFrameworkTest, MultipleExtensionCoordination) {
    // Register multiple extensions
    registry->register_extension(std::make_unique<MockMedicalEquipmentExtension>());
    registry->register_extension(std::make_unique<MockWindowControlsExtension>());
    
    EXPECT_EQ(registry->get_extension_count(), 2);
    
    // Initialize all at once
    EXPECT_TRUE(registry->initialize_all_extensions());
    
    // Verify all are registered
    auto names = registry->get_extension_names();
    EXPECT_EQ(names.size(), 2);
    
    // Terminate all at once
    registry->terminate_all_extensions();
    EXPECT_FALSE(registry->is_registry_initialized());
}