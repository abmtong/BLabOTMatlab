function pickbyeye_rth_wee(dat, ind)
if nargin < 2
    ind = 1;
end

%Add sumNucHist to path
thispath = fileparts(mfilename('fullpath'));
addpath(fullfile(thispath,'../PolRepeats/'))

%Shift y-value by this much per. Acts as Y cutoff for RTH, too
ysh = 5;

%Repeat info
opts.pauloc = 59;
opts.per = 64;
opts.n = 0;
%Nuc info
opts.disp = [63 96 155 204]-63; %Start P1, HP, Ter, per Wee
opts.disp2 = [62 67 79 100 115 124 131 141 167 187 211]-63+1; %Guess from gel interpolation
  %Ignore Runoff band because there's more template in OT
  %There are more bands: one between start and P1, some after HP, and some after Ter
  
%sumNucHist opts
opts.Fs = 4000/3;
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
trs = cellfun(@(x,y,z)plot(x,min(y, ysh, 'includenan')+z), xx, yy, yshcell, 'Un', 0); %'includenan' so min(nan, ysh) = nan, not ysh
%Plot sum RTH, save 
% plot(xg, yg)
%Plot pause line locs
yl = ylim;
for i = 1:opts.n
    %Plot blue line
    plot([1 1] * (opts.pauloc + opts.per * (i-1) ), yl,  'b')
end


%Green lines at disp locs
for i = 1:length(opts.disp)
    plot([1 1]*opts.disp(i), yl, 'g')
end
%Red lines at disp2 locs
for i = 1:length(opts.disp2)
    plot([1 1]*opts.disp2(i), yl, 'r')
end


function outputtf(~,~)
    %Assignin
    assignin('base', 'tfpbetmp', cellfun(@isvalid, trs))
    evalin('base', sprintf('tfpbe{%d} = tfpbetmp;', ind ) )
    fprintf('Picked %d out of %d traces\n', sum(cellfun(@isvalid, trs)), len)
end
end




