function rulerAlignChkBatch(out, outraw, opts)
%Verbose plot for rulerAlign batch mode
% Optional outraw for off/scl scatter (replace with empty to skip)

%Create figure
fg = figure('Name', 'RulerAlign Check Batch');
ax1 = subplot2([2,2],1);
hold(ax1, 'on')
title(ax1, 'Off/Scl Scatter')
ax2 = subplot2([2,2],2);
hold(ax2, 'on')
title(ax2, 'Aligned Traces')
ax3 = subplot2([2,2],3);
hold(ax3, 'on')
title(ax3, 'Aligned RTH')
ax4 = subplot2([2,2],4);
hold(ax4, 'on')
title(ax4, 'Repeat RTH')


%1 Off, Scl stats
if ~isempty(outraw)
    offs = [outraw.off];
    scls = [outraw.scl];
    offscrs = [outraw.offscr];
    sclscrs = [outraw.sclscr];
    
    scatter(ax1, offs, scls, [], offscrs/range(offscrs) + sclscrs/range(sclscrs), 'filled')
    for i = 1:length(offs)
        text(ax1, offs(i), scls(i), sprintf('%d', i));
    end
    colormap(ax1, 'winter')
    colorbar(ax1)
    
    axis(ax1, 'tight')
else
    delete(ax1);
end

%2 Plot aligned traces
cellfun(@(x)plot(ax2, (1:floor(length(x)/(2*opts.filwid+1)))/opts.Fs*(2*opts.filwid+1), windowFilter(@mean, x, [], 2*opts.filwid+1) ), out)
axis(ax2, 'tight')
xl = xlim(ax2);
arrayfun(@(x) plot(ax2, xl, x * [1 1]), bsxfun(@plus, opts.pauloc, (0:opts.nrep-1)'*opts.per))
cellfun(@(x, y) text(ax2,  length(x)/opts.Fs, x(end), sprintf('%d', y) ), out, num2cell(1:length(out)))

%3 Plot aligned histogram
[sumy, sumx] = sumNucHist(out, setfield(setfield(opts, 'verbose', 1), 'disp', [])); %#ok<SFLD>
%Hacky, copy the sumNucHist plot to here
fg2 = gcf;
ch = get(gca, 'Children');
copyobj(ch, ax3);
delete(fg2);
axis(ax3, 'tight')
ym = max( sumy( sumx > 0) );
if ~isempty(ym)
    ylim(ax3, [0 ym]);
end

%4 Plot sum histogram
inds = arrayfun(@(x) find(sumx >= x, 1, 'first'), (0:opts.nrep)*opts.per, 'Un', 0);
inds = [inds{:}];
yy = median( reshape( sumy(inds(1):inds(end)-1), [], length(inds)-1 ), 2 )';
xx = sumx(inds(1):inds(2)-1);
plot(ax4, xx,yy);
xlim(ax4, [0 opts.per])

yl = ylim(ax4);
arrayfun(@(x) line(ax4, x *[ 1 1], yl), opts.pauloc);




