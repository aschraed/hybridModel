%%there are going to be inputs that are calculated from CEA
%{
Outputs include: CSTAR, AREA Ratio, Specific Heat (Throat & Exit)
Gamma(Throat & Exit), Molecular Weight (Throat & Exit), Thrust Coeffecient
(Throat & Exit)

Inputs not from CEA input: Propellant flow rate, chamber pressure, ambient
Pressure, Tc (Combustion Chamber chamber flame temperature), Gas Constant
%}

%creates a dialogue box asking for the given values
prompt = {'ṁ_p','P_{c}','P_{\infty}','T_{c}','R',};
dlgtitle = 'Assumed Variables';
fieldsize = [1 45; 1 45; 1 45; 1 45; 1 45];
definput = {'2', '300', '17.4', '2000', '0.1889'};
opts.Interpreter = 'tex';
x = inputdlg(prompt, dlgtitle, fieldsize, definput,opts);
%converts the string array created into a vector with real numbers
givens = str2double(x);

%create a dialogue box for the CEA numbers
prompt = {'c*', '\epsilon','\gamma_e','\gamma_t','k_e','k_t','M_t','M_e', 'Ct_{throat}','Ct_{exit}','T_t'};
dlgtitle = 'CEA Inputs';
fieldsize = [ones(11,1) 45*ones(11,1)];
definput = {'2', '0.75', '1.2', '1.7', '1.8', '1.9', '30', '40','20', '30','3000'};
y = inputdlg(prompt,dlgtitle, fieldsize,definput,opts);
% converts the string array into the doubles
CEA = str2double(y);

%this part of the program is going to calculate the mass-flow propellant
Thrust = 100; %Assumed Thrust, we have to determine this
c = 75; %exhaust velocity, in CEA, but we will output it here for now
noz_eff = 0.95; %nozzle effiency of a conical nozzle
mdot_p = Thrust/(noz_eff*c);


%Throat Area Calculations
c_star = CEA(1);
P_c = givens(2);
Area_Throat = mdot_p*c_star/P_c;

%Throat Radius
rad_throat = sqrt(Area_Throat/pi);

%Nozzle Exit Area
Area_Ratio = CEA(2);
Area_Exit = Area_Ratio*Area_Throat;

%Exit Radius
rad_exit = sqrt(Area_Exit/pi);

%Nozzle Length
alpha = 15; %angle against the verticle for conical nozzles
noz_length = (0.5*(rad_exit*2-rad_throat*2))/tan(alpha);

%Exit Mach
p_exit = givens(3);
gamma_exit = CEA(3);
mach_exit = sqrt((2/(gamma_exit-1))*((P_c/p_exit)^((gamma_exit-1)/gamma_exit)-1));

%Throat Pressure
gamma_throat = CEA(4);
pressure_throat = P_c*(2/(gamma_throat-1))^(gamma_throat/(gamma_throat-1));

%Exit Pressure
pressure_exit = pressure_throat*(1+((gamma_exit-1)/2*mach_exit^2)^(-gamma_exit/(gamma_exit-1)));

%Exit Velocity
spec_heat_exit = CEA(5);
molar_weight_exit = CEA(8);
R = givens(5);
tc = givens(4);
multiple1 = 2*spec_heat_exit/(spec_heat_exit-1);
multiple2 = R*tc/molar_weight_exit;
multiple3 = 1-(pressure_exit/P_c)^((spec_heat_exit-1)/spec_heat_exit);
velocity_exit = sqrt(multiple1*multiple2*multiple3);


