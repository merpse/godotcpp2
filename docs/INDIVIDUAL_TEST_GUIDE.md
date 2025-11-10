# 🧪 Running Individual C++ Unit Tests Guide

## Quick Steps to Run One Test

### **Step 1: Navigate to Tests Directory**
```bash
cd /Users/marimerpanganiban/Documents/workspace/godotcpp2/tests
```

### **Step 2: Build Tests (if not already built)**
```bash
cmake --build build
```

### **Step 3: Run Individual Tests**

#### **Method 1: Run Specific Test by Name (GoogleTest Filter)**
```bash
# Run just one test function
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.CreateBedWithEnumTypes"

# Run all tests in a test class
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.*"

# Run tests matching a pattern
./build/medical_equipment_tests --gtest_filter="*Factory*"
```

#### **Method 2: List All Available Tests**
```bash
# See all available test names
./build/medical_equipment_tests --gtest_list_tests
```

#### **Method 3: Run Tests with Detailed Output**
```bash
# Run with verbose output
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.CreateBedWithEnumTypes" --gtest_print_time=1
```

---

## 🎯 Available Test Categories

Based on your test setup:

### **Medical Equipment Tests** (`medical_equipment_tests`)
- **BedFactoryTest**: Factory pattern tests
- **PatientBedTest**: Patient bed functionality  
- **SurgicalBedTest**: Surgical bed features
- **BedBaseTest**: Abstract bed class tests
- **GodotBedFactoryTest**: Godot integration tests

### **Individual Test Functions** (examples):
- `BedFactoryTest.CreateBedWithEnumTypes`
- `BedFactoryTest.CreateBedWithStringTypes`  
- `BedFactoryTest.CreateBedCaseInsensitive`
- `PatientBedTest.InitialConfiguration`
- `SurgicalBedTest.EmergencyFeatures`

---

## 📋 Common Use Cases

### **Run One Specific Test Function**
```bash
cd tests
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.CreateBedCaseInsensitive"
```

### **Run All Factory Tests**
```bash
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.*"
```

### **Run All Tests with "Emergency" in Name**
```bash
./build/medical_equipment_tests --gtest_filter="*Emergency*"
```

### **Run Tests and Stop on First Failure**
```bash
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.*" --gtest_break_on_failure
```

---

## 🔍 Debugging Individual Tests

### **Run with Extra Verbose Output**
```bash
./build/medical_equipment_tests --gtest_filter="BedFactoryTest.CreateBedWithEnumTypes" --gtest_print_time=1 --gtest_print_utf8=1
```

### **Run Tests in Debug Mode (if built with debug)**
```bash
lldb ./build/medical_equipment_tests
(lldb) run --gtest_filter="BedFactoryTest.CreateBedWithEnumTypes"
```

---

## ⚡ Quick Commands

```bash
# Navigate to tests
cd /Users/marimerpanganiban/Documents/workspace/godotcpp2/tests

# List all tests to see what's available
./build/medical_equipment_tests --gtest_list_tests

# Run one specific test
./build/medical_equipment_tests --gtest_filter="TEST_NAME_HERE"

# Run all factory tests
./build/medical_equipment_tests --gtest_filter="*Factory*"
```

This gives you complete control over running individual C++ unit tests! 🎯