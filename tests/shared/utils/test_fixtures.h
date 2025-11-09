#pragma once
#include <gtest/gtest.h>
#include <memory>
#include <vector>
#include <string>

namespace TestFixtures {

    // Base test fixture for all extension tests
    class ExtensionTestBase : public ::testing::Test {
    protected:
        void SetUp() override {
            // Common setup for all extension tests
            test_start_time = std::chrono::steady_clock::now();
        }
        
        void TearDown() override {
            // Common cleanup for all extension tests
            test_end_time = std::chrono::steady_clock::now();
            test_duration = std::chrono::duration_cast<std::chrono::milliseconds>(
                test_end_time - test_start_time);
        }

        std::chrono::milliseconds GetTestDuration() const {
            return test_duration;
        }

    private:
        std::chrono::steady_clock::time_point test_start_time;
        std::chrono::steady_clock::time_point test_end_time;
        std::chrono::milliseconds test_duration{0};
    };

    // Base fixture for medical equipment tests
    class MedicalEquipmentTestBase : public ExtensionTestBase {
    protected:
        void SetUp() override {
            ExtensionTestBase::SetUp();
            // Medical equipment specific setup
            default_height = 80.0f;
            default_temperature_mode = "neutral";
            safety_enabled = true;
        }
        
        void TearDown() override {
            // Medical equipment specific cleanup
            ExtensionTestBase::TearDown();
        }

        float default_height;
        std::string default_temperature_mode;
        bool safety_enabled;
    };

    // Base fixture for window controls tests
    class WindowControlsTestBase : public ExtensionTestBase {
    protected:
        void SetUp() override {
            ExtensionTestBase::SetUp();
            // Window controls specific setup
            default_window_size = {800, 600};
            default_window_position = {100, 100};
            window_visible = true;
        }
        
        void TearDown() override {
            // Window controls specific cleanup
            ExtensionTestBase::TearDown();
        }

        std::pair<int, int> default_window_size;
        std::pair<int, int> default_window_position;
        bool window_visible;
    };

    // Base fixture for core framework tests
    class CoreFrameworkTestBase : public ExtensionTestBase {
    protected:
        void SetUp() override {
            ExtensionTestBase::SetUp();
            // Core framework specific setup
            extension_count = 0;
            registry_initialized = false;
        }
        
        void TearDown() override {
            // Core framework specific cleanup
            extension_count = 0;
            registry_initialized = false;
            ExtensionTestBase::TearDown();
        }

        size_t extension_count;
        bool registry_initialized;
    };

    // Mock object factory
    class MockObjectFactory {
    public:
        // Create test data sets for medical equipment
        static std::vector<float> GetTestHeights() {
            return {50.0f, 70.0f, 80.0f, 90.0f, 100.0f, 120.0f};
        }

        static std::vector<std::string> GetTestProcedureNames() {
            return {"appendectomy", "knee_surgery", "brain_surgery", "heart_surgery"};
        }

        static std::vector<std::string> GetTestBedTypes() {
            return {"patient_bed", "surgical_bed", "PATIENT_BED", "SURGICAL_BED", "patient", "surgical"};
        }

        // Create test data sets for window controls
        static std::vector<std::pair<int, int>> GetTestWindowSizes() {
            return {{640, 480}, {800, 600}, {1024, 768}, {1920, 1080}};
        }

        static std::vector<std::pair<int, int>> GetTestWindowPositions() {
            return {{0, 0}, {100, 100}, {200, 150}, {500, 300}};
        }

        static std::vector<std::string> GetTestShadeStates() {
            return {"opaque", "transparent", "OPAQUE", "TRANSPARENT"};
        }

        static std::vector<std::string> GetTestCurtainStates() {
            return {"closed", "open", "CLOSED", "OPEN"};
        }

        // Create test data sets for core framework
        static std::vector<std::string> GetTestExtensionNames() {
            return {"MedicalEquipment", "WindowControls", "CoreFramework", "TestExtension"};
        }

        static std::vector<std::string> GetTestVersions() {
            return {"1.0.0", "1.1.0", "2.0.0", "0.9.0-beta"};
        }
    };

    // Parameterized test fixture for testing multiple values
    template<typename T>
    class ParameterizedExtensionTest : public ExtensionTestBase, 
                                     public ::testing::WithParamInterface<T> {
    protected:
        void SetUp() override {
            ExtensionTestBase::SetUp();
            test_parameter = GetParam();
        }

        T test_parameter;
    };

    // Performance test fixture
    class PerformanceTestBase : public ExtensionTestBase {
    protected:
        void SetUp() override {
            ExtensionTestBase::SetUp();
            performance_threshold_ms = 100; // Default 100ms threshold
            memory_threshold_kb = 1024;     // Default 1MB threshold
        }

        void ExpectPerformanceWithin(std::chrono::milliseconds threshold) {
            auto duration = GetTestDuration();
            EXPECT_LE(duration.count(), threshold.count()) 
                << "Test took " << duration.count() << "ms, expected <= " << threshold.count() << "ms";
        }

        void ExpectDefaultPerformance() {
            ExpectPerformanceWithin(std::chrono::milliseconds(performance_threshold_ms));
        }

    private:
        int performance_threshold_ms;
        int memory_threshold_kb;
    };

    // Stress test fixture
    class StressTestBase : public PerformanceTestBase {
    protected:
        void SetUp() override {
            PerformanceTestBase::SetUp();
            stress_iterations = 1000;
            stress_concurrency = 4;
        }

        void RunStressTest(std::function<void()> test_func) {
            for (int i = 0; i < stress_iterations; ++i) {
                ASSERT_NO_THROW(test_func()) << "Stress test failed at iteration " << i;
            }
        }

        int stress_iterations;
        int stress_concurrency;
    };

} // namespace TestFixtures