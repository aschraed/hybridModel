function [mass_burnt, radius] = regression(dx, dt, mdot_ox, radius, rho)
% Regression rate from the 'Nitrous Oxide Hybrid Rocket Motor Fuel Regression
% Rate Characterization Paper'
% Note: Assumes that Gox is in g/cm^2-s, radius is inputted in inches, and
% regression rate is in mm/s

% ballistic coefficients from Doran Paper
a = 0.417;
n = 0.347;

radius = radius * 25.4; % in to mm
mass_burnt = zeros(length(radius), 1);

for ii = 1:length(radius)
    % regression rate calculation
    Gox = mdot_ox / (radius(ii)/2)^2;
    rdot = a*Gox^n; % mm/s

    % updating radius based on how much fuel regresses and finds how much
    % is burnt away based on the diff in radii
    radius_old = radius(ii);
    radius(ii) = radius(ii) + rdot*dt;
    mass_burnt(ii) = pi*(radius(ii)^2 - radius_old^2)*dx*rho; % pi*r^2h * rho
end

mass_burnt = sum(mass_burnt);
radius = radius / 25.4;

end