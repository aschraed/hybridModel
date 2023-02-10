%% Parameters
% assumes the nitrous is in thermodynamic equilibrium, so using a set
% temperature, can simulate how the properties change over time
% Also, assumes constant flow rate since I don't have an injector model/data yet
% and a predetermined mass of oxidizer in the tank
% Also don't have dimensions for the nitrous tank yet

dt = .01;    % seconds
tmax = 30;  % seconds
volTank = 0.055253077; % m^3
initialTemperature = 293;   % K
totalMass = 40.04;  % kg
oxFlowRate = 2; % kg/s

% mass [liquid & vapor mass(kg), mass vaporized(kg)]
% state [ullage(%), temp(K), pressure(kPa)]
% volLG [liquid & vapor volume(m^3)]
t = linspace(0, tmax, tmax/dt);
mass = zeros(3, length(t));
state = zeros(3, length(t));
volLG = zeros(2, length(t));

%% Initial Conditions
% Using iniTemp, uses thermodynamic properties at that state to calculate
% the starting mass of both liquid and vapor based on 
% Law of Conservation of Mass and Volume

% N2O [liqDensity, vapDensity, vapPressure, hVap, liqSpecHeat, vapSpecHeat]
N2O = NitrousProperties(initialTemperature);
mass(1) = (totalMass-volTank*N2O(2)) / (1-N2O(2)/N2O(1));
mass(2) = totalMass - mass(1);
state(:,1) = [(mass(2) / (N2O(2)*volTank)), initialTemperature, N2O(3)];
volLG(:,1) = [mass(1)/N2O(1), mass(2)/N2O(2)];

%% simulation @ t = 0
% when ox leaves tank, some empty volume is left, so some of the remaining
% liquid vaporizes to restore the equilibrium pressure.
% Temperature of the mixture drops from vaporization, and using spec
% heats, can find the temperature change and then the new properties for
% the next iteration.

for n = 2:length(t)
    volumeEmptied = oxFlowRate*dt / N2O(1);
    mass(3,n) = volumeEmptied * N2O(2);
    state(2,n) = state(2,n-1) - (N2O(4)*mass(3,n-1) / (mass(1,n-1)*N2O(5) + mass(2,n-1)*N2O(6)));
    N2O = NitrousProperties(state(2,n));
    volLG(:,n) = [(volLG(1,n-1)-volumeEmptied), (volLG(2,n-1)+volumeEmptied)];
    mass(1:2,n) = [volLG(1,n)*N2O(1), volLG(2,n)*N2O(2)];
    state(1,n) = mass(2,n) / (N2O(2)*volTank);
    state(3,n) = N2O(3);
    
    if (state(1,n) >= 1) || (mass(1,n) <= 0)
        vaporPhaseTime = n;
        break
    end
end

figure;
subplot(221)
plot(t(1:vaporPhaseTime), state(3,1:vaporPhaseTime))
xlabel('Time(seconds)')
ylabel('Pressure(kPa)')
title('Pressure Drop of Nitrous Tank')

subplot(222)
plot(t(1:vaporPhaseTime), state(2,1:vaporPhaseTime))
xlabel('Time(seconds)')
ylabel('Temperature(K)')
title('Temperature Drop of Nitrous Tank')

subplot(223)
plot(t(1:vaporPhaseTime), mass(1,1:vaporPhaseTime), t(1:vaporPhaseTime), mass(2,1:vaporPhaseTime))
xlabel('Time(seconds)')
ylabel('Mass(kg)')
title('Temperature Drop of Nitrous Tank')
legend('Liquid mass','Vapor mass')