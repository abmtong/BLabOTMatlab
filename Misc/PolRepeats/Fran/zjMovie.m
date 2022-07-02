function zjMovie(tr, inOpts)

%Movie options.... eh just do this by editing
opts.Fs = 80;
opts.fil = 500; %Filter; 500-2k is probably good
opts.color = [1 0 0];

xl = [0 500];
yl = [500 700];
dt = 2; %Seconds to advance plot per frame

%Match the figure
% Let's just match the 'zzom' figure which has set axes

%y-axis is transcribed distance(bp)

figure('Name', 'zjMovie', 'Color', [1 1 1])


%Draw and label lines for NPS entry, dyad, and NPS exit

%Draw box for Time in upper-left

%Layering is trace below dotted lines , so I can do the box-drag trick
% (top) dotted lines > white rectangle > (bottom) trace

%So: plot the trace

xx = (1:length(tr))/opts.Fs;
yy = windowFilter(@mean, tr, opts.fil, 1);
pl = plot(xx, yy, 'Color', opts.color, 'LineWidth', 2);

ax = gca;
ylabel(ax, 'transcribed distance (bp)')
xlabel(ax, 'time (s)')

title(ax, 'Pol II transcription through ...') %Fix...

%Plot the rectangle
% rc = rectangle('Position', [0 0 1e3 2e3], 'FaceColor', [1 1 1], 'EdgeColor', [1 1 1]);
% Hmm i dont really like this rectangle pull for something so steep, you can tell
%So just do it by plotting

%Plot the dotted lines and their text
dotted = [558 631 704]-16;
txts = {' NPS Entry' ' dyad' ' NPS Exit'}; %Note prepended space
for i = 1:length(dotted)
    line([-1e3 1e3], dotted(i) * [1 1], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1)
    text( 0 , dotted(i), txts{i}, 'VerticalAlignment', 'top', 'FontSize', 12 )
end

%And the text/time box. Set xlim here
xlim(ax, xl)
ylim(ax, yl)
txbox = [110 12]; %Dimensions of box
rectangle('Position', [xl(1)  yl(2) - txbox(2) txbox]);
tx = text(xl(1), yl(2), ' Time: 0s', 'VerticalAlignment', 'top', 'FontSize', 12, 'LineWidth', 1);


%Draw a rectangle to act as the axis box
box(ax, 'off')
ax.TickDir = 'out';
rectangle('Position', [xl(1) yl(1) diff(xl) diff(yl)], 'FaceColor', 'none', 'LineWidth', 1.5)

%ACTUALLY do this by plotting
twin = xl(1):dt:xl(2); % t0:dt:tf;
hold(ax, 'on')
imgctr = 0;
outname = 'zjMov';

for i = 1:length(twin);
    imax = find(xx > twin(i), 1, 'first');
    if isempty(imax)
        imax = length(xx);
    end
    %Update line coords
%     rc.Position(1) = twin(i);
    set(pl, {'XData', 'YData'}, { xx(1:imax) yy(1:imax) })
    %Update text
    tx.String = sprintf(' Time: %ds', twin(i));
    %Write to image stack
    if toprint %or use @addframe
        imgctr = imgctr + 1;
        print(fig, sprintf('.\\%s\\%s%0.4d',outname,outname,imgctr),'-dpng',sprintf('-r%d',96*scale))
        %For some reason, r0 == r96 (1:1 scale)
    else
        drawnow
        pause(.016)%60fps ish
    end
end