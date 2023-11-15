clc, clearvars
ChamberPressure=input('Chamber Pressure');
Maxstress=input('Max stress');
SafetyFactor=input('Saftey Factor');
Radius=input('Radius');
Thickness=(SafetyFactor*ChamberPressure*Radius)/(Maxstress)
MEOP=input('Maximum Expected Operating Pressure');
SafetyFactorBolt=input('Safety factor for bolt shear');

