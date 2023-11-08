% thermophysical properties of nitrous on the saturation line white paper
% range of applicability: -90C to 36C (-130F to 96.8F)
% can only model based on temperature (since equations are based off temp, 
% too complex to derive temp from pressure, etc)

function [N2O] = NitrousProperties(absTemp)

%% polynomial expressions for thermodynamic properties
% constants listed as elements in the matrix

% critical point: temp(K), density (kg/m^3), pressure (kPa)
critPnt = [309.57 452 7251];

% vapor pressure(kPa), density of liquid(kg/m^3), density of vapor(kg/m^3)
vapPressure = [-6.7189 1.35966 -1.3779 -4.051];
rhoL = [1.72328 -0.83950 0.51060 -0.10412];
rhoV = [-1.009 -6.28792 7.50332 -7.90463 0.629427];

% specific enthalpy of saturated liquid(kJ/kg) and vapor(kJ/kg)
hL = [-200 116.043 -917.225 794.779 -589.587];
hV = [-200 440.055 -459.701 434.081 -485.338];

% isobaric specific heat capacity of saturated liquid and vapor(kJ/kg*K)
% Assumes that the process is slow enough that deltaP is minimal and the 
% system maintains quasi-equilibrium, and the vapor and liquid states are
% the same temperature.
% Nitrous blowdown is very dynamic, so this assumption would probably fall
% apart, and you would need a very complex heat transfer model to account
% for localized anomalies like the surface of the liquid.

cL = [2.49973 0.023454 -3.80136 13.0945 -14.5180]; 
cV = [132.632 0.052187 -0.364923 -1.20233 0.536141];

%% calculating properties using white paper equations
Tr = absTemp/critPnt(1);
vaporPressure = critPnt(3)*exp((1/Tr)*(vapPressure(1)*(1-Tr) + vapPressure(2)*(1-Tr)^(3/2) + vapPressure(3)*(1-Tr)^(5/2) + vapPressure(4)*(1-Tr)^(5)));
liquidDensity = critPnt(2)*exp(rhoL(1)*(1-Tr)^(1/3) + rhoL(2)*(1-Tr)^(2/3) + rhoL(3)*(1-Tr) + rhoL(4)*(1-Tr)^(4/3));
vaporDensity = critPnt(2)*exp(rhoV(1)*(1/Tr-1)^(1/3) + rhoV(2)*(1/Tr-1)^(2/3) + rhoV(3)*(1/Tr-1) + rhoV(4)*(1/Tr-1)^(4/3) + rhoV(5)*(1/Tr-1)^(5/3));
hVaporization = (hV(1)-hL(1)) + (hV(2)-hL(2))*(1-Tr)^(1/3) + (hV(3)-hL(3))*(1-Tr)^(2/3) + (hV(4)-hL(4))*(1-Tr) + (hV(5)-hL(5))*(1-Tr)^(4/3);
liquidSpecHeat = cL(1)*(1 + cL(2)*(1-Tr)^(-1) + cL(3)*(1-Tr) + cL(4)*(1-Tr)^2 + cL(5)*(1-Tr)^3);
vaporSpecHeat = cV(1)*(1 + cV(2)*(1-Tr)^(-2/3) + cV(3)*(1-Tr)^(-1/3) + cV(4)*(1-Tr)^(1/3) + cV(5)*(1-Tr)^(2/3));

% [kg/m^3, kg/m^3, psi, kJ/kg, kJ/kg*K, kJ,kg*K]
N2O = [liquidDensity vaporDensity vaporPressure/6.89475 hVaporization liquidSpecHeat vaporSpecHeat];

end