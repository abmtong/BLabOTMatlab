function [bts, btrawmat, btdata] = phagepauseKV(data, fdata, inOpts)

if nargin < 2 || isempty(fdata)
    fdata = cellfun(@(x) 10 * ones(size(x)), data, 'uni', 0);
end

%verbose flags
opts.verbose.traces = 0; %plot every N traces
opts.verbose.output = 1;
%Filter opts: decimation factor
opts.filwid = {[] 5};
%KV opts
opts.kvpf = single(8);
%etc.
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
%btraw = {inds meas}

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
    minlen = -inf;
    
    %Debug: Plot
    if mod(i,opts.verbose.traces) == 0
        figure
        plot(dfil{i}), hold on
        surface([1:length(kvt{i}); 1:length(kvt{i})],[kvt{i}; kvt{i}], zeros(2,length(kvt{i})), repmat(ind2tra(kvi{i}, [isbt{i} 0]), [2 1]) ,'edgecol', 'interp', 'LineWidth', 2)
    end
    %Get info on bts
    hei = length(indSta);
    btstats = zeros(hei, 8);
    btraw = cell(hei,2);
    btd = cell(1,hei);
    for j = 1:hei
        in = kvi{i}(indSta(j):indEnd(j)+1);
        me = kvm{i}(indSta(j):indEnd(j));
        frc = median(ffil{i}(in(1):in(end))); %Median force is the frc this occured at ...? or use f0?
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
        
        btstats(j,:) = [frc dwst/opts.Fs dwen/opts.Fs ttot/opts.Fs ctot ctot./ttotv*opts.Fs ctotvn/ttotvn*opts.Fs (ttot-dwen-dwst)/opts.Fs];
        btraw(j,:) = {in me};
        btd{j} = data{i}(in(1):in(end));
    end
    
    btstatscell{i} = btstats';
    btrawcell{i} = btraw';
    btdata{i} = btd;
    %^ note the transposes, so [a{:}] works below
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
for i = 1:7
    itn = indorder(i);
    [cts, bdys]=arrayfun(@(z,zz) nhistc(bts(bts(:,1)>z & bts(:,1)< zz, itn)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    means{i} = arrayfun(@(z,zz) mean(bts(bts(:,1)>z & bts(:,1)< zz, itn), 'omitnan'), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    stdevs{i} = arrayfun(@(z,zz) std(bts(bts(:,1)>z & bts(:,1)< zz, itn), 'omitnan'), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    nns{i} = arrayfun(@(z,zz) length(bts(bts(:,1)>z & bts(:,1)< zz, itn)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    
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
%%in progress


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

return
% 
% 
% %collect tloc runs
% len = length(dcrop);
% tl = cell(1,len);
% tlf = cell(1,len);
% for i = 1:len
%     %start of tloc is istl 0 -> 1
%     indSta = find(diff(istl{i}) == -1);
%     %end of tloc is istl 1 -> 0
%     indEnd = [find(diff(istl{i}) == -1) length(istl{i})];
%     
%     if istl{i}(1)
%         indSta = [1 indSta]; %#ok<AGROW>
%     end
%     
%     hei = length(indSta);
%     tmptl = cell(1, hei);
%     tmptlf = cell(1, hei);
%     for j = 1:hei
%         tmptl{j} = dcrop{i}(indSta(j):indEnd(j));
%         tmptlf{j} = fcrop{i}(indSta(j):indEnd(j));
%     end
%     tl{i} = tmptl;
%     tlf{i} = tmptlf;
% end
% 
% %unpack
% tl = [tl{:}];
% tlf = [tlf{:}];
% tl = tl(~cellfun(@isempty, tl));
% tlf = tlf(~cellfun(@isempty, tlf));
% 
% tlheis = cellfun(@range, tl);
% 
% %n events per bp
% df = dfil(~cellfun(@isempty, dfil));
% sumbp = cellfun(@(x)x(1)-min(x), df);
% sumbp = sum(sumbp);
% 
% fprintf( '%0.2f events per kb\n' , 1000 * sum([szs{:}]) / sumbp);
% 
% 
% %get forces
% tlf0 = cellfun(@(x) x(1), tlf);
% 
% %do PWD of 5-15pN ones that span at least 50bp
% sumPWDV1b(tl(tlf0 > 5 & tlf0 < 15 & tlheis > 50));
% tmpfg = gcf;
% tmpfg.Name = 'PWD Tloc';
% 
% btheis = cellfun(@range, bt);
% btf0 = cellfun(@(x) x(1), btf);
% %do PWD of bt, too why not
% sumPWDV1b(bt(btf0 > 5 & btf0 < 15 & btheis > 50));
% tmpfg2 = gcf;
% tmpfg2.Name = 'PWD Bt';