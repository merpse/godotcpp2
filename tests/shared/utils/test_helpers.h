#pragma once
#include <gtest/gtest.h>
#include <string>
#include <cmath>
#include <vector>
#include <memory>

namespace TestHelpers {

    // Floating point comparison with tolerance
    bool FloatEquals(float a, float b, float tolerance = 1e-6f) {
        return std::abs(a - b) < tolerance;
    }

    bool DoubleEquals(double a, double b, double tolerance = 1e-10) {
        return std::abs(a - b) < tolerance;
    }

    // String comparison helpers
    bool StringContains(const std::string& haystack, const std::string& needle) {
        return haystack.find(needle) != std::string::npos;
    }

    bool StringStartsWith(const std::string& str, const std::string& prefix) {
        return str.substr(0, prefix.length()) == prefix;
    }

    bool StringEndsWith(const std::string& str, const std::string& suffix) {
        if (suffix.length() > str.length()) return false;
        return str.substr(str.length() - suffix.length()) == suffix;
    }

    // Case-insensitive string comparison
    bool StringEqualsIgnoreCase(const std::string& a, const std::string& b) {
        if (a.length() != b.length()) return false;
        
        for (size_t i = 0; i < a.length(); ++i) {
            if (std::tolower(a[i]) != std::tolower(b[i])) {
                return false;
            }
        }
        return true;
    }

    // Vector comparison utilities
    template<typename T>
    bool VectorContains(const std::vector<T>& vec, const T& item) {
        return std::find(vec.begin(), vec.end(), item) != vec.end();
    }

    template<typename T>
    bool VectorsEqual(const std::vector<T>& a, const std::vector<T>& b) {
        if (a.size() != b.size()) return false;
        return std::equal(a.begin(), a.end(), b.begin());
    }

    // Exception testing helpers
    template<typename ExceptionType, typename Func>
    bool ThrowsException(Func&& func) {
        try {
            func();
            return false;
        } catch (const ExceptionType&) {
            return true;
        } catch (...) {
            return false;
        }
    }

    template<typename Func>
    bool DoesNotThrow(Func&& func) {
        try {
            func();
            return true;
        } catch (...) {
            return false;
        }
    }

    // Memory testing helpers
    template<typename T>
    bool IsValidPointer(T* ptr) {
        return ptr != nullptr;
    }

    template<typename T>
    bool IsValidUniquePtr(const std::unique_ptr<T>& ptr) {
        return ptr != nullptr;
    }

    template<typename T>
    bool IsValidSharedPtr(const std::shared_ptr<T>& ptr) {
        return ptr != nullptr;
    }

    // Range checking helpers
    template<typename T>
    bool IsInRange(T value, T min, T max) {
        return value >= min && value <= max;
    }

    // Timeout testing helper
    class TimeoutHelper {
    private:
        std::chrono::steady_clock::time_point start_time;
        std::chrono::milliseconds timeout_duration;

    public:
        TimeoutHelper(std::chrono::milliseconds timeout) 
            : start_time(std::chrono::steady_clock::now()), timeout_duration(timeout) {}

        bool HasTimedOut() const {
            auto now = std::chrono::steady_clock::now();
            auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time);
            return elapsed >= timeout_duration;
        }

        std::chrono::milliseconds GetElapsed() const {
            auto now = std::chrono::steady_clock::now();
            return std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time);
        }
    };

    // Test result aggregation
    struct TestResults {
        int passed = 0;
        int failed = 0;
        int skipped = 0;
        std::vector<std::string> failure_messages;

        void AddPass() { passed++; }
        void AddFailure(const std::string& message) {
            failed++;
            failure_messages.push_back(message);
        }
        void AddSkip() { skipped++; }

        int GetTotal() const { return passed + failed + skipped; }
        bool AllPassed() const { return failed == 0 && skipped == 0; }
        double GetPassRate() const {
            int total = GetTotal();
            return total > 0 ? static_cast<double>(passed) / total : 0.0;
        }
    };

} // namespace TestHelpers

// Convenient macros for testing
#define EXPECT_FLOAT_EQ_TOL(a, b, tol) EXPECT_TRUE(TestHelpers::FloatEquals(a, b, tol))
#define EXPECT_DOUBLE_EQ_TOL(a, b, tol) EXPECT_TRUE(TestHelpers::DoubleEquals(a, b, tol))
#define EXPECT_STRING_CONTAINS(haystack, needle) EXPECT_TRUE(TestHelpers::StringContains(haystack, needle))
#define EXPECT_STRING_STARTS_WITH(str, prefix) EXPECT_TRUE(TestHelpers::StringStartsWith(str, prefix))
#define EXPECT_STRING_ENDS_WITH(str, suffix) EXPECT_TRUE(TestHelpers::StringEndsWith(str, suffix))
#define EXPECT_STRING_EQ_IGNORE_CASE(a, b) EXPECT_TRUE(TestHelpers::StringEqualsIgnoreCase(a, b))
#define EXPECT_VECTOR_CONTAINS(vec, item) EXPECT_TRUE(TestHelpers::VectorContains(vec, item))
#define EXPECT_VALID_PTR(ptr) EXPECT_TRUE(TestHelpers::IsValidPointer(ptr))
#define EXPECT_VALID_UNIQUE_PTR(ptr) EXPECT_TRUE(TestHelpers::IsValidUniquePtr(ptr))
#define EXPECT_IN_RANGE(value, min, max) EXPECT_TRUE(TestHelpers::IsInRange(value, min, max))