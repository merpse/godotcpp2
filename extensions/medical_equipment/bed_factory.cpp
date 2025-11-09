#include "bed_factory.h"
#include "patient_bed.h"
#include "surgical_bed.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <algorithm>

using namespace godot;

std::unique_ptr<Bed> BedFactory::createBed(BedType type) {
    switch (type) {
        case BedType::PATIENT:
            UtilityFunctions::print("🏥 Creating PatientBed");
            return std::make_unique<PatientBed>();
            
        case BedType::SURGICAL:
            UtilityFunctions::print("🏥 Creating SurgicalBed");
            return std::make_unique<SurgicalBed>();
            
        default:
            UtilityFunctions::print("❌ Unknown bed type, creating PatientBed as default");
            return std::make_unique<PatientBed>();
    }
}

std::unique_ptr<Bed> BedFactory::createBedFromString(const std::string& bedTypeName) {
    BedType type = stringToBedType(bedTypeName);
    return createBed(type);
}

std::vector<std::string> BedFactory::getAvailableBedTypes() {
    return {
        "patient_bed",
        "surgical_bed"
    };
}

BedFactory::BedType BedFactory::stringToBedType(const std::string& typeName) {
    std::string lowerTypeName = typeName;
    
    // Convert to lowercase for case-insensitive comparison
    std::transform(lowerTypeName.begin(), lowerTypeName.end(), lowerTypeName.begin(),
                   [](unsigned char c) { return std::tolower(c); });
    
    if (lowerTypeName == "patient_bed" || lowerTypeName == "patient" || lowerTypeName == "patientbed") {
        return BedType::PATIENT;
    } else if (lowerTypeName == "surgical_bed" || lowerTypeName == "surgical" || lowerTypeName == "surgery" || lowerTypeName == "surgicalbed") {
        return BedType::SURGICAL;
    } else {
        UtilityFunctions::print("⚠️  Unknown bed type: ", typeName.c_str(), " - defaulting to PatientBed");
        return BedType::PATIENT;
    }
}