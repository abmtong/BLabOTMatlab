function infp = ezPlotAvo(infp)


%Filtering options
 %Trap downsample wid, dsamp, for use in windowFilter(@median, x, fil, dsamp)
xfil = [];
xdsamp = 10;


%Fluorescence options
fdsamp = 3; %Fluorescence dsamp. 10ms a 'good' starting dsamp for fluor
ffil = 2; %Filter by this much AFTER downsampling. Median.
% lstyle = {'' ':' '--'}; %Styles for line 1/2/3 , regular '', dotted ':', dashed '--', dotted ':'
lstyle = {'' ':' '--'}; %Styles for line 1/2/3 , regular '', dotted ':', dashed '--', dotted ':'

%Some way to encode scaling/offsetting? a 3x3x3 matrix?


plotbgr = [1 1 0]; % B G R y/n source lasers

%Permute lstyle such that first plotbgr == 1 is lstyle(1)
lstyle = circshift(lstyle, [0 find(plotbgr==1, 1, 'first')-1]);

if nargin < 1
    [f, p] = uigetfile('', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    infp = cellfun(@(x) ezPlotAvo(fullfile(p,x)), f, 'Un', 0);
    return
end


%Load file
cd = load(infp);
cd = cd.ContourData; %Just assume for now

%Set up axes
[~, f, ~] = fileparts(infp);
fg = figure('Name', f);
ax1 = subplot2(fg, [2 1], 1, .1);
ax2 = subplot2(fg, [2 1], 2, .1);
hold(ax1, 'on')
hold(ax2, 'on')

ylabel(ax1, 'Extension (nm)')
ylabel(ax2, 'Counts (kHz)')
xlabel(ax2, 'Time (s)')


%Load time, extension 
tt = cd.time;
xx = cd.extension;
xx = windowFilter(@median, xx, xfil, xdsamp);
tt = windowFilter(@median, tt, xfil, xdsamp);
plot(ax1,tt,xx);

%Load fluorescence, base code taken from PhageGUI

%Downsample, convert counts to Hz
gt = windowFilter(@mean, cd.apdcolT, [], fdsamp);
fdat = cellfun(@(x) windowFilter(@sum, double(x) / (gt(2)-gt(1)) /1000, [], fdsamp), cd.apdcol, 'Un', 0);
%Smooth
gt = windowFilter(@median, gt, ffil, 1);
fdat =  cellfun(@(x) windowFilter(@median, x, ffil, 1), fdat, 'Un', 0);

cols = 'bgr';
for j = 1:3
    if plotbgr(j)
        for i = 1:3
            plot(ax2, gt, fdat{j,i}, [cols(j) lstyle{ i }], 'LineWidth', 2)
        end
    end
end

%Legend for source laser. Maybe add an invisible black line for legend purposes? na
lgn = {'Blue Laser' 'Green Laser' 'Red Laser'};
% lgn = lgn( logical( plotbgr ) );
legend(ax2, lgn)

linkaxes([ax1 ax2], 'x');




