function [outCon, outFrc, outTim] = splitcond(insd, dsamp, dfmax)
%Splits a condensation trace into sections by force

if nargin < 2
    dsamp = 1e3; %downsamp factor, 
end

if nargin < 3
    dfmax = .5; %delta F max , decides what is a jump
end

%Look for force jumps
frc = insd.force{1};
%Downsample, look for jumps
frcf = windowFilter(@mean, frc, [], dsamp);
%Movement is pretty fast, so force jumps are near instantaneous
tfmove = find(abs(diff(frcf)) > dfmax);

%Split at those bdys
indSta = [1 (tfmove+1)*dsamp];
indEnd = [(tfmove-1)*dsamp length(frc)];

%Output con + force trace of each
con = insd.contour{1};
tim = insd.time{1};
outCon = arrayfun(@(x,y) con(x:y), indSta, indEnd, 'Un', 0);
outFrc = arrayfun(@(x,y) frc(x:y), indSta, indEnd, 'Un', 0);
outTim = arrayfun(@(x,y) tim(x:y), indSta, indEnd, 'Un', 0);

ki = ~cellfun(@isempty,outCon);

outCon = outCon(ki);
outFrc = outFrc(ki);
outTim = outTim(ki);