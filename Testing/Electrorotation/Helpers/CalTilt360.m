function out = CalTilt360(ined, inOpts)
%Processes rotating CalTilt
%Assumes dTheta = 6 deg, the only value tried
%Works by splitting data by theta, running CalTilt on that data subsection (spoof eldata)

dth = 6;
%4hz, 10 repetitions = 2.5s each dwell, * 60 positions = 150 second for full rotation

if nargin < 1
    [f,p] = uigetfile('*.mat');
    pf = [p f];
    ined = load(pf);
    ined = ined.eldata;
end

len = length(ined.rotlong);
npd = 10/4*4000; %pts per angle step
n = floor(len/npd);

tilts = cell(1,n);
for i = 1:n
    %Grab part
    if i == n
        ki = npd*i+1:len;
    else
        ki = npd*(i-1)+1:npd*i;
    end
    %Trim eldata
    teld = ined;
    %Only rotlong is used, so just crop rotlong
    teld.rotlong = teld.rotlong(ki);
    %CalTilt
    tilts{i} = CalTilt(teld);
    
    %Plot somehow
    
end