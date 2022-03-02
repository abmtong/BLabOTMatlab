function [outcon, outan, lodat, hidat] = anMinaConds(dat, fns, inCOpts, inUOpts)

%anCondense opts
copts.sgp = {1 401}; %"Savitzky Golay Params"
copts.vbinsz = 2; %Velocity BIN SiZe
copts.Fs = 1e3; %Frequency of Sampling
copts.velmult = -1;%Set decreasing to positive
copts.verbose = 0;

%anUnravel opts
%kdfsfind opts
uopts.fpre = {10,1}; %pre filter
uopts.binsz = 0.2; %bin size, for kdf and hist
uopts.kdfsd = 15; %kdf gaussian sd
uopts.histdec = 5; %Step histogram decimation factor
uopts.histfil = 10; %Filter width for step histogram
uopts.kdfmpp = .5; %Multiplier to kdf MinPeakProminence
uopts.histfitx = [0 100]; %X range to fit histfit to
uopts.rmburst = 0; %Remove bursts in kdfdwellfind
uopts.verbose = 0; %Plot

if nargin >= 3 && ~isempty(inCOpts)
    copts = handleOpts(copts, inCOpts);
end

if nargin >= 4 && ~isempty(inUOpts)
    uopts = handleOpts(uopts, inUOpts);
end

%Grab the traces
lodat = cell(1, length(fns));
hidat = cell(1, length(fns));
for i = 1:length(fns)
    lodat{i} = dat.(fns{i}).lo;
    hidat{i} = dat.(fns{i}).hi;
end

outcon = [];
outan = [];

%Do anCondense
outcon = anCondense(lodat, copts);

% anUnravel(lodat, struct( 'fpre', {{200 1}}, 'kdfsd', 10 ));
% outan = anUnravel(hidat, uopts);












