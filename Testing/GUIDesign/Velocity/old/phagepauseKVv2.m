function [bts, btrawmat, btdata] = phagepauseKVv2(data, fdata, inOpts)

if nargin < 2 || isempty(fdata)
    fdata = cellfun(@(x) 10 * ones(size(x)), data, 'uni', 0);
end

%Troubleshooting verbose flag
opts.verbose.traces = 0; %plot every N traces, to show tl/bt sections
%Filter opts: {filter factor, decimation factor}; args 3 and 4 of @windowFilter
opts.filwid = {[] 5};
%K-V penalty factor
opts.kvpf = single(8);
%Sampling frequency, to convert pts to time
opts.Fs = 2500;

if nargin >= 3
    opts = handleOpts(opts, inOpts);
end

% %Filter the inputs
dfil = cellfun(@(x)windowFilter(@mean, x, opts.filwid{:}), data, 'un', 0);
ffil = cellfun(@(x)windowFilter(@mean, x, opts.filwid{:}), fdata, 'un', 0);

%Do K-V stepfinding
[kvi, kvm, kvt] = BatchKV(dfil, opts.kvpf);
%kvi = index of step start, kvm = height of step i, kvt = fit staircase

%get stats on bt runs
len=length(kvi);

kvssz = cellfun(@diff, kvm, 'Un', 0);
isbt = cellfun(@(x) x > 0, kvssz, 'Un', 0);

btstatscell = cell(1,len);
btrawcell = cell(1,len);
btdata = cell(1,len);
%btstats = [force tstart tend ttotal ctotal vtotal vbt];
%btrawcell = {inds meas}


for i = 1:len
    if isempty(isbt{i})
        continue
    end
    %start of backtracks is isbt 0 -> 1
    indSta = find(diff([0 isbt{i} 0]) == 1);
    %end of backtracks is isbt 1 -> 0
    indEnd = find(diff([0 isbt{i} 0]) == -1);
    if isempty(indSta)
        continue
    end
    
    %v Should be unnecessary now with changes to ^?
%     %If start/ends bt, fix indices
%     if indSta(1) > indEnd(1)
%         indSta = [1 indSta]; %#ok<AGROW>
%     end
%     if indSta(end) > indEnd(end)
%         indEnd = [indEnd length(isbt{i})]; %#ok<AGROW>
%     end
    
    %Need N transloc. steps to become a non-bt again
    mintr = 3;
    %Find number of steps between backtrack events
    dws = indSta(2:end) - indEnd(1:end-1);
    tooshort = dws <= mintr;
    %And remove
    indEnd([tooshort false]) = [];
    indSta([false tooshort]) = [];
    
%     %Also need N net bt length, apply this later
    minlen = 5;
    
    %Debug: Plot
    if mod(i,opts.verbose.traces) == 0
        figure
        plot(dfil{i}), hold on
        surface([1:length(kvt{i}); 1:length(kvt{i})],[kvt{i}; kvt{i}], zeros(2,length(kvt{i})), repmat(ind2tra(kvi{i}, [isbt{i} 0]), [2 1]) ,'edgecol', 'interp', 'LineWidth', 2)
    end
    %Get info on bts
    hei = length(indSta);
    btstats = zeros(hei, 9);
    btraw = cell(hei,2);
    btd = cell(1,hei);
    for j = 1:hei
        in = kvi{i}(indSta(j):indEnd(j)+1);
        me = kvm{i}(indSta(j):indEnd(j));
        frc = median(ffil{i}(in(1):in(end))); %Median force is the frc this occured at; since its ffb it shouldn't matter how exactly this is gotten
        dwst = in(2)-in(1);
        dwen = in(end)-in(end-1);
        ttot = in(end)-in(1);
        ctot = me(end)-me(1);
        if ctot < minlen
            continue
        end
        ttotv = ttot - dwst/2 -dwen/2; %want line between midpts
        if length(in) > 3
            ttotvn = (in(end-1) + in(end-2) -in(2) - in(3)) /2; %Here want line of just bt part, ignoring start/end
            ctotvn = me(end-1) - me(2);
        else
            ttotvn = NaN;
            ctotvn = NaN;
        end
        
        btstats(j,:) = [frc dwst/opts.Fs dwen/opts.Fs ttot/opts.Fs ctot ctot./ttotv*opts.Fs ctotvn/ttotvn*opts.Fs (ttot-dwen-dwst)/opts.Fs (ttot-dwst)/opts.Fs];
        btraw(j,:) = {in me};
        btd{j} = data{i}(in(1):in(end));
    end
    
    btstatscell{i} = btstats';
    btrawcell{i} = btraw';
    btdata{i} = btd;
    %^ note the transposes, so [a{:}] works below
