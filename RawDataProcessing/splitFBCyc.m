function [indSta, indEnd, indStaCut, indEndCut] = splitFBCyc(inTPos, inOpts)
%Split feedback cycles by analyzing trap movement

%Analyze inTPos to find segments

%Set filtering settings
opts.fcsplit.filhz = 60; %Filter trap to this Hz. HiRes mirror has 60Hz noise, so choose that?
opts.fcsplit.workhz = 2500; %Downsample to this Hz
if nargin > 1
    opts = handleOpts(opts, inOpts);
end
filwid = ceil(inOpts.Fsamp/opts.fcsplit.filhz/2);
fildec = ceil(inOpts.Fsamp/opts.fcsplit.workhz);
padt = 0.00; %Time to pad; ignore -- filter width 'takes care of it'
mint = 1e-2;
pad = padt*inOpts.Fsamp; %pts to pad, say 10ms
len = length(inTPos);

%Use velocity thresholding to find steps in trap movement
dmx = diff(windowFilter(@mean, inTPos, filwid, fildec));
dmx(1:filwid) = 0; %Replace edges with zero
dmx(end-filwid:end) = 0;
%Threshold = 5 * 1.4 * MAD (= 5*SD), assume mean ~ 0
thr = 5 * 1.4 * mad(dmx,1); %should be ~equal to the thr in the switch above
ind = [1 find( diff(abs(dmx) > thr) )*fildec len];

%Remove short segments, say minimum length of 0.1s. Do loop so two adjacent short sections doesn't invert polarity
while true
    seglens = diff(ind);
    keepind = seglens>opts.Fsamp*mint;
    keepind(1) = true; %Leave edge cycles regardless
    keepind(end) = true;
    i = find(~keepind, 1, 'first');
    if isempty(i) || length(ind) <= 2
        break
    end
    ind(i:i+1) = [];
end

if abs(dmx(1))>thr %Starting in trap motion
    %Apply padding
    ind(2:2:end-1) = ind(2:2:end-1) + pad;
    ind(3:2:end-1) = ind(3:2:end-1) - pad;
    %Assign Sta/End
    indStaCut = ind(1:2:end-mod(end,2));
    indEndCut = ind(2:2:end);
    indSta = ind(2:2:end-mod(end+1,2));
    indEnd = ind(3:2:end);
else %Start in data section
    %Apply padding
    ind(2:2:end-1) = ind(2:2:end-1) - pad;
    ind(3:2:end-1) = ind(3:2:end-1) + pad;
    %Assign Sta/End
    indSta = ind(1:2:end-mod(end,2));
    indEnd = ind(2:2:end)-1;
    indStaCut = ind(2:2:end-mod(end+1,2));
    indEndCut = ind(3:2:end)-1;
end

