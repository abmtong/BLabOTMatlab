function out = RPp1(condat, inOpts)
%Naming: 'Rohit Protein' project, so let's call these 'RP' part 1, 2, 3 etc.
%Part 1: Separate the raw data into pulling cycles

%Input: ContourData struct , i.e. the processed data
%Output: Data separated to 

opts.start = []; %Pulling start distance, nm (either set this manually, or we'll estimate it as first percentile of extension)
opts.minpull = 0.1; %s, minimum expected time for a pull
opts.pulltrim = 2; %Skip first N pulls, since this is just the algorithm finding the start/end points
opts.fmin = 10; %Minimum force for a pull to be good ? / just a value above noise and below the max force
% opts.Fs = []; %get Fsamp from condat

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Estimate Fsamp from input data if not supplied
opts.Fs = condat.opts.Fsamp;

% Estimate mirror extension : ext ~= trappos + beadAX - beadBX
trappos = condat.extension - condat.forceAX/condat.cal.AX.k + condat.forceBX/condat.cal.BX.k;

%Separate by pulls by finding excursions above some base mirror extension
% The trace in mirror extension coords looks like __/\__/\__/\__ , we just want the pull parts (the /\'s)
% So let's extract these by finding contiguous sections greater than some trap position
if isempty(opts.start)
    %Estimate by finding most probable position
    [hy, hx] = nhistc(trappos, 0.2); %Let's set a 0.2nm step size
    [~, maxi] = max(hy);
    opts.start =hx(maxi);
end
%Find regions above this trap position
tfpull = trappos > opts.start;
%Separate to sections 
indSta = find( diff([false tfpull]) == 1 ); %Find when ki goes from 0 -> 1
indEnd = find( diff([tfpull false]) == -1 ); %Find when ki goes from 1 -> 0
% Pad with false so length(indSta) == length(indEnd), and so indicies match (@diff shortens length by one)
%Mirror baseline noise might peek over otps.start, this would result in a very short pull. Remove them.
tpull = (indEnd-indSta)/opts.Fs;
ki = tpull > opts.minpull;
indSta = indSta(ki);
indEnd = indEnd(ki);
%If this is the automatic pulling algorithm, ignore the first pull or few (just used to set distances)
indSta = indSta(opts.pulltrim+1:end);
indEnd = indEnd(opts.pulltrim+1:end);

%Find when the tether breaks, if any
pullextr = @(x) arrayfun(@(st,en) x(st:en), indSta, indEnd, 'un', 0);
frc = pullextr(condat.force);
tf = cellfun(@(x) any( x > opts.fmin), frc);
ki = find(tf); %Remove any pull that doesn't get above this force (should just be the last few pulls, if any)
ki = ki(1:end-1); %Crop last pull, too
%And crop
indSta = indSta(ki);
indEnd = indEnd(ki);

%Extract these pulls to data
pullextr = @(x) arrayfun(@(st,en) x(st:en), indSta, indEnd, 'un', 0);
ext = pullextr(condat.extension);
frc = pullextr(condat.force);
tpos = pullextr(trappos);

out = struct('ext', ext, 'frc', frc, 'tpos', tpos);
