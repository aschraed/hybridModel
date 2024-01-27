% running this script will produce a GUI where you can enter the
% dimensions of the mold you are using, and lets you enter a
% user-overridden volume obtained from Solidworks if port geometry is
% complex

%% composition parameters
per_MDI = .14; % percentage of curative obtained from CurativeCalculation
per_R45 = 1 - per_MDI;

% densities of resin and curative from Rocket Motor Components TDS
rho_R45 = .901;  % g/cm^3
rho_MDI = 1.22;  % g/cm^3

%% cylindrical grain dimensions
prompt = {'SolidWorks Volume Override (Leave as 0 if inputting dimensions)'...
    'Effective Grain Length (in)', 'Mold OD (in, outermost wall)'...
    'Port ID (in)', 'Mold Thickness (cm)', 'Pouring Loss Factor (Scales Mass; Leave as 1 if no loss)'};
dlgtitle = 'Curative Calculation: Grain Dimensions';
dims = [1 70];
definput = {'0', '12', '2', '.5', '.12', '1'}; % Y/N, length, OD, portID, wall thickness, pouring loss factor
opts.Resize = 'on';
inputs = inputdlg(prompt, dlgtitle, dims, definput, opts);
inputs = str2double(inputs(1:6));

if (inputs(1) ~= 0) % checking if user override or not
    vol_cavity = inputs(1);  % cm^3, user overridden cavity volume
else
    % calculates the volume of the cavity by offsetting from the mold's OD
    % to find cavity OD, and offsetting from the port ID to find cavity ID
    eff_grain_length = inputs(2);    % in, total mold length minus the bottom platform
    mold_OD = inputs(3);    % in, diameter of the outermost wall
    mold_thickness = inputs(5);   % cm, wall thickness of the print
    port_ID = inputs(4); % in, inside diameter of the grain port
    pour_factor = inputs(6); % accounts for pouring losses
    
    cavity_OD = (mold_OD*2.54) - (2*mold_thickness);    % cm
    cavity_ID = (port_ID*2.54) + (2*mold_thickness);    % cm
    cavity_Area = (pi * ((cavity_OD/2)^2 - (cavity_ID/2)^2)); % cm^2
    vol_cavity = cavity_Area * (eff_grain_length*2.54);    % cm^3
end

%% mixture calculations
% calculates cured mass based on total density and given volume
rho_total = 1/(per_R45/rho_R45+per_MDI/rho_MDI);  % g/cm^3
mass_total = rho_total * vol_cavity * pour_factor;  % g

mass_R45 = per_R45 * mass_total;    % g
mass_PAPI = mass_total - mass_R45;  % g
xsave = [rho_total mass_total mass_R45 mass_PAPI];

fprintf('Combined Density: %.3f g/cm^3 \n', xsave(1))
fprintf('Total Mass: %.3f g \n', xsave(2))
fprintf('Mass Resin: %.3f g \n', xsave(3))
fprintf('Mass MDI: %.3f g \n', xsave(4))
% disp("Combined Density (g/cm^3), Total Mass (g), Mass Resin (g), Mass PAPI (g)")
% disp(xsave)

clear allclc