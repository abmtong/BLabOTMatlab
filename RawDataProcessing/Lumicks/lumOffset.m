function out = lumOffset(infp)

if nargin < 1
    [f, p] = uigetfile('*.h5');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

binsz= .05; %um: eg HiRes offsets are .04um difference

%If infp is dat, accept it
if isstruct(infp)
    dat = infp;
else
    %Read dat
    dat = readh5all(infp);
end

%% First: find conversion from trap pos to distance

%Extract fields to use

%Get camera tracking stuff
camt= double(dat.Distance_Distance1.Timestamp)/1e9; %Timestamp is an int in nanoseconds
camt = camt - camt(1);
cam = dat.Distance_Distance1.Value; %Is it always Distance1 with Distance2 being 0?
%Get mirror values. Assume movement is along x.
mir = dat.Trapposition_N1X;
mirt= (0:length(mir)-1)/78125; %Fs is 78125Hz
%Downsample mirror to 625Hz, lower but still larger than the 100Hz camera
mirf = windowFilter(@mean, mir, [], 5^3);
mirtf = windowFilter(@mean, mirt, [], 5^3);

%Downsample mirror values to camera values
mirc = interp1(mirtf, mirf, camt, 'linear', 'extrap');

%Find linear relation between mirc and cam
mirconv = polyfit(mirc, cam, 1);

%Convert 
dist = polyval(mirconv, mir);

%% Second: get force offsets
frc = {dat.ForceHF_Force1x dat.ForceHF_Force1y dat.ForceHF_Force2x dat.ForceHF_Force2y};

%Downsample greatly (to 25hz)
distF = windowFilter(@mean, dist, [], 5^5);
frcF = windowFilter(@mean, frc, [], 5^5);

%Interpolate x array
%Find bounds that fit within the bounds
dmin = ceil(min(distF)/binsz);
dmax = floor(max(distF)/binsz);
offx = (dmin:dmax)*binsz;

intF = cellfun(@(x)interp1(distF, x, offx), frcF, 'Un', 0);

out.mirconv = mirconv;
out.offy = intF;
out.offx = offx;









