function out = getXingTimes(inst, pos, wid, verbose)

%Get the crossing times of these traces

% wid = 2.5; %bp width for crossing time analysis 
fil = 500; %Filter amt, pts

Fs = 4000/3;

if nargin < 4
    verbose = 1;
end

len = length(inst);
out = cell(1,len);

for i = 1:len
    %Get data
    dat = inst(i).con;
    
    %Filter
    datF = cellfun(@(x) windowFilter(@mean, x, fil, 1), dat, 'Un', 0);
    
    %Convert to monotonic to deal with backtracking
    datFM = cellfun(@makeMono, datF, 'Un', 0);
    
    %Shift
    if isfield(inst, 'yoffmanual')
        datFM = cellfun(@(x) x + inst(i).yoffmanual, datFM, 'Un', 0);
    end
    
    %Check for crossing pos-wid to pos+wid
    npos = length(pos);
    xts = zeros(length(dat),npos);
    for j = 1:npos
        tpre = cellfun(@(x) [find( x > pos(j) - wid, 1, 'first') nan], datFM, 'Un', 0);
        tpos = cellfun(@(x) [find( x > pos(j) + wid, 1, 'first') nan], datFM, 'Un', 0);
        tpre = cellfun(@(x) x(1), tpre);
        tpos = cellfun(@(x) x(1), tpos);
        % If the find doesn't find something, it'll be NaN
                
        %If tpos contains the last point, check whether it's a tether break or due to other things (max time 1000s)
        tfend = tpos == cellfun(@length, datFM);
        
        %Let's mark this by adding 0.5
        tpos = tpos + 0.5 * tfend;
        
        xts(:,j) = tpos - tpre; %nan = never crossed, 0.5 = tether ended during this region (crossref inst(i).tfbreak)
    end
    out{i} = xts;
end

%Plot by condition

%Make plotccdf fh
ccdf = @(x) plot( sort(x), (length(x):-1:1)/length(x), 'LineWidth', 2 );
if verbose
    
    for i = 1:npos
        figure('Name', sprintf('Crossing time for %d +- %0.2f nt', pos(i), wid))
        hold on
        %Plot CCDFs, make legend
        plotdat = cell(1,len);
        beex = cell(1,len);
        for j = 1:len
            tmp = out{j}(:,i);
            tmp = tmp(~isnan(tmp)) / Fs; %Skip nans = never crossed
            %Remove pts that never escaped
            
            ccdf( tmp )
            plotdat{j} = tmp';
            beex{j} = ones(size(tmp))' * j;
        end
        set(gca, 'YScale', 'log')
        xlabel('Time (s)')
        ylabel('Crossing Time CCDF')
        legend({inst.name})
        axis tight
        
        %Plot beeswarm
        figure('Name', sprintf('Crossing time for %d +- %0.2f nt', pos(i), wid))
        %Let x's be A+C A-C O+C O-C OSatNTP
        beeswarm( [beex{:}]', [plotdat{:}]', 'corral_style', 'random', 'dot_size', .5, 'overlay_style', 'mad', 'colormap', 'lines');
        ylabel('Crossing Time (s)')

    end
    
end
