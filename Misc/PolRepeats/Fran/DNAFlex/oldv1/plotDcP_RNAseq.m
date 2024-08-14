function plotDcP_RNAseq(dat, tpm, nbp)
%Plots output of prepDcPp2
% Input: dat is 1x4 cell of 1xn NPS cyc-ity values
%  Join multiple inputs together by making a nx4 cell

%bp per nps
if nargin < 3
    nbp = 301;
end

%'Plot mode', handle with this value
plottyp = 2;

switch plottyp
    case 1
        typrng = [1 3]; %Which to plot
        tpmrng = [0 1 30 60 inf];
    case 2 %Auto TPMrng
        
        %How many divisions to divide the nonzero TPMs into
        ndivs = 3;
        
        typrng = [1 3]; %Which to plot
        
        %Get all TPMs >0
        tpmall = [tpm{:}];
        tpmall = tpmall(tpmall > 0); %This also skips NaNs
        
        %Divide by percentiles, so we can divide into ndivs regions
        tpmprc = prctile(tpmall, 100 * (1:ndivs-1) ./ ndivs); 
        
        %So we have 0, [first 1/ndiv nonzero, second 1/ndiv nonzero, ... last 1/ndiv nonzero]
        tpmrng = [-1 0 tpmprc inf];
end


figure('Name', sprintf('DNAcycP Results %s',inputname(1)), 'Color', [1 1 1])
hold on
len = length(typrng);
typrngdisp = '-0+b';
hei = length(tpmrng)-1; %Range is tpmrng(i) to tpmrng(i+1)
nn = zeros(len, hei);
nams = cell(len, hei);
for i = 1:len
    %Concatenate (if necessary) and reshape
    tmp = reshape([dat{:,typrng(i)}], nbp, []);
    xx = (1:nbp) - round(nbp/2);
    %Get tpm, crop to same length [in case not all the data is processed]
    tmptpm = tpm{typrng(i)};
    tmptpm = tmptpm(1:size(tmp,2));
    set(gca, 'ColorOrderIndex', 1);
    for j = 1:hei
        %Grab just the NPSes with the right TPM score
%         if j == hei 
%             tmp2 = tmp(:, isnan(tmptpm) ); %Genes with NaN value. Actually skip these
%         else
            tmp2 = tmp(:, tmptpm > tpmrng(j) & tmptpm <= tpmrng(j+1) );
%         end
        nn(i,j) = size(tmp2, 2);
        nams{i,j} = sprintf('Dir: %s, TPM: %0.1f+, N: %d', typrngdisp(typrng(i)), tpmrng(j), nn(i,j));
        yy = mean(tmp2, 2, 'omitnan')';
        %         y2 = median(tmp2, 2, 'omitnan')';
        ee = std(tmp2, [], 2, 'omitnan')' / sqrt( size(tmp2, 2) );
        %Flip the genes on the (-) strand
        if i == 1 && j==1 %Hard-coded order of -, 0, +, both
            %For - strand genes, plot flipped
%             plot(xx,yy)
            xx = fliplr(xx);
        end
        %Line style
        if i == 1
            lstyle = '--';
        else
            lstyle = '-';
        end
        ob = plot(xx,yy, lstyle); %Plot mean
        %     plot(xx,y2); %Plot median
        %     errorbar(xx,yy,ee); %Plot mean +- SEM, @errorbar isn't a great way to do this
        %Plot mean +- SEM as data band
        surfx = [xx fliplr(xx)];
        surfy = [yy + ee fliplr(yy-ee)];
        %     surfz = zeros(size(surfx));
        curcol = ob.Color;
        %Plot data band, lighter color + transparent
%         patch(surfx, surfy, mean( [curcol; 1 1 1], 1), 'FaceAlpha', 0.5, 'EdgeColor', 'none')
        
    end
end
nams = nams';
legend(nams(:));

% %Plot 601 as a reference line
% % Load from file
% cycref = load('cyc601.mat', 'cyc601');
% cycref = cycref.cyc601;
% %Center
% cycxx = (1:length(cycref)) - round(length(cycref)/2);
% %Scale to the same range as the current graph
% yl = ylim;
% wid = 0.05; %Pad on both sides by this amount of ylim
% cycyy = (cycref - min(cycref)) / range(cycref) * range(yl) *(1-wid*2) + yl(1) + range(yl)*wid;
% plot(cycxx, cycyy, 'k')

% %Legend and N
% nam0 = {'Gene <- (flipped)' 'Non-gene' 'Gene ->' 'Gene both'};
% nams = cellfun(@(x,y) sprintf('%s, N=%d', x, y), nam0, num2cell(nn), 'Un', 0);
% %If we also plotted patches, add 'Mean +- SEM'
% nams = [nams; repmat({'Mean±SEM'},1,4)];
% nams = [{'Gene <-'} nams(:)' {sprintf('601 (scaled, normal range %0.2f-%0.2f)', min(cycref), max(cycref))}];
% legend(nams)
% % legend({'Gene <- (flipped)' 'Non-gene' 'Gene ->' 'Gene both'})
% legend({'Gene <- (flipped)' '' 'Non-gene' '' 'Gene ->' '' 'Gene both' ''})

%Axis labels
ylabel('Predicted Relative Cyclizibility (DNAcycP, arbitrary)')
xlabel('Position from Dyad (bp)')

%Add guidelines for entry/dyad/exit
axis tight
yl = ylim;
arrayfun(@(x) line(147/2 * [1 1] * x, yl), -1:1)

%Shade 25bp off each edge, since this data is 'meaningless'
xl = xlim;
rectangle('Position', [xl(1) yl(1) 25 diff(yl)], 'EdgeColor', 'none', 'FaceColor', [0 0 0 0.25])
rectangle('Position', [xl(2)-25 yl(1) 25 diff(yl)], 'EdgeColor', 'none', 'FaceColor', [0 0 0 0.25])

%Plot 601 as a reference line




