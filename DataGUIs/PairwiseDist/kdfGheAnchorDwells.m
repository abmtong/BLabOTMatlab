function out = kdfGheAnchorDwells(dat, inOpts)

%~in progress~
%Probably add some sort of visualizer (verbose output) and checker

opts.Fs = 2500; %Fs
opts.pauT = 0.5; %Cutoff time to call a pause, sec

%kdfsfind options
%opts. [] = [];

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Do kdfsfindV2, get dwelltimes too
[~, ~, ~, ~, tra] = kdfsfindV2(dat, opts);

len = length(dat);
stpre = cell(1,len);
stpos = cell(1,len);
for i = 1:len
    %Find long dwells = pauses
    [in, me] = tra2ind(tra{i});
    dw = diff(in) / opts.Fs;
    ssz = diff(me);
    isp = dw > opts.pauT;
    
    %Do Ghe-like 'anchor dwell' alignment
    % Easy: Just take the step size it just took / it will take
    % Or, if that seems too noise-laden, average across the adjacent two steps (Ghe used two anchor dwells)

    %For pauses, take the step before and after [if it exists]
    ssznan = [nan ssz nan]; %ssz is length N, dw is length N+1, ssznan is length N+2
    stpre{i} = ssznan( isp );
    stpos{i} = ssznan( [false isp] );
    
    %Maybe replicate Ghe-like histograms?
end




