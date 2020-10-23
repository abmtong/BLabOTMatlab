function [indSta, indEnd] = splitFBCyc(inTPos, inOpts)
%Split feedback cycles by analyzing trap movement

%Analyze inTPos to find segments

%Set filtering settings
opts.fcsplit.filhz = 200;
opts.fcsplit.workhz = 2500;
if nargin > 1
    opts = handleOpts(opts, inOpts);
end
filwid = ceil(inOpts.Fsamp/opts.fcsplit.filhz);
fildec = ceil(inOpts.Fsamp/opts.fcsplit.workhz);
pad = 20; %pts to pad
thr = 1e-5*760*10; %old thr used to be 1e-5, but now using nm instead of V -- just scale
len = length(inTPos);

%Use velocity thresholding to find steps in mirror movement. Maybe try BatchKV?
dmx = diff(windowFilter(@mean, inTPos, filwid, fildec));
%Threshold = 5 * 1.4 * MAD (= 5*SD), assume mean ~ 0
%     thr = 5 * 1.4 * median(abs(dmx - mean(dmx))); %should be ~equal to the thr in the switch above
%is this necessary to recalc or just use one value?
ind = diff(abs(dmx) > thr);
%     ind = diff(abs(smooth(velocityThresh(rawdat(5,:), dec))) > thr)';
indSta = fildec*find(ind<0)+pad; %=-1, end of mirror movement (start of segment)
indEnd = fildec*find(ind>0)-pad; %=+1, start of mirror movement (end of segment)
%Might need to shift or add, depending on whether ind starts/ends moving or stationary
if isempty(indSta) && isempty(indEnd) %One segment (e.g. if really slow)
    indSta = fildec*1;
    indEnd = fildec*length(ind);
elseif length(indSta) > length(indEnd)
    indEnd = [indEnd len];
elseif length(indEnd) > length(indSta)
    indSta = [1 indSta];
elseif indSta(1) > indEnd(1) %lengths are equal
    indSta = [1 indSta];
    indEnd = [indEnd len];
end %This is probably better handled by ind = [1 diff(x>thr) 1], indSta = find(ind == -1), indEnd = find(ind == 1)
%Remove short segments, say minimum length of 0.1s
seglens = indEnd-indSta;
keepind = seglens>opts.Fsamp*0.1;
indSta = indSta(keepind);
indEnd = indEnd(keepind);