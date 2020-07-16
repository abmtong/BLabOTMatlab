function out = vizSGF(iny, sgp, cleanup)
%Made for Lab OHs

if nargin < 3
    cleanup = 0;
end

%Filter and plot
[ydiff, yfil, ycrop] = sgolaydiff(iny, sgp);

Fs = 1e3;

%Scale ydiff
ydiff = ydiff * Fs;


fg = figure('Name', sprintf('SGF of trace with SGP n,k = %d, %d', [sgp{:}]));

ax1 = subplot2(fg, [3 1], [1 2], .1);
ax2 = subplot2(fg, [3 1], 3, .1);

plot(ax1, ycrop, 'Color', .7 * ones(1,3))
hold(ax1, 'on')
plot(ax1, yfil, 'Color', 'b');
plot(ax2, ydiff);
ylabel(ax1, 'Extension (nm)')
ylabel(ax2, 'Velocity (nm/s)')
xlabel(ax2, 'Time (pts@1kHz)')
linkaxes([ax1, ax2], 'x')

%Get vel dist, too
vdist(iny, struct('sgp', {sgp}, 'velmult', 1, 'vbinsz', .5, 'vfitlim', [-5 20], 'Fs', Fs, 'xlim', [-10 20]));

ax=gca;
xlabel(ax, 'Velocity (nm/s)')
ylabel(ax, 'Probability Density (s/nm)')
%User-select the pause cutoff
[vco, ~] = ginput(1);

%Determine by this cutoff what is paused
istloc = ydiff > vco;
indSta = find(diff([false ~istloc]) == 1);
indEnd = find(diff([~istloc false]) == -1);
ax0 = [];

if cleanup
    %Plot un-cleaned up
    fg = figure('Name', sprintf('SGF of trace with SGP n,k = %d, %d, uncleaned', [sgp{:}]));
    ax1 = subplot2(fg, [3 1], [1 2], .1);
    ax2 = subplot2(fg, [3 1], 3, .1);
    plot(ax1, ycrop, 'Color', .7 * ones(1,3))
    hold(ax1, 'on')
    surface(ax1,[1:length(yfil) ; 1:length(yfil)], [ycrop; ycrop], zeros(2,length(yfil)), double([istloc; istloc]), 'EdgeColor', 'interp')
    %Set up colormap
    colormap(ax1, 'copper')
    plot(ax2, ydiff);
    line(ax2, [1 length(ydiff)], vco*[1 1])
    ylabel(ax1, 'Extension (nm)')
    ylabel(ax2, 'Velocity (nm/s)')
    xlabel(ax2, 'Time (pts@1kHz)')

    ax0 = [ax1 ax2];
    
    %Do some cleanup of the sections
    %Remove small pauses: Let's say our detection limit is width/2
    minpau = sgp{2}/2;
    ki = (indEnd - indSta) > minpau;
    indSta = indSta(ki);
    indEnd = indEnd(ki);
    
    %Get every paused section
    len = length(indSta);
    paus = cell(1,len);
    for i = 1:len
        paus{i} = iny(indSta(i):indEnd(i));
    end
    paume = cellfun(@mean, paus);
    pautim = (indSta + indEnd) /2/Fs;
    
    dtvel = diff(paume) ./ diff(pautim);
    
    %Remove pauses that are different by less than a vel thr
    %Assumes , of course, that pauses
    ki = dtvel > vco;
    indSta = indSta([true ki]);
    indEnd = indEnd([ki true]);
    %Remake istloc
    istloc = true(1,length(yfil));
    for i = 1:length(indSta)
        istloc(indSta(i):indEnd(i)) = false;
    end
end
%Plot again, with color by pause state
fg = figure('Name', sprintf('SGF of trace with SGP n,k = %d, %d', [sgp{:}]));
ax1 = subplot2(fg, [3 1], [1 2], .1);
ax2 = subplot2(fg, [3 1], 3, .1);
plot(ax1, ycrop, 'Color', .7 * ones(1,3))
hold(ax1, 'on')
surface(ax1,[1:length(yfil) ; 1:length(yfil)], [ycrop; ycrop], zeros(2,length(yfil)), double([istloc; istloc]), 'EdgeColor', 'interp')
%Set up colormap
colormap(ax1, 'copper')
plot(ax2, ydiff);
line(ax2, [1 length(ydiff)], vco*[1 1])
ylabel(ax1, 'Extension (nm)')
ylabel(ax2, 'Velocity (nm/s)')
xlabel(ax2, 'Time (pts@1kHz)')

%Link all four axes
linkaxes([ax0 ax1, ax2], 'x')

%Output paused sections
len = length(indSta);
out = cell(1,len);
for i = 1:len
    out{i} = iny(indSta(i):indEnd(i));
end



