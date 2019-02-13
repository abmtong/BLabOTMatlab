function scaleFCsMoff

%how do I get mirror X?
%load stepdata

%get fax, fay, etc.

%get fc indicies


len = length(keepind);
for i = 1:len

    mx = extension - stepdata.forceAX/stepdata.cal.AX.k +  stepdata.forceBX/stepdata.cal.BX.k;
    posx = mean(mx);

    

