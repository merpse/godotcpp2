#ifndef PATIENT_BED_H
#define PATIENT_BED_H

#include "bed.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

// Observer pattern for occupancy detection
class OccupancyObserver {
public:
    virtual ~OccupancyObserver() = default;
    virtual void onPatientEntered() = 0;
    virtual void onPatientLeft() = 0;
};

// Occupancy sensor using Observer pattern
class OccupancySensor {
private:
    bool isOccupied;
    std::vector<OccupancyObserver*> observers;
    
public:
    OccupancySensor() : isOccupied(false) {}
    
    void addObserver(OccupancyObserver* observer) {
        observers.push_back(observer);
    }
    
    void removeObserver(OccupancyObserver* observer) {
        observers.erase(
            std::remove(observers.begin(), observers.end(), observer),
            observers.end()
        );
    }
    
    void setOccupied(bool occupied) {
        if (isOccupied != occupied) {
            isOccupied = occupied;
            
            if (occupied) {
                notifyPatientEntered();
            } else {
                notifyPatientLeft();
            }
        }
    }
    
    bool getOccupied() const { return isOccupied; }

private:
    void notifyPatientEntered() {
        for (auto* observer : observers) {
            if (observer) {
                observer->onPatientEntered();
            }
        }
    }
    
    void notifyPatientLeft() {
        for (auto* observer : observers) {
            if (observer) {
                observer->onPatientLeft();
            }
        }
    }
};

// PatientBed class implementing specific functionality
class PatientBed : public Bed, public OccupancyObserver {
    GDCLASS(PatientBed, Bed)

private:
    std::unique_ptr<OccupancySensor> occupancySensor;
    bool comfortMode;
    float lastOccupancyTime;

public:
    PatientBed();
    virtual ~PatientBed() = default;

    // Override base class methods
    std::string getClassName() const override;
    
    // PatientBed specific functionality
    void simulatePatientEntry();
    void simulatePatientExit();
    bool isOccupied() const;
    void enableComfortMode();
    void disableComfortMode();
    bool isComfortModeEnabled() const { return comfortMode; }
    
    // Occupancy observer implementation
    void onPatientEntered() override;
    void onPatientLeft() override;

protected:
    // Override hook methods from base class
    void performSpecificChecks() override;
    void onPowerOn() override;
    void onPowerOff() override;
    
    static void _bind_methods();

private:
    void adjustForPatientComfort();
    void resetToDefaultSettings();
};

#endif // PATIENT_BED_H