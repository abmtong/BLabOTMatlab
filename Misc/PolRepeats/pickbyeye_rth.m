function pickbyeye_rth(dat, ind)
if nargin < 2
    ind = 1;
end
%Shift y-value by this much per
ysh = 1;

%Repeat info
opts.pauloc = 59;
opts.per = 64;
opts.n = 8;
%Nuc info
opts.disp = [558 631 704]-16;

%sumNucHist opts
opts.Fs = 1e3;
opts.verbose = 0;
opts.shift = 0;
opts.fil = 20; %41pts @ 800Hz = 20Hz filter

%Calculate RTHs: singles and global
[yy, xx] = cellfun(@(x)sumNucHist(x, opts), dat, 'Un', 0);
% [yg xg] = sumNucHist(dat, opts);

len = length(dat);
fprintf('Picking %d traces by eye\n', len)
yshcell = num2cell(ysh * (0:len-1));
fg = figure;
hold on
uicontrol(fg, 'Units', 'normalized', 'Position', [0, 0, .05, .05], 'String', '[Output bool]', 'Callback', @outputtf);
%Plot RTHs, save handles
trs = cellfun(@(x,y,z)plot(x,min(y, ysh)+z), xx, yy, yshcell, 'Un', 0);
%Plot sum RTH, save 
% plot(xg, yg)
%Plot pause line locs
yl = ylim;
for i = 1:opts.n
    %Plot blue line
    plot([1 1] * (opts.pauloc + opts.per * (i-1) ), yl,  'b')
end
%Plot red lines at -1 and n+1 repeat
plot([1 1]*(opts.pauloc + opts.per*-1), yl, 'r')
plot([1 1]*(opts.pauloc + opts.per*(opts.n)), yl, 'r')
%Green lines at nuc pos;s
for i = 1:length(opts.disp)
    plot([1 1]*opts.disp(i), yl, 'g')
end
% %Red line at n+1 nuc and n-1 nuc
% plot([1 1]*(opts.disp(end) - opts.per), yl, 'r')
% plot([1 1]*(opts.disp(end) + opts.per), yl, 'r')

function outputtf(~,~)
    %Assignin
    assignin('base', 'tfpbetmp', cellfun(@isvalid, trs))
    evalin('base', sprintf('tfpbe{%d} = tfpbetmp;', ind ) )
    fprintf('Picked %d out of %d traces\n', sum(cellfun(@isvalid, trs)), len)
end
end




