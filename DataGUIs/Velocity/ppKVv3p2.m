function outstats = ppKVv3p2(inst, inOpts)
%PPause Part 2: now that we've stepfound, analyze bt events for stats
%inst = the output of phagepauseKVv3

opts.mincon = 0; %Minimum bt contour allowed: affects size of first bin in con plots
opts.minstp = 2; %Minimum back steps required for an event
opts.fbin = [5 15 25 35]; %Bin force by these bin edges
opts.cols = {[0 0 1] [.5 0 .5] [1 0 0]}; %Colors, default blue > purple > red
opts.Fs = 2.5e3;
%Some bin/display params
opts.plotViolins = 0;
binmax.con = [2.5 200];
binmax.tim = [.05 2];
binmax.vel = [10 500];
binmax.dwl = [.01, .5];
binmax.stp = [0.2, 15];
binmax.nnn = [1, 20];
opts.binmax = binmax;
opts.conmult = 0.34; %Convert from bp to nm
opts.smoothfact = 5; %Smooth dists by this amt

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Apply to conmult to binning
opts.binmax.con = opts.binmax.con * opts.conmult;
opts.binmax.stp = opts.binmax.stp * opts.conmult;
opts.binmax.vel = opts.binmax.vel * opts.conmult;

smoothfact = opts.smoothfact;
binmax = opts.binmax;

nfbin = length(opts.fbin)-1;

%What events to calculate, array of {'Axis title', analysis fh, 'type', bt or tl }
toplot = {'Total Time',  @pp_tottim, 'tim', 'bt'; ...
          'S+M Time', @pp_snmtim, 'tim', 'bt'; ...
          'Mid Time', @pp_midtim, 'tim', 'bt'; ...
          'M+E time', @pp_mnetim, 'tim', 'bt'; ...
          ...
          'Total Contour', @pp_totcon, 'con', 'bt'; ...
          'N Stepwise Slips', @pp_nsteps, 'nnn', 'bt';...
          'Total Velocity', @pp_totvel, 'vel', 'bt'; ...
          'Middle Velocity', @pp_midvel, 'vel', 'bt'; ...
          ...
          'Dwell Start', @pp_dwlsta, 'dwl', 'bt'; ...
          'Dwell Dist Mid', @pp_dwdmid, 'dwl', 'bt'; ...
          'Dwell End', @pp_dwlend, 'dwl', 'bt'; ...
          'Tloc Dwell Dist', @pp_dwdsttl, 'dwl', 'tl';...
          ...
          'Bt Step Size', @pp_sszdst, 'stp', 'bt'; ...
          'Tloc Step Size', @pp_sszdsttl, 'stp', 'tl'; ...
          'Tloc Total Contour', @pp_totcontl, 'con', 'tl'; ... 
          'Tloc Total Time', @pp_tottimtl, 'tim', 'tl'; ...
          };
%For the event distribution, calculate these stat params
tocalc = {'Mean', @mean; 'SD', @std; 'N', @length; 'Median', @median; 'MAD_scaled', @(x)mad(x,1)/sqrt(2)/erfinv(.5)};
ntocalc = size(tocalc,1);

