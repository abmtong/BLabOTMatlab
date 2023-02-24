function out = getXingTimes_all(inst, snhopts, verbose)

%Get the crossing times of every wid pts
if nargin < 3
    verbose = 1;
end

wid = 5; %bp width for crossing time analysis 
fil = 200; %Filter amt, pts

Fs = 4000/3;

pos = (0:wid:200);

len = length(inst);
out = cell(1,len);

for i = 1:len
    %Get data
    dat = inst(i).con;
    
    %Filter
    datF = cellfun(@(x) windowFilter(@mean, x, fil, 1), dat, 'Un', 0);
    
    %Convert to monotonic
    datFM = cellfun(@makeMono, datF, 'Un', 0);
    
    %Check for crossing pos-wid to pos+wid
    npos = length(pos);
    xts = zeros(length(dat),npos);
    for j = 1:npos
        tpre = cellfun(@(x) [find( x > pos(j) - wid, 1, 'first') nan], datFM, 'Un', 0);
        tpos = cellfun(@(x) [find( x < pos(j) + wid, 1, 'last') nan], datFM, 'Un', 0);
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
ccdf = @(x) plot( sort(x), (length(x):-1:1)/length(x) );
if verbose
    %Calculate stats = mean/sd of crossing time
    
    figure('Name', sprintf('Crossing times every %dnt', wid));
    hold on
    %Plot by condition, as @errorbar
    for i = 1:len
        x = pos;
        y = mean(out{i}, 1, 'omitnan')/Fs;
        e = std(out{i}, 1, 'omitnan')/Fs;
        n = sum( ~isnan( out{i}), 1);
        
        errorbar(x,y,e./sqrt(n))
    end
    %Legend
    legend({inst.name})
    
    xlim([0 150])
    %     for i = 1:npos
    %         figure('Name', sprintf('Crossing time for %dnt', pos(i)));
    %         hold on
    %         %Plot CCDFs, make legend
    %         for j = 1:len
    %             tmp = out{j}(:,i);
    %             tmp = tmp(~isnan(tmp)) / Fs; %Skip nans = never crossed
    %             %Remove pts that never escaped
    %
    %             ccdf( tmp )
    %         end
    %         set(gca, 'YScale', 'log')
    %         xlabel('Time (s)')
    %         ylabel('Crossing Time CCDF')
    %     end
    
%     snhopts.disp = [63 96 155 204]-63; %Start P1, HP, Ter, per Wee
%     snhopts.disp2 = [62 67 79 100 115 124 131 141 167 187 211]-63+1; %Guess
    yl=ylim;
    %Green lines at disp locs
    for i = 1:length(snhopts.disp)
        plot([1 1]*snhopts.disp(i), yl, 'g')
    end
    %Red lines at disp2 locs
    for i = 1:length(snhopts.disp2)
        plot([1 1]*snhopts.disp2(i), yl, 'r')
    end
end
