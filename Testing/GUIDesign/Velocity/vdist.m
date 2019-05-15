function [ccts, xbins, cvel, cfilt, ccrop] = vdist(c, inOpts)
%Calculates the velocity pdf of c by using sgolay filtering

%outputs: velocity pdf (normalized), velocity bins, trace -> velocity, ...
%  trace position filtered, trace position cropped (no filter)
%to e.g. get unnormalized counts, N = sum(cellfun(@length, cvel));

%Definte default options
opts.sgp = {1 301}; %"Savitsky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling

if nargin >= 2
    opts = handleOpts(opts, inOpts);
end

if ~iscell(c)
    c = {c};
end

%Apply @sgolaydiff to input
[cvel, cfilt, ccrop] = cellfun(@(x)sgolaydiff(x, opts.sgp), c, 'uni', 0);

%Convert velocity from /pt to /s
cvel = cellfun(@(x) double(x)*opts.Fs, cvel, 'Uni', 0); 

%Concatenate velocities
cf2 = [cvel{:}];

%Make hist bounds
mincf = floor(min(cf2) / opts.vbinsz) * opts.vbinsz;
maxcf =  ceil(max(cf2) / opts.vbinsz) * opts.vbinsz;
xbins = mincf:opts.vbinsz:maxcf;

%Bin values
% ccts = hist(cf2, xbins); lets move away from @hist
ccts = histcounts(cf2, xbins);
%@histcounts uses them as edges, so convert to centers
xbins = ( xbins(1:end-1) + xbins(2:end) ) /2; 

%Normalize
ccts = ccts / sum(ccts) / opts.vbinsz;

% %Debug: plot
% figure, bar(xbins, ccts);