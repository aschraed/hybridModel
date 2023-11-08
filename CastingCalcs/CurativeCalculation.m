% Curative Calculation for HTPB resin and Modified MDI Isocyanate curative
% from Rocket Motor Components.
% Uses Equivalent weight calculations from http://www.thrustgear.com/topics/Curative_calculation.pdf
% Function of the curative is to link the hydroxyl compound (OH) of the
% binder with an isocyanate compound (NCO) of the curative.

% EW = Effective Weight listed on the MDSs
prompt = {'EW of Resin (OH Eq. Wt.): ', 'EW of Curative (NCO Eq. Wt): ', 'Index Ratio (0-1, 1 is full cure)'};
dlgtitle = 'Curative Calculation: Material Properties';
dims = [1 60];
definput = {'1219.5', '185', '1'};
opts.Resize = 'on';
inputs = inputdlg(prompt, dlgtitle, dims, definput, opts);
inputs = str2double(inputs(1:3));
% str2double converts the cell array from the dialog box into a vector

relativeHardness = inputs(3);
ewResin = inputs(1);
ewCurative = inputs(2);
massResin = 100;

% calc required mass of curative based on EW of OH and NCO
% percent of curative only dependent on Index Ratio, not mass of Resin
massCurative = relativeHardness * ewCurative * (massResin/ewResin);
proportionCurative = massCurative / (massCurative + massResin);
fprintf('Mass of Curative need: %.3f g\n', massCurative)
fprintf('Percent Curative: %.3f \n', proportionCurative*100)

% finding percent curative for small changes in index ratio
dIndRat = 1000;
indRatSave = linspace(0,1,dIndRat);
for n = 1:dIndRat
    
end

clear all