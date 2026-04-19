function out = callofftester()

[f, p] = uigetfile('C:\Users\Abmtong\Desktop\Sala Data\*.dat', 'Mu', 'on');

% [f p] = uigetfile('D:\Data\250725 Avo FRET Tests\250728\*.dat', 'Mu', 'on');


%Select [off, cal] pair

%First is cal: Plot with this downsample

dtype = 'int16'; %Flzr
% dtype = 'single'; %Avo


figure, hold on

caldat = timeshareread( fullfile(p, f{1}) , dtype, 1);
offdat = timeshareread( fullfile(p, f{2}) , dtype, 1);

caldsamp = 1e3;
offdsamp = 1e1;


caly = windowFilter(@mean, caldat.AX, [], caldsamp);
calx = linspace(0,1,length(caly));
plot(calx, caly);

offy = windowFilter(@mean, offdat.AX, [], offdsamp);
offx = linspace(0,1,length(offy));
plot(offx, offy);