%Create figure to show these things, a grid with dims fgsz
fg = figure('Name', sprintf('PhagePauseKVv3 %s', inputname(1)));
fgsz = [4 4];
% %Create figure to plot raw data
% fg2 = figure('Name', sprintf('PhagePauseKVv3 raw data %s', inputname(1)));
%Make sure we have enough space
nrows = size(toplot,1);
assert(prod(fgsz) >= nrows)
axn = 0; %Axis number, to keep track of where to place the next graph
%Calculate dist, mean/sd/N/med/mad of these; plot too
outstats = cell(nrows, 1+ ntocalc*nfbin); %Name, [Mean SD N Median MAD] * num force ranges
outstats(:,1) = toplot(:,1);
for i = 1:size(toplot,1) %Hm, loop should be done over unique type/bt options in toplot, but w/e insignificant runtime
    %Increment plot number
    axn = axn + 1;
    %Extract row
    row = toplot(i,:);
    %Skip empty rows
    if isempty(row{1})
        continue
    end
    %Create plot
    ax = subplot2(fg, fgsz, axn);
    hold on
    %For every force range...
    for j = 1:nfbin
        %Calculate the statistic:
        %Extract events in force range
        crp = inst.(row{4})( [inst.(row{4}).frc] > opts.fbin(j) & [inst.(row{4}).frc] < opts.fbin(j+1) );
        if isempty(crp)
            continue
        end
        %Apply calculation function
        nos = row{2}(crp, opts);
        %Apply scaling if contour
        if any(strcmp(row{3}, {'con', 'vel', 'stp'}))
            nos = nos * opts.conmult;
        end
        
        %Form into a histogram
        [yy,xx] = nhistc(nos, binmax.(row{3})(1));
        %Pad with zeros
        yy = [yy zeros(1,1e2)]; %#ok<AGROW>
        xx = [xx xx(end) + median(diff(xx)) * (1:1e2)]; %#ok<AGROW>
        %If contour, fiddle with first bin if necessary
        if strcmp(row{3}, 'con')
            %Fiddling is necessary if opts.mincon cuts into a bin
            %Assume that this would be the first bin
            if opts.mincon ~= 0
                rm = rem( xx(1) - binmax.con(1)/2 , opts.mincon);
                if rm
                    xx(1) = xx(1) + rm/2;
                    yy(1) = yy(1) * binsz / (binsz - rm);
                end
            end
        end
        %Smooth
        yy = smooth(yy, smoothfact)';
        %And plot
        if opts.plotViolins
            %If violins, some of this calculation will be wasted, but eh whatever
%             obs = violin(nos(:), 'facecolor', opts.cols{j}, 'mc', [], 'medc', 'k', 'bw', binmax.(row{3})(1)*opts.smoothfact, 'facealpha', 1, 'plotlegend', 0);
%             obs(1).XData = obs(1).XData + (j-1);
%             obs(3).XData = obs(3).XData + (j-1);
            patch('XData',smooth([-yy yy(end:-1:1)], smoothfact), 'YData', [xx xx(end:-1:1)], 'FaceColor', opts.cols{j});
            xlim([0 j+1])
            ylim([0 binmax.(row{3})(2)])
        else
            plot(ax, xx, yy, 'Color', opts.cols{j})
            xlim(ax, [0 binmax.(row{3})(2)])
        end
        %Calculate stats
        outstats(i, 1+(j:3:end-1)) = cellfun(@(x) x(nos), tocalc(:,2), 'un', 0);
    end
    %Font, title
    ax.FontSize = 14;
    title(ax, row{1}, 'FontWeight', 'normal', 'FontSize', ax.FontSize-2)
end

%Special row: Events per kb or time. Derivable from available rows
evtfrq = cell(1, 1+ ntocalc*nfbin);
evtfrq{1} = 'Events per kb';
%Evts/kb = N bt events / Avg tloc length * N tloc events
indn = 1+nfbin*(find(strcmp(tocalc(:,1),'N'),1)-1) + (1:nfbin); %What columns N is in
indm = 1+nfbin*(find(strcmp(tocalc(:,1),'Mean'),1)-1)+(1:nfbin); %What columns Mean is in
indtl = find(strcmp('Tloc Total Contour', toplot(:,1)),1); %What row translocation contour is in
%Calculate values, assign to the new row. Check isempty to skip if we're missing force ranges
evtfrq([false ~cellfun(@isempty,outstats(1,indn))]) = num2cell( [outstats{1,indn}] * 1000 ./([outstats{indtl,indm}] .* [outstats{indtl,indn}]) );
indt = find(strcmp('Tloc Total Time', toplot(:,1)),1); %What row translocation time is in
evtfrqt = cell(1, 1+ ntocalc*nfbin);
evtfrqt{1} = 'Events per sec';
evtfrqt([false ~cellfun(@isempty,outstats(1,indn))]) = num2cell( [outstats{1,indn}] ./([outstats{indt,indm}] .* [outstats{indt,indn}]) );
%Add to outstats
outstats = [outstats; evtfrq; evtfrqt];

