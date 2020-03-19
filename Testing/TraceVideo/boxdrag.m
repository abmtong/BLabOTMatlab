function boxdrag(outname, fig)
%Drags a white box across all axes in a figure, for animating.
%Outputs an image sequence; assemble with e.g. Avidemux
%First used in JohnMovie

if nargin < 2
    fig = gcf;
end

if nargin < 1
    outname = 'boxdrag';
end

%Set movie length
nframes = 1 + 8*60; %e.g. for a 8s, 60fps movie do 1+8*60. Add 1 because last frame doesn't have 'time'

%Get the axes in this figure
axs = fig.Children;
axs = axs( arrayfun(@(x)isa(x, 'matlab.graphics.axis.Axes'), axs) );
%Convert to cell, to use @cellfun
axs = num2cell(axs);

%Set axes on top, so Rectangle draws underneath the axis borders
cellfun(@(x)set(x, 'Layer', 'Top'), axs)

%Get axes limits
xls = cellfun(@(x)get(x, 'XLim'), axs, 'Un', 0);
yls = cellfun(@(x)get(x, 'YLim'), axs, 'Un', 0);

%Draw a rectangle covering each axis
rects = cellfun(@(w,x,y) rectangle(w,'Position', [x(1) y(1) diff(x) diff(y)], 'FaceColor',[1 1 1], 'EdgeColor', [1 1 1]), axs, xls, yls, 'Un', 0);

%Make folder
if ~exist(outname, 'dir')
    mkdir(outname)
end

%Precalculate x, x width of every frame [use @linspace for a linear drag]
xs = cellfun(@(x)linspace(x(1), x(2), nframes), xls, 'Un', 0);
xw = cellfun(@(x)linspace(diff(x), 0, nframes), xls, 'Un', 0);

for i = 1:nframes
    %Move rectangle
    cellfun(@(w,x,y,z) set(w, 'Position', [x(i) z(1) y(i) diff(z)]), rects, xs, xw, yls);
    %Write frame
    print(fig, sprintf('%s/%s%04d', outname, outname, i), '-r96', '-dpng')
%     %For showing animation without writing files
%     drawnow
%     pause(.01)
end

%Clean up: Remove rectangles
cellfun(@delete, rects)







