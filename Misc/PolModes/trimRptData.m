function out = trimRptData(inst, inOpts)

%Trims repeat data to an ROI (repeat section?)

%inst is the output of procFran, a struct with field drA (aligned data)
%For this data, the 

opts.roi = [0 64*8]; %ROI to trim off Nuc region for this data. Maybe take pre-Nuc data, too?
 %Could go as negative as -250 or -200 nuc
opts.trimwid = 10; %Width for trimming, i.e. roi + [-trim trim]

opts.Fs = 800;


%Okay so this N is 500bp*300 traces, cf 2-3kb * 30 traces

%The odd part is that this includes a sequence-dependent pause, is k2 just seq dep or also more?

%Process data
rawdat = [inst.drA];

%Apply crop. Let's do this by cropping a bit extra on both sides, then 
len = length(rawdat);
for i = 1:len
    st = find(rawdat{i} > opts.roi(1) - opts.trimwid, 1, 'first');
    en = find(rawdat{i} > opts.roi(2) + opts.trimwid, 1, 'first');
    if isempty(st)
        st = 1;
    end
    if isempty(en)
        en = length(rawdat{i});
    end
    rawdat{i} = rawdat{i}(st:en);
end
%Remove empty [skipped traces]
rawdat = rawdat(~cellfun(@isempty, rawdat));

%Do pol_dwelldist_p1
p1opts.Fs = opts.Fs;

[p1, ~, p1tr] = pol_dwelldist_p1(rawdat, p1opts);

% out = struct('raw', rawdat, 'dw', p1, 'tr', p1tr);
out.raw = rawdat;
out.dw = p1;
out.tr = p1tr;


