function xy2png(inx, iny, toprint, outname)
%just plots inx to iny (cell array)
%for lisa CaM f-x
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

%Set up figure and axes
fig = figure('Name','PrintWindow');
fig.Position = [100 100 640 480];
ax1 = axes;
hold (ax1,'on')
ax1.ClippingStyle = 'rectangle';
ax1.XLim = [0 1e4];
ax1.YLim = [0 20];
ax1.FontSize = 16;

%Make output folder
if toprint
    if ~exist(outname, 'dir')
        mkdir(outname)
    end
end

ax1.YLabel.String = 'Force (pN)';
ax1.XLabel.String = 'Extension (nm)';

ntr = length(inx);
spd = 4; %pts per tick
scale = 1;
imgctr = 0;
waitpuex = 60; % wait at pull/extend transition for this amount 
waitbtwn = 120; % wait at set transition for this amount
for j = 1:ntr
    x = inx{j};
    y = iny{j};
    len = length(x);
    ln(j) = plot(x(1),y(1)); %#ok<AGROW>
    
    q = floor((j-1)/2);
    r = mod(j, 2);
    
    if toprint
        switch r
            case 1
                if q>0
                    %if extending (odd r) and not the first pull, wait for waitbtwn, fade to grey
                    c1 = [0 0 1];
                    c1b = [1 0 0];
                    c2 = [.7 .7 .7];
                    for i = 1:waitbtwn
                        imgctr = imgctr + 1;
                        ln(q*2-1).Color = i/waitbtwn * c2 + (1-i/waitbtwn)* c1; 
                        ln(q*2).Color =   i/waitbtwn * c2 + (1-i/waitbtwn)* c1b; 
                        print(fig, sprintf('.\\%s\\%s%0.4d',outname,outname,imgctr),'-dpng',sprintf('-r%d',96*scale))
                    end
                end
            otherwise
                %if relaxing (even r), wait for waitpuex
                for i = 1:waitpuex
                    imgctr = imgctr + 1;
                    print(fig, sprintf('.\\%s\\%s%0.4d',outname,outname,imgctr),'-dpng',sprintf('-r%d',96*scale))
                end
        end
    end
    
    if q > 0
        ln(q*2-1).Color = [.7 .7 .7]; %#ok<AGROW>
        ln(q*2).Color = [.7 .7 .7]; %#ok<AGROW>
    end
    switch r
        case 1
            col = 'b';
        otherwise
            col = 'r';
    end
    

    for i = 1:spd:len
        %rm old line
        delete(ln(j))
        %plot new line
        ln(j) = plot(x(1:i), y(1:i), col, 'LineWidth', 1);
        %Print the figure
        if toprint
            imgctr = imgctr + 1;
            print(fig, sprintf('.\\%s\\%s%0.4d',outname,outname,imgctr),'-dpng',sprintf('-r%d',96*scale))
            %For some reason, r0 == r96 (1:1 scale)
        else
            drawnow
            pause(.016)%60fps ish
        end
    end
end
end