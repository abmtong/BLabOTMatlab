function multilinkaxes(numaxes,axstr)
%Quick way to link multiple axes via graphical interface. Run, and click the approrpriate axes (2 sec pause in between each)

if nargin < 1
    numaxes = 2;
end

if nargin < 2
    axstr = 'xy';
end

ax = gobjects(1,numaxes);
for i = 1:numaxes
    fprintf('Click axis %d of %d.\n',i, numaxes)
    pause(2)
    ax(i) = gca;
end
linkaxes(ax,axstr);