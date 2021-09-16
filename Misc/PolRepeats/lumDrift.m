function out = lumDrift(iny, inpau)
%Tries to mitigate drift, models it as a constant change over time, requires input data (iny) and a region that should be flat (inpau)

%Meant to be used as: Make two crops per trace, one of the trace and one of a pause (i.e. a section that should be flat) to characterize the drift
% For traces that don't have a valid section, make a second crop over a <10s section of trace -- this code will ignore it

Fs = 3125;
tmin = 10;

len = length(iny);

out = cell(1,len);

figure, hold on
for i = 1:len
    pau = inpau{i};
    
    %Check for length
    if length(pau) < tmin*Fs
        out{i} = [];
        continue
    end
    x = (1:length(pau))/Fs;
    
    pf = polyfit( x , pau, 1 );
    
    %Check fitting
    plot(x,pau), hold on, plot(x, polyval(pf, x));
    
    %Make Y-intercept zero
    out{i} = iny{i} - pf(1) * (1:length(iny{i}))/Fs;
end
