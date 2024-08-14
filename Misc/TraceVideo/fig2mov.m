function fig2mov(infig, nframe)
%Create a movie (image stack) from a trace figure
% No axis shifting, fixed limits with increasing time
%  i.e. like pulling a shade off
% Can handle multiple axes, but only works with the same n_data
% If you have illustrative lines, make these simple lines (small data) and they'll be left there
%And you can make the image stack to a .gif with eg Photoshop or .mp4 with eg Avidemux

%So create a figure that has the aesthetics you want as the final frame, pass the handle as infig

if nargin < 2
    nframe = 600; %Number of frames to output -1
    % Output naming is %0.4d, so shouldn't do nframe > 1e4 (just add more zeroes)
    if nframe > 9999
        error('n frame too high, edit output naming to add more leading zeroes');
    end
end

%Movie options.... eh just do this by editing
scale = 1; %Relative size of saved image to figure

%Make a copy of the figure
fg = copyobj(infig, 0);
% Does copying like this work 100%?
%Get figure name for output naming
fignam = fg.Name;
%Make fignam a proper filename
fignam = matlab.lang.makeValidName(fignam);
%Add a preceding _ if fignam isn't empty
if ~isempty(fignam)
    fignam = ['_' fignam];
end

%Grab axes from figure children
ax = fg.Children;
%Filter to just axes
ki = arrayfun(@(x) isa(x, 'matlab.graphics.axis.Axes'), ax);
ax = ax(ki);

%Grab plots from axes
ob = [ax.Children]; %This will be all objects from all axes
%Only take Lines
ki = arrayfun(@(x)isa(x, 'matlab.graphics.chart.primitive.Line'), ob); %Is this m.g.c.p.Line or m.g.p.Line?
ob = ob(ki);
%And only take long plots, say XData length > nframe (or could just do length > like 10)
oblen = arrayfun(@(x) length(x.XData), ob);
ob = ob( oblen > nframe );
%Make sure ob isn't empty...
if length(ob) < 1
    error('No valid plot detected, exiting')
    delete(fg);
end

%Create timepoints
xl = xlim(ax(1));
tbin = linspace(xl(1), xl(2), nframe+1);

%Create output folder
outname = sprintf('fig2mov_%s%s', datestr(now, 'yymmddHHMMSS'),fignam);
if ~exist(['.\\' outname], 'dir')
    mkdir(['.\\' outname])
end
%Set up output sprintf string
nzero = ceil(log10(600));
zstr = sprintf('%d', nzero);
sfstr = ['.\\%s\\%s%0.', zstr 'd']; %Make \foldername\filename%0.4d ; the %0.#d depends on nframe

%Save figure in that folder for convenience
savefig(fg, sprintf('.\\%s\\%s',outname,'fig2mov'))
%Change the figure name, why not
fg.Name = 'fig2mov working...';
%Fix the axes
axis(ax, 'manual')

%Create frames in reverse, so we can continuously remove pts 
for i = nframe+1:-1:1
    %Delete xdata past tbin(i)
    for j = 1:length(ob)
        xx = ob(j).XData;
        ki = xx < tbin(i);
        xx = xx(ki);
        yy = ob(j).YData(ki);
        set(ob(j), 'XData', xx, 'YData', yy)
    end
    
    %Save png
    print(fg, sprintf(sfstr, outname,'fig2mov',i-1),'-dpng',sprintf('-r%d',96*scale))
end

%Delete the copied fig
delete(fg)



