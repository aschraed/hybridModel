initial_CEA = readmatrix('cea2.csv');
%this is for optimization of 4500ft pressure

CEA = excel_to_num(initial_CEA);
%gets ride of excess pressure varialbes


CEA = optimal_CEA(CEA);
%coverts to a matrix without extraneous Exit variables







