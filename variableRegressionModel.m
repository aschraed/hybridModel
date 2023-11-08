% from RPE page 605, lab tested grain (2in OD, .43in port dia),
%   rdot for HTPB = 0.104*G_o^.681 (English Units)

% from doran paper, rdot = .417*G_o^0.347 (rdot in mm/s and G_ox in g/cm^2*s)

% from Humble section on hybrid regression (page 381): "the boundary layer growth
% represented by x^m, which causes a decrease in heat flux, is balanced by
% the increase in G_total from burnt fuel"
%   x is axial position along the grain (injector side --> postCC)


% initial fuel grain dimensions
grain_length = 10; % in
grain_OD = 2; % in
port = 0.5; % in; diameter of the port
rho = 0.935; % g/cm^3

% Generating number of slices and time interval
dx = 0.01; % in
slices = grain_length/dx; % slicing grain into cylindrical segments

dt = .1;
time = 0;


% assuming constant mass flow of ox bc haven't integrated an injector or tank model yet
ini_gox = 45; % g/cm^2-s (IIRC, range of optimal flux is around 30-65 from Humble)
extrapolated_mdot_ox = ini_gox * (port/2)^2 *2.54^2; % g/s
mdot_ox = extrapolated_mdot_ox; % g/s


% initializing vectors for each slice of the grain
axial_position = linspace(0, grain_length, slices); % in; injector --> post
radius = ones(slices, 1) * port/2;
% g_ox = zeros(slices, 1); % g/cm^2-s; initializing with flux @ x=0
rdot = zeros(slices, 1);

% while max(radius) <= (grain_OD/2)
% 
% 
% end
 

[mass_burnt, radius] = regression(dx, dt, mdot_ox, radius, rho)