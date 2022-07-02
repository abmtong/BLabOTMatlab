function inst = procFranp4(inst, rAopts)
%kn versus pause?

len = length(inst);

%Set up ROIs
roirpt = [0 rAopts.nrep * rAopts.per];


for i = 1:len
    %Fit to staircase
    [~, ~, inst(i).tr] = pol_dwelldist_p1(inst(i).drA);
    hei = length(inst(i).tr);
    kn = zeros(1,hei);
    
    for j = 1:hei
        
        
    end
    %Fit dwells in repeat section to get kn. ..or just take median?
    
    %Compare to major dwells? Crossing time?
    
end