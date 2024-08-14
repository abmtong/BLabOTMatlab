function plotDcPv2(dat, nbp)
%Plots output of prepDcPp2
% V2: plots mirrored about dyad, for easier comparisons
% Input: dat is 1x4 cell of 1xn NPS cyc-ity values
%  Join multiple inputs together by making a nx4 cell

%bp per nps
if nargin < 2
    nbp = 301;
end



%Plot here, too?
figure('Name', sprintf('DNAcycP Results %s',inputname(1)), 'Color', [1 1 1])
hold on
nn = zeros(1,4);
for i = 1:4
    %Concatenate (if necessary) and reshape
    tmp = reshape([dat{:,i}], nbp, []);
    nn(i) = size(tmp, 2);
    xx = (1:nbp) - round(nbp/2);
    yy = mean(tmp, 2, 'omitnan')';
    ee = std(tmp, [], 2, 'omitnan')' / sqrt( size(tmp, 2) );
    %Flip the genes on the (-) strand
    if i == 1 %Hard-coded order of -, 0, +, both
        %For - strand genes, flip x-axis
        xx = fliplr(xx);
    end
    %Plot RHS
    kir = xx >= 0;
    ob = plot(xx(kir),yy(kir));
    %Plot LHS, negated, as dashed
    kil = xx <= 0;
    plot(-xx(kil), yy(kil), '--', 'Color', ob.Color)
    

    %Let's not do a data band for these, just assume its 'small enough' as it has been seen
    % %     plot(xx,y2); %Plot median
% %     errorbar(xx,yy,ee); %Plot mean +- SEM, @errorbar isn't a great way to do this
%     %Plot mean +- SEM as data band
%     surfx = [xx fliplr(xx)];
%     surfy = [yy + ee fliplr(yy-ee)];
% %     surfz = zeros(size(surfx));
%     curcol = ob.Color;
%     %Plot data band, lighter color + transparent
%     patch(surfx, surfy, mean( [curcol; 1 1 1], 1), 'FaceAlpha', 0.5, 'EdgeColor', 'none') 
% %     surface([surfx;surfx], [surfy;surfy], [surfz;surfz], 'EdgeColor', 'none', 'FaceColor', mean( [curcol; 1 1 1], 1) )
end

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

%Legend and N
nam0 = {'Gene <- (flipped)' 'Non-gene' 'Gene ->' 'Gene both'};
nams = cellfun(@(x,y) sprintf('%s, N=%d', x, y), nam0, num2cell(nn), 'Un', 0);
%If we also plotted patches, add 'Mean +- SEM'
nams = [nams; repmat({'Pre-Dyad'},1,4)];
% nams = [{'Gene <-'} nams(:)' {sprintf('601 (scaled, normal range %0.2f-%0.2f)', min(cycref), max(cycref))}];
legend(nams(:))
% legend({'Gene <- (flipped)' 'Non-gene' 'Gene ->' 'Gene both'})
% legend({'Gene <- (flipped)' '' 'Non-gene' '' 'Gene ->' '' 'Gene both' ''})

%Axis labels
ylabel('Predicted Relative Cyclizibility (DNAcycP, arbitrary)')
xlabel('Position from Dyad (bp)')

%Add guidelines for exit/entry
axis tight
yl = ylim;
line(147/2 * [1 1], yl)
%And guideline for last 50bp cyc-ity
line( (147/2-25) * [1 1], yl)

%Shade 25bp off each edge, since this data is 'meaningless'
xl = xlim;
% rectangle('Position', [xl(1) yl(1) 25 diff(yl)], 'EdgeColor', 'none', 'FaceColor', [0 0 0 0.25])
rectangle('Position', [xl(2)-25 yl(1) 25 diff(yl)], 'EdgeColor', 'none', 'FaceColor', [0 0 0 0.25])


%







