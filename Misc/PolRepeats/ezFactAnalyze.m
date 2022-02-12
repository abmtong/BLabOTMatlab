function out = ezFactAnalyze(inp, rAopts)
%Input: Path, rAopts

%getFCs, rulerAlign, then sumNucHist [on all vs. only crossers]

if nargin < 1 || isempty(inp)
    inp = uigetdir();
end


frccotrim = 1e3;
frccof = 5; %pN, lower = tether break
hstexit = 700;

%Get data
if ~iscell(inp)
    inp = {inp};
end

[tra, ~, traf] = cellfun(@(x) getFCs(-1, x), inp, 'Un', 0);
tra = [tra{:}];
traf = [traf{:}];
ntr = length(tra);

%Cutoff force
traco = cellfun(@(x) find( x < frccof, 1, 'first'), traf, 'un', 0);
for i = 1:ntr
    if ~isempty(traco{i})
        tra{i} = tra{i}(1:traco{i}-frccotrim);
    end
end

%Zero
tra = cellfun(@(x) x - mean(x(1:100)), tra, 'Un', 0);

%rulerAlign
traR = rulerAlignV2(tra, rAopts);

%sumNucHist opts
snho.binsz = 0.5; %RTH binsize, best if this divides 1
snho.roi = [-200 800]; %Region of interest
snho.normmeth = 2; %1= 1/median, 2= s/bp; seems no real difference? (median is used to average across traces either way)
snho.Fs = rAopts.Fs;
%Display options
snho.disp = [558 631 704]-16; %Location of lines

%sumNucHist: all
[hsty, hstx] = sumNucHist(traR, snho);

%sumNucHist: Just crossers
tfcross = cellfun(@max, traR) > hstexit;
if any(tfcross)
    [hstycr, hstxcr] = sumNucHist(traR(tfcross), snho);
else
    hstycr = [];
    hstxcr = [];
end

out.p = inp;
out.tra = tra;
out.traf = traf;
out.traco = traco;
out.traR = traR;
out.tfcross = tfcross;
out.hstx = hstx;
out.hsty = hsty;
out.hstxcr = hstxcr;
out.hstycr = hstycr;