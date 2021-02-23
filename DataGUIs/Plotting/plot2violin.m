function out = plot2violin(inax, inOpts)

opts.filwid = 5; %To convert to kdf, smooth it
opts.perm = []; %May need to permute the order of the plots (default plots in reverse order)
opts.stats = [0 1]; %Plot [mean, median] boolean
opts.outfig = [];
% opts.lims = [-inf inf]; %

if nargin >= 2
    opts = handleOpts(opts, inOpts);
end

if nargin < 1 || isempty(inax)
    inax = gca;
end

%Get children [flip, so they are in plotting order]
ch = flipud(inax.Children);
ymx = inax.YLim(2);
xl = inax.XLim;

%Output axis
if isempty(opts.outfig)
    opts.outfig = figure;
end
%Start it as a copy of the original axis
outax = copyobj(inax, opts.outfig);
arrayfun(@delete,outax.Children);

for i = 1:length(ch)
    %Get the x,y data of the graph [make row vectors, too]
    xx = ch(i).XData(:)';
    yy = ch(i).YData(:)';
    
    %Smooth
    yy = smooth(yy, opts.filwid)'; %Alternately, gaussian filter (closer to what @ksdensity would do)
    
    %Make the patch x/y, trace starting from -x axis
    px = [xx fliplr(xx)];
    py = [yy -fliplr(yy)] / ymx/2; %Scale py
    %May need to add the starting point to the end, we'll see
    
    %Plot this guy at x=i
    patch(outax, py+i, px, ch(i).Color)

    %Calculate mean or median and label
    if opts.stats(1)
        %Calc mean
        mnx = xx * yy' / sum(yy);
        mny = interp1(xx, yy, mnx);
        %Plot line
        line(outax, i + (mny * [-1 1]), mnx * [1 1], 'Color', 'k', 'LineWidth', 1)
    end
    if opts.stats(2)
        %Calc median
        cy = cumsum(yy);
        [~, ki] = unique(cy);
        mnx = interp1(cy(ki), xx(ki), cy(end)/2);
        mny = interp1(xx, yy, mnx);
        line(outax, i + (mny * [-1 1])/ ymx/2, mnx * [1 1], 'Color', 'k', 'LineWidth', 1)
    end
end
xlim(outax, [0 i+1])
ylim(outax, xl)
