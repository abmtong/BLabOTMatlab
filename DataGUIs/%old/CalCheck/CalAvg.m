function yy = CalAvg()
%Averages multiple cal files of the 2444kb size type

[f, p] = uigetfile('F:\BackUpFrom180GBHardDisk\2008\*.dat', 'MultiSelect', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end
len = length(f);

ys = cell(1, len);

for i = 1:len
    %Calibrate with default options
    ACalibrate([p f{i}]);
    fg = gcf; %ACalibrate plots a figure
    fgc = fg.Children; %4x1 Axes
    %pick AX, bc whynot - is at end because it's plotted first
    fgca = fgc(end);
    % pick whole, weakly filtered trace - is at end because it's plotted first
    fgcl = fgca.Children(end);
    x = fgcl.XData;
    ys{i} = fgcl.YData;
    close(fg);
end

yy = cell2mat(ys');

y = mean(yy, 1);
ysd = std(yy, 0, 1);

figure('Name', sprintf('%s et al, N=%d', f{1}, len) ), 
loglog(x,y)
%errorbar(x, y, ysd), set(gca, 'yscale', 'log'), set(gca, 'xscale', 'log')

end

