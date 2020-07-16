function cxripV2p2(cxripresult)
%Takes the output from cxripV2 and calculates statistics
%This is just an example, do what you want with it

%Remove first row (the table title) from input
cxrr = cxripresult(2:end, :);
%Separate into components (name, step size, dwell time, force)
nam = cxrr(:,1);
ssz = [cxrr{:,2}];
dwt = [cxrr{:,3}];
frc = [cxrr{:,4}];

%Separate result into individual traces. This kinda just undoes the last fiew lines of cxripV2
[~, ~, uc] = unique(nam);
ntr = max(uc);
sszcell = arrayfun(@(x) ssz(uc == x), 1:ntr, 'Un', 0);
dwtcell = arrayfun(@(x) dwt(uc == x), 1:ntr, 'Un', 0);
frccell = arrayfun(@(x) frc(uc == x), 1:ntr, 'Un', 0);

%Create output containers, for steps that precede positive (unfolding) and negative (translocation) steps
outsszpos = cell(1,ntr);
outdwtpos = cell(1,ntr);
outfrcpos = cell(1,ntr);
outsszneg = cell(1,ntr);
outdwtneg = cell(1,ntr);
outfrcneg = cell(1,ntr);
%For each trace...
for i = 1:ntr
    %Extract group of traces
    sz = sszcell{i};
    dw = dwtcell{i};
    fr = frccell{i};
    %Find the first unfolding rip (first positive ssz)
    firstunf = find(sz > 1, 1, 'first');
    %For the steps that follow, separate into positive and negative steps
    indpos = sz > 1 & (1:length(sz)) >= firstunf;
    indneg = sz < 1 & (1:length(sz)) >= firstunf;
    outsszpos{i} = sz(indpos);
    outdwtpos{i} = dw(indpos);
    outfrcpos{i} = fr(indpos);
    outsszneg{i} = sz(indneg);
    outdwtneg{i} = dw(indneg);
    outfrcneg{i} = fr(indneg);
end

%Plot statistics, I'll give some as examples
figure('Name', 'ClpX Rip V2 Statistics')
%One: Unfolding times vs. force
ax = subplot(2,2,1);
xx = [outfrcpos{:}];
yy = [outdwtpos{:}];
scatter(ax,xx,yy);
title(ax, 'Unfolding dwells vs. Force')
xlabel(ax, 'Force (pN)')
ylabel(ax, 'Unfolding dwell (s)')

%Two: Tloc times vs. force
ax = subplot(2,2,2);
xx = [outfrcneg{:}];
yy = [outdwtneg{:}];
scatter(ax,xx,yy);
title(ax, 'Translocation dwells vs. Force')
xlabel(ax, 'Force (pN)')
ylabel(ax, 'Translocation dwell (s)')

%Three: Step sizes of unfolding
ax = subplot(2,2,3);
hist(ax,[outsszpos{:}]);
title(ax, 'Unfolding step sizes')

%Four: Step sizes of translocation. Note that you might not have the resolution to accurately call these steps.
ax = subplot(2,2,4);
hist(ax,[outsszneg{:}]);
title(ax, 'Translocation step sizes')