%Write a header for this table: [Statistic [] [] ... ; Force1 Force2 Force3 ...]
hdr1 = cell(nfbin,ntocalc);
hdr1(1,:) = tocalc(:,1);
hdr1 = [{''} hdr1(:)'];
hdr2 = [{''} repmat(num2cell( mean( [opts.fbin(1:end-1); opts.fbin(2:end)],1) ), [1 ntocalc])];
outstats = [hdr1; hdr2; outstats];

%Write to a xls, save figure
xlswrite(sprintf('ppkv_%s', inputname(1)), outstats)
savefig(fg, sprintf('ppkv_%s', inputname(1)))
end

%% Functions to extract the required statistic from the KV fits. All prefixed with 'pp_'
function out = pp_tottim(inbt, opts) %Total Time
out = cellfun(@(x) (x(end)-x(1))/opts.Fs, {inbt.ind});
end

function out = pp_snmtim(inbt, opts) %Start and Middle Time
out = cellfun(@(x) (x(end-1) - x(1)) /opts.Fs, {inbt.ind});
end

function out = pp_midtim(inbt, opts) %Middle Time
out = cellfun(@(x) (x(end-1) - x(2)) /opts.Fs, {inbt.ind});
end

function out = pp_mnetim(inbt, opts) %Middle and End Time
out = cellfun(@(x) (x(end) - x(2)) /opts.Fs, {inbt.ind});
end

function out = pp_totcon(inbt, ~) %Total Contour
out = cellfun(@(x) x(end)-x(1), {inbt.mea});
end

function out = pp_totvel(inbt, opts) %Total Velocity
out = cellfun(@(x,y) (x(end)-x(1))/(y(end)-y(1))*opts.Fs, {inbt.mea}, {inbt.ind});
end

function out = pp_midvel(inbt, opts) %Middle Velocity
out = cellfun(@(x,y) (x(end)-x(1))/(y(end)+y(end-1)-y(2)-y(1) )*2*opts.Fs, {inbt.mea}, {inbt.ind});
end

function out = pp_dwlsta(inbt, opts) %Dwell Start
out = cellfun(@(x) (x(2)-x(1))/opts.Fs, {inbt.ind});
end

function out = pp_dwdmid(inbt, opts) %Dwell Middle
out = cellfun(@(x) diff(x)/opts.Fs, {inbt.ind}, 'Un', 0);
out = cellfun(@(x) x(2:end-1), out, 'Un', 0);
out = [out{:}];
end

function out = pp_dwlend(inbt, opts) %Dwell End
out = cellfun(@(x) (x(end)-x(end-1))/opts.Fs, {inbt.ind});
end

function out = pp_nsteps(inbt, ~) %Number of Slip Steps
out = cellfun(@(x) length(x) -1 , {inbt.mea})+.5; %Add 0.5 so @nhistc bins nicely
end

function out = pp_sszdst(inbt, ~) %Step Size Distribution
out = cellfun(@(x) diff(x), {inbt.mea}, 'Un', 0);
out = [out{:}];
end

function out = pp_dwdsttl(inbt, opts)
out = cellfun(@(x) diff(x)/opts.Fs, {inbt.ind}, 'Un', 0);
out = cellfun(@(x) x(2:end-1), out, 'Un', 0);
out = [out{:}];
end

function out = pp_sszdsttl(inbt, ~) %Step Size Distribution (Translocation)
out = cellfun(@(x) -diff(x), {inbt.mea}, 'Un', 0);
out = [out{:}];
end

function out = pp_totcontl(inbt, ~) %Total Contour (Translocation)
out = cellfun(@(x) x(1)-x(end), {inbt.mea});
end

function out = pp_tottimtl(inbt, opts) %Total Time (Translocation)
out = cellfun(@(x) (x(end)-x(1))/opts.Fs, {inbt.ind});
end