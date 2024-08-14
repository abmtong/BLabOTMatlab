function outp = plotDcP_bar(dat, nbp)
%Plots output of prepDcPp2
% V2: plots mirrored about dyad, for easier comparisons
% Input: dat is 1x4 cell of 1xn NPS cyc-ity values
%  Join multiple inputs together by making a nx4 cell

%bp per nps
if nargin < 2
    nbp = 301;
end

%Also, make a ... bar graph? with a p-value matrix? 
% xbar = [-73 -73+25 0 73-25 73]; %Look at these five values alone: edges, arms, center
% xbar = 0; %Look at these five values alone: edges, arms, center
% xbar = [-73 73]; %Look at these five values alone: edges, arms, center
xbar = [-73+25 73-25]; %Look at these five values alone: edges, arms, center
hei = length(xbar);

%Plot here, too?
figure('Name', sprintf('DNAcycP Results %s',inputname(1)), 'Color', [1 1 1])
hold on
nn = zeros(1,4);
%Extract certain columns, save here
outraw = cell(hei,4); %(xbar(i), geneID)

for i = 1:4
    %Concatenate (if necessary) and reshape
    tmp = reshape([dat{:,i}], nbp, []);
    nn(i) = size(tmp, 2);
    xx = (1:nbp) - round(nbp/2);
    %Extract data on specific x positions
    for j = 1:hei
        outraw{j,i} = tmp( find(xx == xbar(j),1,'first'), :);
    end
end


%Do T-test matrix
% Matrix edges are in order of outraw(:), so easy

len = numel(outraw);
outp = zeros(len);

for i = 1:len
    %Set diagonal
    outp(i,i) = 1;
    text(i,i,1.01, '0', 'HorizontalAlignment', 'center', 'Color', .85*[1 1 1], 'FontSize', 14)
    for j = i+1:len 
        %Just calculate upper diagonal and set to lower diagonal
        [~, tmp] = ttest2( outraw{i}, outraw{j} );
        outp(i,j) = tmp;
        outp(j,i) = tmp;
        
        %Plot labels
        text(i,j,1.01, sprintf('%0.1f', log10(tmp)), 'HorizontalAlignment', 'center', 'Color', .85*[1 1 1], 'FontSize', 14)
        text(j,i,1.01, sprintf('%0.1f', log10(tmp)), 'HorizontalAlignment', 'center', 'Color', .85*[1 1 1], 'FontSize', 14)
    end
end

%Plot outp mtx , as bar
br= bar3(outp);
%Set height = color. See >>doc Color 3-D Bars by Height
for i = 1:length(br)
    br(i).CData = log10(br(i).ZData);
    br(i).FaceColor = 'interp';
end


%Create x-label mtx ?
lbls = cell(hei,4);
chrs = '-0+b'; %- strand, no gene, + strand, both strands
for i = 1:hei
    for j = 1:4
        lbls{i,j} = sprintf('%s#%02d',chrs(j), xbar(i) );
    end
end

%Apply labels as xlabels

axis tight
ax=gca;
lbls = lbls(:)';
ax.XTick = 1:len;
ax.XTickLabel = lbls;
ax.YTick = 1:len;
ax.YTickLabel = lbls;
ax.XTickLabelRotation = 90;

%Maybe make colormap to cover like p<1e-3, 1e-2, .05, etc.
ax.CLim = [-10 0];
colorbar
colormap jet
%Here, jet dark red is p>.05, red is 0.01, orange is .001, bluer = way diff



