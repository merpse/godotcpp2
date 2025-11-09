#pragma once

// Mock Godot classes for testing
// This allows us to test our CustomWindow without requiring full Godot runtime

#ifdef TESTING_MODE

#include <string>
#include <iostream>

// Mock Godot namespace
namespace godot {

    // Forward declaration
    class String;

    // Mock String class - declare first since Node uses it
    class String {
    private:
        std::string str;
        
    public:
        String() = default;
        String(const char* s) : str(s) {}
        String(const std::string& s) : str(s) {}
        
        const char* c_str() const { return str.c_str(); }
        std::string std_string() const { return str; }
        
        // Add length method that tests expect
        size_t length() const { return str.length(); }
        
        operator std::string() const { return str; }
    };

    // Mock Node class
    class Node {
    public:
        Node() = default;
        virtual ~Node() = default;
        
        virtual void _ready() {}
        static void _bind_methods() {}
        
        // Add methods that tests expect
        String get_name() const { return String("MockNode"); }
        void add_child(Node* child) { /* Mock implementation */ }
        void remove_child(Node* child) { /* Mock implementation */ }
    };

    // Mock UtilityFunctions
    class UtilityFunctions {
    public:
        static void print(const std::string& message) {
            std::cout << "[MOCK PRINT] " << message << std::endl;
        }
    };

    // Mock ClassDB
    class ClassDB {
    public:
        template<typename T>
        static void register_class() {
            // Mock registration
        }
        
        template<typename T>
        static void bind_method(const char* name, T method) {
            // Mock method binding
        }
        
        // Overload for three parameters
        template<typename T>
        static void bind_method(const char* class_name, const char* method_name, T method) {
            // Mock method binding for class/method/pointer combination
        }
    };

    // Mock GDCLASS macro
    #define GDCLASS(class_name, base_class) \
        public: \
            typedef base_class Super; \
            static const char* get_class_static() { return #class_name; } \
            virtual const char* get_class() const override { return #class_name; }

    // Mock PropertyInfo
    struct PropertyInfo {
        int type;
        String name;
        
        PropertyInfo(int t, const String& n) : type(t), name(n) {}
    };

    // Mock Variant types
    namespace Variant {
        enum Type {
            NIL,
            STRING,
            INT,
            FLOAT,
            BOOL
        };
    }

} // namespace godot

#endif // TESTING_MODE