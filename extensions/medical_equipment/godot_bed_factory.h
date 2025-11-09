#ifndef GODOT_BED_FACTORY_H
#define GODOT_BED_FACTORY_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "bed.h"
#include "patient_bed.h"
#include "surgical_bed.h"

using namespace godot;

/**
 * @class BedFactory
 * @brief Godot-compatible factory class for creating medical beds
 */
class BedFactory : public Node {
    GDCLASS(BedFactory, Node)

public:
    BedFactory();
    ~BedFactory();

    // Factory methods callable from GDScript
    Bed* create_bed_by_type(int bed_type);
    Bed* create_patient_bed();
    Bed* create_surgical_bed();
    
    // Utility methods
    PackedStringArray get_available_bed_types();
    String get_bed_type_name(int bed_type);

protected:
    static void _bind_methods();

private:
    // Internal factory logic
    PatientBed* createPatientBedInternal();
    SurgicalBed* createSurgicalBedInternal();
};

#endif // GODOT_BED_FACTORY_H