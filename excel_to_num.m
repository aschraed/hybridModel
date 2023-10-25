function [CEA] = excel_to_num(initial_CEA)
    [~, nColm] = size(initial_CEA); %sizes the CEA
   %need to figure out how big the final CEA matrix needs to be
   nRows = 0;
   exit_rows = 0;

   for i = 1:7:length(initial_CEA)-7
       nRows = nRows+2; %rows for chamber and exit pressure
       for j = i+2:i+6
           if abs(0.8115129334-initial_CEA(j,1))<0.05 %condition statement for 4500ft pressure
               exit_rows = exit_rows+1; %rows for exit pressure
           end
       end
   end

   nRows = nRows + exit_rows;
   CEA = zeros(nRows,nColm); %actual length of the CEA
   exit_pres_rows = zeros(exit_rows,nColm);
   iter_num = 1;

for i = 1:7:length(initial_CEA)-7
    for j = i+2:i+6
        if abs(0.8115129334-initial_CEA(j,1))<0.05
            exit_pres_rows(iter_num,:) = initial_CEA(j,:); %creates the rows of the exit pressure importance
        end
    end
    iter_num = iter_num + 1;
end

iter_num = 1;

for i = 1:3:length(CEA)-3
    CEA(i+2,:) = exit_pres_rows(iter_num,:); %adds the exit pressure rows into the CEA
    iter_num = iter_num +1;
end

iter_num = 1;
for i = 1:7:length(initial_CEA)-7
    CEA(iter_num,:) = initial_CEA (i,:); %chamber variables
    CEA(iter_num+1,:) = initial_CEA(i+1,:); %throat variables
    iter_num = iter_num+3;
end

%{
This function works, basically what it does is it takes all of the CEA 
outputs and narrows it down to the varialbes with the correct numbers that
we actually care about: the chamber, throat, and optimal exit pressure.
%}
return




           

       


