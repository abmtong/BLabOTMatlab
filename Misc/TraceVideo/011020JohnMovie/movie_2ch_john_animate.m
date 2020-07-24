function movie_2ch_john_animate(outname, fig)

if nargin < 2
    fig = gcf;
end

if nargin < 1
    outname = 'JohnMovie';
end

%Set options
ttot = 8; %Runtime, seconds
fps = 60; %Frames per second

%For each axis in this figure...
axs = fig.Children;
axs = axs( arrayfun(@(x)isa(x, 'matlab.graphics.axis.Axes'), axs) );
%Convert to cell
axs = num2cell(axs);

cellfun(@(x)set(x, 'Layer', 'Top'), axs)

%Get axes limits
xls = cellfun(@(x)get(x, 'XLim'), axs, 'Un', 0);
yls = cellfun(@(x)get(x, 'YLim'), axs, 'Un', 0);

%Draw a rectangle on each axis
recs = cellfun(@(w,x,y) rectangle(w,'Position', [x(1) y(1) diff(x) diff(y)], 'FaceColor',[1 1 1], 'EdgeColor', [1 1 1]), axs, xls, yls, 'Un', 0);

%Make folder
if ~exist(outname, 'dir')
    mkdir(outname)
end

%Move rectangle, write frame
nframes = ttot*fps+1;
%Precalculate xs, widths
xs = cellfun(@(x)linspace(x(1), x(2), nframes), xls, 'Un', 0);
xw = cellfun(@(x)linspace(diff(x), 0, nframes), xls, 'Un', 0);

for i = 1:nframes
    %Move rectangle
    cellfun(@(w,x,y,z) set(w, 'Position', [x(i) z(1) y(i) diff(z)]), recs, xs, xw, yls);
    %Write frame
    print(fig, sprintf('%s/%s%04d', outname, outname, i), '-r96', '-dpng')
% drawnow
% pause(.01)
end










