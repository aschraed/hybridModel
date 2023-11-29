clc, clearvars
%Safety Factors
FS_tear_out=input('Safety Factor bolt tear out');
FS_Hoop_stress=input('Safety Factor hoop stress');
FS_bolt_shear=input('Safety Factor bolt shear');
FS_BYS=input('Safety Factor bearing yeild strength');

%Some inputs we should already know
chamberpressure=input('Chamber Pressure');
radius=input('radius of chamber');
diameter=radius*2;
Shear_strength=input('Shear strength of material');
UTS=input('Ultimate Tensile Strength of material');
Max_vessel_stress=input('Maximum stress allowed for material');
MEOP=input('Maxmium Expected Operating Pressure');
BYS=input('Bearing Yield Strength of material');
%Calculating Thickness
Thickness=((FS_Hoop_stress)*(chamberpressure)*(radius))/(Max_vessel_stress);
%Calculating minor diameter of bolt
diameter_minor=((1.5)*(2*Thickness)*(FS_bolt_shear))/((FS_tear_out)*(pi/4)*(0.75)*(UTS));
%Calculating Number of bolts
Number_of_bolts=((pi/4)*(diameter^2)*(MEOP)*(FS_tear_out))/((1.5*diameter_minor)*(2*Thickness)*(Shear_strength));
%Calculating Force on each bolt
Fbolt=((1.5)*(diameter_minor)*(2*Thickness)*(Shear_strength))/(FS_tear_out);
%Calculating major diameter of bolt
diameter_major=((FS_BYS)*(Fbolt))/((BYS)*(Thickness));








