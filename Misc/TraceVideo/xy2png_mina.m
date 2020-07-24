function xy2png_mina(inx, iny, toprint, outname)
%Animates a sequence of traces
%Plot, fade, plot, fade, etc. Meant to be changed per task. 191205
%Options are hard-coded (edit a few lines down)

if nargin < 3
    toprint = 0;
end
if nargin < 4
    outname = 'xy2png';
end
if ~iscell(inx)
    inx = {inx};
    iny = {iny};
end

%% Resolution and Timing
%Set up figure and axes
fg = figure('Name','PrintWindow');
fg.Position = [100 100 640 480];
%Timing options, to be set manually
dt = 0.02*2; %Sec/frame, probably dont go higher than say .04 = 25fps [recommended 0.02 = 50fps]
spd = 100; %Pts per frame
waitbtwn = round(1/dt); % Fade over these many frames
savetogif = 0; %Whether to save directly to gif or to an image stack

%% Colors and Naming
%Plot colors
c = {[0 0 0], [1 0 0], [0 1 0], [0 0 1]};
%Continue setting up figure and axes
fg.Color = [1 1 1];
ax1 = axes;
hold (ax1,'on')
ax1.ClippingStyle = 'rectangle';
ax1.XLim = [0 100];
ax1.YLim = [0 2.1];
ax1.FontSize = 16;
ax1.YLabel.String = 'Extension (\mum)';
ax1.XLabel.String = 'Time (s)';

%Force outname to be a .gif
[p, f, ~] = fileparts(outname);
if ~savetogif
    p = fullfile(p,f);
    if ~exist(p , 'dir')
        mkdir(p);
    end
    nn=0;
end
outname = fullfile(p, [f '.gif']);

%% Plot+Print loop
ntr = length(inx);
for j = 1:ntr
    x = inx{j};
    y = iny{j};
    len = length(x);
    ln(j) = plot(ax1, x, y, 'Color', c{j}, 'LineWidth', 1); %#ok<*AGROW>
    
    %Plot the pull
    for i = 1:spd:len
        %rm old line
        delete(ln(j))
        %plot new line
        ln(j) = plot(ax1, x(1:i), y(1:i), 'Color', c{j}, 'LineWidth', 1);
        %Print the figure
        if toprint
            if savetogif
                addframe(outname, fg, dt);
            else
                nn = nn + 1;
                print(fg, sprintf('%s/%s%04d%s', p,f,nn,'.png'), '-dpng', '-r96') %#ok<*UNRCH>
            end
        else
            drawnow
            pause(.016)%60fps ish
        end
    end
    
    %Fade it
    c1 = ln(j).Color;
    gry = [.95 .95 .95];
    prop = 10;
    c2 = (10 * gry + c1) / (prop +1);
    for i = 1:waitbtwn
        if j ~= 1 && j ~= ntr %Dont fade first, last traces
            ln(j).Color = c1 + (c2-c1) * (i/waitbtwn);
        end
        if toprint
            if savetogif
                addframe(outname, fg, dt);
            else
                nn = nn + 1;
                print(fg, sprintf('%s/%s%04d%s', p,f,nn,'.png'), '-dpng', '-r96') %#ok<*UNRCH>
            end
        else
            drawnow
            pause(dt)
        end
    end
end
end