end

%Do a separate loop for tloc sections, since there's some short-circuit continues above that would skip this section
tldata = cell(1,len);
tlssd = cell(1,len);
tldwd = cell(1,len);
tlrawcell = cell(1,len);
%Similarly for tl
for i = 1:len
    %Use same indSta/indEnd
    %start of backtracks is isbt 0 -> 1
    indSta = find(diff([0 isbt{i} 0]) == 1);
    %end of backtracks is isbt 1 -> 0
    indEnd = find(diff([0 isbt{i} 0]) == -1);
    
    %But unlike in bt, do not exit for empty indSta/indEnd to get data on tloc runs
    %These will be slightly different, because there are a few more exit cases in bt, but
    % should be close enough, since bt is rare
    
    %Get info on tlocs
    hei = length(indSta);
    tmpddist = cell(1,hei+1);
    tmpbdist = cell(1,hei+1);
    tlfrc = zeros(1,hei+1);
    tldist = zeros(1,hei+1);
    tlraw = cell(hei+1,2);
    %Now we end at indSta, start at indEnd
    % Overlap OK due to shared dwells (we'll remove dwSta and dwEnd later
    tindSta = [1 indEnd];
    tindEnd = [indSta length(kvi{i})];
    % indSta/indEnd should be interior, so the [1 x] and [x len] are ok
    for j = 1:hei+1
        in = kvi{i}(tindSta(j):tindEnd(j)+1);
        me = kvm{i}(tindSta(j):tindEnd(j));
        tlfrc(i) = median(ffil{i}(in(1):in(end)));
        tldist(j) = me(end)-me(1);
        tmp = diff(in);
        tmpddist{i} = tmp(2:end-1);
        tmpbdist{i} = diff(me);
        
        tlraw(j,:) = {in me};
    end
    tldata{i} = [tlfrc; tldist];
    tlssd{i} = [tmpbdist{i}];
    tldwd{i} = [tmpddist{:}];
    tlrawcell{i} = tlraw';
end

%Rearrange cells
bts = [btstatscell{:}]';
btrawmat = [btrawcell{:}]';
%^ Note the transposes, offsetting what was done before

%Sanity check: F vs. ttotal
figure, scatter(bts(:,4),bts(:,1))

%Calculate histograms and sort
fbins = [5 15 25 35];
%btstats = [force tstart tend ttotal ctotal vtotal vbt];
figure ('Name', ['PhagePauseKV ' inputname(1)])
fgtits = {'Total Time' 'Total Contour' 'Total Velocity' 'Dwell Start' 'Dwell End' 'Middle Time' 'Middle Velocity'};
xmxs = [.5 100 3000 .2 .2 .2 3000];
indorder = [4 5 6 2 3 8 7];
means = cell(1,10);
stdevs = cell(1,10);
nns = cell(1,10);
iscon = 2; %Which plots involve contour, and need a bin to be shifted
for i = 1:7
    itn = indorder(i);
    [cts, bdys]=arrayfun(@(z,zz) nhistc(bts(bts(:,1)>z & bts(:,1)< zz, itn)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    means{i} = arrayfun(@(z,zz) mean(bts(bts(:,1)>z & bts(:,1)< zz, itn), 'omitnan'), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    stdevs{i} = arrayfun(@(z,zz) std(bts(bts(:,1)>z & bts(:,1)< zz, itn), 'omitnan'), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    nns{i} = arrayfun(@(z,zz) length(bts(bts(:,1)>z & bts(:,1)< zz, itn)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    
    if ~isinf(minlen) && any(i == iscon)
        %Convert from bdys to edges
        bsz = mean(diff(bdys));
        edges = [bdys - bsz/2 bdys(end)+bsz/2] ;
        %Check that minlen is within the bin range
        if minlen > edges(1)
            %Then, shift bdys and cts by an amount
            bdys(1) = (minlen(1) + edges(2)) /2;
            cts(1) = cts(1) * (edges(2) - edges(1)) / (edges(2) - minlen);
        end
    end
    subplot2([3,4],i), hold on, cellfun(@plot, bdys, cts)
    title(fgtits{i})
    xlim([0 xmxs(i)])
end

%Dwell time dist all and middle
dwells = cell(1,length(fbins)-1);
dwellsm = cell(1,length(fbins)-1);
%Stepsizes
ssz = cell(1, length(fbins)-1);

for i = 1:size(bts,1)
    ind = find(bts(i,1) > fbins(1:end-1) & bts(i,1) < fbins(2:end),1);
    if isempty(ind)
        continue
    end
    tdw = diff(btrawmat{i,1})/opts.Fs;
    tsz = diff(btrawmat{i,2});
    dwells{ind} = [dwells{ind} tdw];
    dwellsm{ind} = [dwellsm{ind} tdw(2:end-1)];
    ssz{ind} = [ssz{ind} tsz];
end


[cts, bdys]=cellfun(@(z) nhistc(z), dwells, 'Uni', 0);
means{8} = cellfun(@(z) mean(z, 'omitnan'), dwells, 'Uni', 0);
stdevs{8} = cellfun(@(z) std(z) - sum(isnan(z)), dwells, 'Uni', 0);
nns{8} = cellfun(@(z) length(z), dwells, 'Uni', 0);
subplot2([3,4],8), hold on, cellfun(@plot, bdys, cts)
title('Dwell Dist')
xlim([0 .2])

means{9} = cellfun(@(z) mean(z, 'omitnan'), dwellsm, 'Uni', 0);
stdevs{9} = cellfun(@(z) std(z, 'omitnan'), dwellsm, 'Uni', 0);
nns{9} = cellfun(@(z) length(z) - sum(isnan(z)), dwellsm, 'Uni', 0);
[cts, bdys]=cellfun(@(z) nhistc(z), dwellsm, 'Uni', 0);
subplot2([3,4],9), hold on, cellfun(@plot, bdys, cts)
title('Dwell Dist Middle')
xlim([0 .2])

means{10} = cellfun(@(z) mean(z), ssz, 'Uni', 0);
stdevs{10} = cellfun(@(z) std(z), ssz, 'Uni', 0);
nns{10} = cellfun(@(z) length(z), ssz, 'Uni', 0);
[cts, bdys]=cellfun(@(z) nhistc(z), ssz, 'Uni', 0);
subplot2([3,4],10), hold on, cellfun(@plot, bdys, cts)
title('Step Dist')
xlim([0 30])

%For those histograms where there is a cmin, account for this by shifting x, scaling y


means = [means{:}];
means = [means{:}];
means = reshape(means, 3, [])';
stdevs = [stdevs{:}];
stdevs = [stdevs{:}];
stdevs = reshape(stdevs, 3, [])';
nns = [nns{:}];
nns = [nns{:}];
nns = reshape(nns, 3, [])';

a = [means stdevs nns];
assignin('base', 'ppkvstats', a) %super messy but w/e
