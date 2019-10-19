function [bts, btrawmat, btdata] = phagepauseKV(data, fdata, inOpts)

if nargin < 2 || isempty(fdata)
    fdata = cellfun(@(x) 10 * ones(size(x)), data, 'uni', 0);
end

%verbose flags
opts.verbose.traces = 0; %plot every N traces
opts.verbose.output = 1;
%Filter opts: decimation factor
opts.filwid = 5;
%KV opts
opts.kvpf = single(5);
%etc.
opts.Fs = 2500;

if nargin >= 3
    opts = handleOpts(opts, inOpts);
end

%Filter the inputs
dfil = cellfun(@(x)windowFilter(@mean, x, [], opts.filwid), data, 'un', 0);
ffil = cellfun(@(x)windowFilter(@mean, x, [], opts.filwid), fdata, 'un', 0);

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
    
    %Remove those that are too short?
    mintr = 5; %Need N transloc. steps to become a non-bt again
    %Find number of steps between backtrack events
    dws = indSta(2:end) - indEnd(1:end-1);
    tooshort = dws <= mintr;
    %And remove
    indEnd([tooshort false]) = [];
    indSta([false tooshort]) = [];
    
    %Debug: Plot
    if mod(i,opts.verbose.traces) == 0
        figure
        plot(dfil{i}), hold on
        surface([1:length(kvt{i}); 1:length(kvt{i})],[kvt{i}; kvt{i}], zeros(2,length(kvt{i})), repmat(ind2tra(kvi{i}, [isbt{i} 0]), [2 1]) ,'edgecol', 'interp', 'LineWidth', 2)
    end
    %Get info on bts
    hei = length(indSta);
    btstats = zeros(hei, 7);
    btd = cell(1,hei);
    for j = 1:hei
        in = kvi{i}(indSta(j):indEnd(j)+1);
        me = kvm{i}(indSta(j):indEnd(j));
        frc = median(ffil{i}(in(1):in(end))); %Median force is the frc this occured at ...? or use f0?
        dwst = in(2)-in(1);
        dwen = in(end)-in(end-1);
        ttot = in(end)-in(1);
        ctot = me(end)-me(1);
        ttotv = ttot - dwst/2 -dwen/2; %want line between midpts
        if length(in) > 3
            ttotvn = (in(end-1) + in(end-2) -in(2) - in(3)) /2; %Here want line of just bt part, ignoring start/end
            ctotvn = me(end-1) - me(2);
        else
            ttotvn = NaN;
            ctotvn = NaN;
        end
        
        btstats(j,:) = [frc dwst/opts.Fs dwen/opts.Fs ttot/opts.Fs ctot ctot./ttotv*opts.Fs ctotvn/ttotvn*opts.Fs];
        btraw = {in me};
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
figure Name PhagePauseKV
fgtits = {'Total Time' 'Total Contour' 'Total Velocity' 'Dwell Start' 'Dwell End' 'Middle Velocity'};
xmxs = [.5 100 3000 .2 .2 3000];
indorder = [4 5 6 2 3 7];

for i = 1:6
    itn = indorder(i);
    [cts, bdys]=arrayfun(@(z,zz) nhistc(bts(bts(:,1)>z & bts(:,1)< zz, itn)), fbins(1:end-1), fbins(2:end), 'Uni', 0);
    subplot2([3,2],i), hold on, cellfun(@plot, bdys, cts)
    title(fgtits{i})
    xlim([0 xmxs(i)])
end

%%in progress
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