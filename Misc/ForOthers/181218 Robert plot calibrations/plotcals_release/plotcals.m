function out = plotcals()
%Robert wants to see the fx of trap A on trap B
%Inputs: Regular cal, then cal data taken with empty trap A, moving closer to it

%choose calibration file to use for others
[f, p] = uigetfile('*.dat','Choose the calibration file');
if ~p
    return
end

%{
opts.raA = 500;
opts.raB = 500;
%}

cal = ACalibrate([p f]);

%choose files to plot
[f, p] = uigetfile('*.dat', 'Choose the files you want to plot', 'MultiSelect', 'on');

if ~p
    return
end
if ~iscell(f)
    f = {f};
end

out = cell(1,length(f));
for i = 1:length(f)
    tmpdat = processHiFreq([p f{i}]);
    figure ('Name', f{i})
    plot(tmpdat(3,:) ./ tmpdat(7,:) * cal.AX.a)
    tmpout.data = tmpdat;
    tmpout.cal = cal;
    out{i} = tmpout;
end