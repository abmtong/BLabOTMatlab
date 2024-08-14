function out = procFran_PFV(inst, inOpts)
%Calculate pause-free velocity for nucleosome crossings

opts.tfpick = 1; %Use tfpick
opts.Fs = 800; %Sampling frequency
opts.method = 3; %Calculation method, see code
opts.rois = {[0 64*8] [542 688]}; %ROIs: e.g. ladder region, nuc region


%Method 1: vdist-like
opts.tpause = 1;
% vdist opts
opts.vdopts.sgp = {1 401}; %"Savitzky Golay Params"
opts.vdopts.vbinsz = 0.2; %Velocity BIN SiZe
opts.vdopts.verbose = 0;
opts.vdopts.fitmethod = 1;

%Method 3: RTH-based
opts.npos = 3; %Take the ... average of the 3 lowest RTs? take the 3rd-lowest?
opts.maxdw = 0.5;

opts.snhopts.binsz = 1;
opts.snhopts.verbose = 0;
opts.snhopts.Fs = 800;
opts.snhopts.fil = 100;
opts.snhopts.filfcn = @median; %Filter function




%Set some opts
opts.vdopts.Fs = opts.Fs;


%For each element in inst...


len = length(inst);
out = cell(1,len);
nr = length(opts.rois);
for i = 1:len
    tmp = inst(i);
    
    hei = length(tmp.drA);
    
    outtmp = nan(nr,hei); %PFV for each (region, trace)
    for j = 1:hei
        %Skip trace if not picked
        if opts.tfpick
            if ~tmp.tfpick(j)
                continue
            end
        end
        
        %Extract data
        dat = tmp.drA{j};
        pdd = tmp.pdd{j};
        
        %For each ROI
        for k = 1:nr
            %Get current ROI
            roi = opts.rois{k};
            
            %Calc PFV via some method
            switch opts.method
                case 1 %vdist-like
                    %Convert pdd output to index/mean
                    [in, me] = tra2ind(pdd);
                    
                    %Keep segments that are in ROI + smaller than pause duration
                    ki = me >= roi(1) & me <= roi(2) & diff(in)/opts.Fs < opts.tpause;
                    
                    %Extract these sections of the raw data
                    [kiin, kime] = tra2ind(ki);
                    kime = find(kime); %Find steps of ki == 1
                    
                    %If no data for this section, skip
                    if isempty(kime)
                        continue
                    end
                    
                    
                    %Convert between drA index and pdd index.
                    % THIS IS BAD BUT
                    % pdd(1) is drA( find(drA>pdd_roi(1), 1, 'first') ), unless it has changed in _pdd (check)
                    indoff = find( dat > 0, 1, 'first'); %roi(1) in _pdd is 0
                    
                    %And extract these sections
                    crp = arrayfun(@(x,y) dat( (indoff-1) + (x:y) ), in(kiin(kime)), in(kiin(kime+1)), 'Un', 0 );
                    
                    %If too little data, vdist will error. Check for that here
                    if max( cellfun(@length, crp) ) < 2*opts.vdopts.sgp{2}
                        continue
                    end
                    
                    %run vdist on these sections
                    [ccts, xbins, ~, ~, ~, vfit]  = vdist(crp, opts.vdopts);
                    
                    %Get PFV from vfit. vfit = [0 sd0 amp0 pfv pfv_sd pfv_amp]
                    outtmp(k,j) = vfit(4);
                    
                case 2 %dtd
                    %Convert pdd output to index/mean
                    [in, me] = tra2ind(pdd);
                    
                    dw = diff(in) / opts.Fs;
                    
                    %Keep segments that are in ROI + smaller than pause duration
                    ki = me >= roi(1) & me <= roi(2) & dw < opts.tpause;
                    
                    %And get these dwells
                    dw = dw(ki);
                    
                    %And find the principal 1exp that fits this data. How to do this? Weights?
                    yy = ( length(dw):-1:1)/length(dw);
                    xx = sort(dw);
                    
%                     figure, plot(xx,yy)
                    
                    %Unfinished
                    error('unfinished, don''t use')
                case 3 %ZJ paper-like, from RTH
                    %Calculate per-trace RTH. only need to do this once per trace
                    if k == 1
                        [rthy, rthx] = sumNucHist( dat, opts.snhopts );
                    end
                    
                    %Crop to range
                    ki = rthx >= roi(1) & rthx <= roi(2);
                    dw = rthy(ki);
                    
                    %Remove long dwells. i.e., attempt to cut the tail (pauses)
                    dw(dw > opts.maxdw ) = nan;
                    mdw = median(dw, 'omitnan'); 
                    
%                     outtmp(k,j) = 1/ prctile(dw, 5); %Take 5th percentile dwell... ?
                    outtmp(k,j) = 1/mdw; 
%                     outtmp(k,j) = 1/mdw/log(2); %log(2) to convert median (1exp) to the rate constant?
            end
            
        end
    end
    out{i} = outtmp;
    
end

%And plot
switch opts.method
    case {1 3} %vdist
        %Errorbar, mean SEM, per ROI
        
        %Basically, we can just take stats along dim 2
        mn = cellfun(@(x) mean(x,2,'omitnan'), out, 'Un', 0);
        sd = cellfun(@(x) std(x, [], 2, 'omitnan'), out, 'Un', 0);
        nn = cellfun(@(x) sum(~isnan(x), 2), out, 'Un', 0);
        
        %Concatenate. This is now [roi1(:) roi2(:) roi3(:) ...]
        mn = [mn{:}]';
        sd = [sd{:}]';
        nn = [nn{:}]';
        
%         %Add a row of 0s to the end, as a spacer
%         mn = [mn zeros( length(mn,1) , 1)];
%         sd = [sd zeros( length(mn,1) , 1)];
%         nn = [nn zeros( length(mn,1) , 1)];
        
        
%         %Reorder from [condition1_roi1, condition2_roi2, ...c2_roi1, c2_roi2, ...] to [c1_r1, c2_r1, ...c1_r2, c2_r2, ...]
%         
%         mn = reshape(mn, nr,[])';
%         mn = mn(:)';
%         
%         sd = reshape(sd, nr,[])';
%         sd = sd(:)';
%         
%         nn = reshape(nn, nr,[])';
%         nn = nn(:)';
        
        %Plot as bar? errorbar?
        
        
        figure, hold on
%         xx = 1:length(mn);
%         errorbar(xx, mn, sd./sqrt(nn), 'LineStyle', 'none', 'Marker', '+')
%         xx = 1:size(mn, 2);
%         bar( mn ) %Grouped bars
%         errorbar(mn(:), sd(:)./nn(:), 'LineStyle', 'none')
        %Create x labels
        
        %Add a 0 spacer between ROIs
        mn = [mn; zeros(1, nr)];
        sd = [sd; zeros(1, nr)];
        nn = [nn; ones(1, nr)];
        
        bar( mn(:) )
        errorbar(mn(:), sd(:)./nn(:), 'LineStyle', 'none')
        
        %Create x tick labels
        xt = 1:numel(mn);
        nams = repmat( [{inst.nam} {[]}] , 1, nr );
        ax = gca;
        ax.XTick = xt;
        ax.XTickLabel = nams;
        ax.XTickLabelRotation = 90;
        
        xlabel('Region: Repeats | 601')
        ylabel('Pause-free velocity (bp/s)')
    case 2 %pdd
    
    
end

