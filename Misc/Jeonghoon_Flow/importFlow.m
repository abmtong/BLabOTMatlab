function [out, outraw] = importFlow(p, f)

if nargin < 2
    [f, p] = uigetfile('*.csv', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
end


binsz = 10; %Bin size for kdf. Basically arbitrary, biggest effect is execution time vs. guess precision
kdfsd = 2e3; %KDF sd, affects smoothness of KDF, don't make bigger than the spread of the data itself
checkplot = 1; %Plot the raw kdfs

if checkplot
    fg = figure('Color', [1 1 1]);
%     plotind = 1;
end

%Do hacky fetching of time from filename: if this string is found, that's the time
%'time dictionary'. Initial spaces are [sic] to exclude possible others
tdict = {' 0,' 0 ; ' 15,' 15; ' 30,' 30; ' 1hr,', 60; ' 2hr,', 120};

len = length(f);
tt = nan(1, len);
for i = 1:len
    ind = find( cellfun(@(x) ~isempty(strfind(f{i}, x)), tdict(:,1)' ) );
    if ind
        tt(i) = tdict{ind,2};
    else
        warning('Cant get a time value for file %s, update tdict', f{i})
    end
end

%And let's sort the filenames by time
[tt, si] = sort(tt);
f = f(si);

%Grab Data
outraw = cell(2,len); %{gfp(:), mcherry(:) peak 1 ; peak 2 g/r}
out = repmat({nan(6,1)},4,len); %Initialize to no value found
cols = [8 11]; %Columns the data is stored in, in this case, the gfp column, the mcherry column

for i = 1:len
    %Load csv
    tbl = readtable(fullfile(p, f{i}));
    
    for j = 1:2
        %Green on column 8, red on column 1
        dat = table2array(tbl(:, cols(j) ));
        
%         %Make into hist
%         [p,x] = nhistc(dat, binsz);
        
        %Find peak with kdf
        [kp, kx] = kdf(dat(:)', binsz, kdfsd);
        %Normalize
        kp = kp / sum(kp) / binsz;
        
        %Fit a gauss to the peak
        [pkht, pkx, pkwid, prom] = findpeaks(kp, kx);
        
        if checkplot
            colarr = {'GFP' 'mCh'};
            subplot(2, len, i + (j-1) * len)
            title( sprintf('t=%dmin, %s', tt(i), colarr{j} ))
            %         plotind = plotind + 1;
            hold on
            plot(kx, kp)
        end
        
        
        %If empty, skip; eg for no data / no color
        if isempty(pkht)
            outraw{j ,i} = dat;
%             outraw{j+2,i} = dat;
%             out{j,i} = nan(6,1);
            continue
        end
        
        %Pick the highest-prominence peak
        [~, si] = sort(prom, 'descend');
        

        
        for k = 1:2 
            if length(si) >= k
                %Create gaussian fit guess from this: mean, sd, ht
                xg = [pkx(si(k)) pkwid(si(k))/2.4 pkht(si(k))];
                xg(3) = xg(3) * xg(2) * sqrt(2*pi); %normpdf(0,0,sig) = 1/sig/sqrt(2pi)
                
                %Fit to just this region ? like +/-3SD?
                fitwid = 3;
                kxki = kx > xg(1) - xg(2) * fitwid & kx < xg(1) + xg(2) * fitwid;
                
                xcrop = kx(kxki);
                ycrop = kp(kxki);
                
                %Fit to this cropped data. Regularize x data, since x is large (otherwise it'll say it's at a local minimum)
                opopts = optimoptions('lsqcurvefit', 'Display', 'off');
                fitfcn = @(x0,xx) normpdf(xx, x0(1), x0(2))*x0(3);
                ft = lsqcurvefit( fitfcn, xg/max(xcrop), xcrop/max(xcrop), ycrop, [], [], opopts);
                % (all elements of guess scale by x, so just divide thru
                ft = ft * max(xcrop);
                
                %Save output
                outraw{j ,i} = dat; %Will be done twice but w/e
                out{j + 2*(k-1),i} = [xg(:) ; ft(:)]; %Save as row vector so we can easily concatenate later
                if checkplot
                    plot( xcrop, fitfcn(xg,xcrop) )
                    plot( xcrop, fitfcn(ft,xcrop) )
                end
            end
        end
    end
end

%Assemble output table
tmp = cell(1,len);
for i = 1:len
    tmpp = [out{:,i}];
    tmp{i} = [tt(i); tmpp(:)];
end

out = [tmp{:}]';

fg2 = figure('Color', [1 1 1]);
hold on

%Plot errorbars (mu, sd) for the G/R data
errorbar( out(:,1), out(:,2), out(:,3), 'LineStyle', 'none', 'Marker', 'x', 'Color', [0 1 0] )
errorbar( out(:,1), out(:,2+6), out(:,3+6), 'LineStyle', 'none', 'Marker', 'x', 'Color', [1 0 0] )
errorbar( out(:,1), out(:,2+6*2), out(:,3+6*2), 'LineStyle', 'none', 'Marker', 'x', 'Color', [.5 1 .5] )
errorbar( out(:,1), out(:,2+6*3), out(:,3+6*3), 'LineStyle', 'none', 'Marker', 'x', 'Color', [1 .5 .5] )

%Add GFP divided by mCherry channel
out = [out out(:,2:7)./out(:,8:13) out(:,14:19)./out(:,20:25) ];
% Probably replace with individual g/r by adding a j=3 case that makes g/r as the data

%And plot in blue. Scale values to be in ylim
yl = ylim;
maxblue = max( [out(:,26);out(:,26+6)] );
yyaxis right
plot( out(:,1), out(:, 26) , 'x', 'Color', [0 0 1]);
plot( out(:,1), out(:, 26+6), 'o', 'Color', [.5 .5 1] );
yyaxis left
% plot( out(:,1), out(:, 26)  / maxblue * yl(2)*.75, 'x', 'Color', [0 0 1]);
% plot( out(:,1), out(:, 26+6)/ maxblue * yl(2)*.75, 'o', 'Color', [.5 .5 1] );

%Make legend
lgnnam = {'GFP-1' 'mCh-1' 'GFP-2' 'mCh-2' 'GFP/mCh-1' 'GFP/mCh-2' };
legend(lgnnam)

%Make marker size ~ proportion of cells, lets say all cells = 100sz
%Do something to deal with small sizes... esp ==0, which errors
maxg = max( [out(:,4); out(:,4+12)] );
maxr = max( [out(:,4+6); out(:,4+18)] );
%Lets do minimum size = maxsz/10? /100?
minsizemult = 1/100;

%Apply a multiplier that the size of the circle ~ 100pts (10px?) this is screen size dependent so watch out?
szmultg = 100/maxg;
szmultr = 100/maxr;

%Plot scatters (size = population)
scatter( out(:,1), out(:,2), szmultg*max(out(:,4), maxg*minsizemult), 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', 'none' )
scatter( out(:,1), out(:,2+6), szmultr*max(out(:,4+6), maxr*minsizemult), 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', 'none' )
scatter( out(:,1), out(:,2+6*2), szmultg*max(out(:,4+6*2), maxg*minsizemult), 'MarkerFaceColor', [.5 1 .5], 'MarkerEdgeColor', 'none' )
scatter( out(:,1), out(:,2+6*3), szmultr*max(out(:,4+6*3), maxr*minsizemult),'MarkerFaceColor', [1 .5 .5], 'MarkerEdgeColor', 'none' )

xlabel('Induction Time (min)')
ylabel('Intensity (arb.)')
yyaxis right
ylabel('GFP/mCherry Ratio (arb.)')
yyaxis left

%Create non-time column names with cellfun...?
rownam = {'gu-mu' 'gu-sd' 'gu-pop' 'fit-mu' 'fit-sd' 'fit-pop'}';
colnam = [lgnnam(1:4) {'GdivR-1' 'GdivR-2'}]; %Can't use slashes for matlab table?
namraw = cellfun(@(x,y) strrep(sprintf('%s-%s',x,y), '-', '_'), repmat(colnam, length(rownam), 1), repmat(rownam, 1, length(colnam)), 'Un', 0);
namraw = [{'time'} namraw(:)'];

%Create and save output table
tbl = array2table(out, 'VariableNames', namraw);

%Create filename
outfnpre = sprintf('iF_%s', datestr(now, 'yymmdd_HHMMSS'));
writetable(tbl, fullfile(p, [outfnpre '-table.xlsx']))

%Set figure title = folder title
if p(end) == filesep
    [~,fignam,~] = fileparts(p(1:end-1)); %Strip final \ and call fileparts to get the folder name
else
    [~,fignam,~] = fileparts(p);
end

%Set name and save
fg2.Name = sprintf('iF Summary: %s', fignam);
savefig(fg2, fullfile(p, [outfnpre '-summaryfig.fig']))
if checkplot
    fg.Name = sprintf('iF Raw Fitting: %s', fignam);
    savefig(fg, fullfile(p, [outfnpre '-fitfig.fig']))
end

%And lets make out into a struct
out = struct('name', fignam, 'dat', out);


