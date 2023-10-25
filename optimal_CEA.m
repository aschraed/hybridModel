function CEA = optimal_CEA(initial_CEA)
of = initial_CEA(:,2);
temp = initial_CEA(:,3);
idx = [];

for i = 1:3:length(initial_CEA)
    for j = i:i+2
        if (of(j)<5) %o/f ratio limit
            for k = i:i+2
                idx = [idx,k]; %saves index of the set of variables to be deleted
            end
            break
        elseif temp(j)>3500 %temp limit
            for k = i:i+2
                idx = [idx,k]; %same idx as earlier
            end
            break
        end
    end
end



initial_CEA(idx,:) =[]; %deletes variable sets that we don't want
CEA = initial_CEA;
          
           
            
            


