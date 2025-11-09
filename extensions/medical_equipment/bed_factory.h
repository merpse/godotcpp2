#pragma once
#include "bed.h"

/**
 * @class BedFactory
 * @brief Factory class for creating different types of medical beds using the Factory design pattern
 */
class BedFactory {
public:
    enum class BedType {
        PATIENT,
        SURGICAL
    };

    /**
     * Creates a specific type of bed
     * @param type The type of bed to create
     * @return Unique pointer to the created bed
     */
    static std::unique_ptr<Bed> createBed(BedType type);

    /**
     * Creates a bed from string specification
     * @param bedTypeName String name of the bed type
     * @return Unique pointer to the created bed
     */
    static std::unique_ptr<Bed> createBedFromString(const std::string& bedTypeName);

    /**
     * Get all available bed types
     * @return Vector of available bed type names
     */
    static std::vector<std::string> getAvailableBedTypes();

private:
    /**
     * Convert string to BedType enum
     * @param typeName String representation of bed type
     * @return Corresponding BedType enum value
     */
    static BedType stringToBedType(const std::string& typeName);
};