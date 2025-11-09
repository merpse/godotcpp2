# Medical Equipment Extension Design

## Requirements Analysis

### Objects to Implement:
1. **Bed** (Base class)
2. **PatientBed** (Inherits from Bed)
3. **SurgicalBed** (Inherits from Bed)
4. **LightStrip** (Component - Strategy pattern)
5. **Scanner** (Component for SurgicalBed)
6. **VitalSignMonitor** (Component for SurgicalBed)
7. **ScannerDevice** (Composite device with scanner + monitor)

### Design Patterns to Use:
- **Template Method Pattern** - For common bed operations
- **Strategy Pattern** - For light behaviors and temperature control
- **Composite Pattern** - For complex devices
- **Observer Pattern** - For emergency alerts and monitoring
- **Factory Pattern** - For creating different bed types

### Features:
- Height adjustment (all beds)
- Temperature control (all beds)
- Light strip management (all beds)
- Occupancy detection (patient bed)
- Scanner/monitor system (surgical bed)
- Emergency alert system
- Swivel functionality (surgical bed)