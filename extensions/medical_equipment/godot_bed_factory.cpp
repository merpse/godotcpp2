#include "godot_bed_factory.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

// Define bed type constants
const int PATIENT_BED_TYPE = 0;
const int SURGICAL_BED_TYPE = 1;

BedFactory::BedFactory() {
    UtilityFunctions::print("🏭 BedFactory initialized");
}

BedFactory::~BedFactory() {
}

void BedFactory::_bind_methods() {
    // Bind factory methods
    ClassDB::bind_method(D_METHOD("create_bed_by_type", "bed_type"), &BedFactory::create_bed_by_type);
    ClassDB::bind_method(D_METHOD("create_patient_bed"), &BedFactory::create_patient_bed);
    ClassDB::bind_method(D_METHOD("create_surgical_bed"), &BedFactory::create_surgical_bed);
    ClassDB::bind_method(D_METHOD("get_available_bed_types"), &BedFactory::get_available_bed_types);
    ClassDB::bind_method(D_METHOD("get_bed_type_name", "bed_type"), &BedFactory::get_bed_type_name);
    
    // Bind integer constants instead of enum
    ClassDB::bind_integer_constant(get_class_static(), "", "PATIENT", PATIENT_BED_TYPE);
    ClassDB::bind_integer_constant(get_class_static(), "", "SURGICAL", SURGICAL_BED_TYPE);
}

Bed* BedFactory::create_bed_by_type(int bed_type) {
    switch (bed_type) {
        case PATIENT_BED_TYPE:
            return create_patient_bed();
        case SURGICAL_BED_TYPE:
            return create_surgical_bed();
        default:
            UtilityFunctions::print("❌ Unknown bed type: ", bed_type, " - creating PatientBed as default");
            return create_patient_bed();
    }
}

Bed* BedFactory::create_patient_bed() {
    UtilityFunctions::print("🛏️ Creating PatientBed via BedFactory");
    PatientBed* bed = createPatientBedInternal();
    if (bed) {
        // Add the bed as a child to the factory for proper scene tree management
        add_child(bed);
    }
    return bed;
}

Bed* BedFactory::create_surgical_bed() {
    UtilityFunctions::print("🔬 Creating SurgicalBed via BedFactory");
    SurgicalBed* bed = createSurgicalBedInternal();
    if (bed) {
        // Add the bed as a child to the factory for proper scene tree management
        add_child(bed);
    }
    return bed;
}

PackedStringArray BedFactory::get_available_bed_types() {
    PackedStringArray types;
    types.push_back("Patient Bed");
    types.push_back("Surgical Bed");
    return types;
}

String BedFactory::get_bed_type_name(int bed_type) {
    switch (bed_type) {
        case PATIENT_BED_TYPE:
            return "Patient Bed";
        case SURGICAL_BED_TYPE:
            return "Surgical Bed";
        default:
            return "Unknown Bed Type";
    }
}

PatientBed* BedFactory::createPatientBedInternal() {
    PatientBed* bed = memnew(PatientBed);
    bed->set_name("PatientBed");
    return bed;
}

SurgicalBed* BedFactory::createSurgicalBedInternal() {
    SurgicalBed* bed = memnew(SurgicalBed);
    bed->set_name("SurgicalBed");
    return bed;
}