function data = plotMirrorOffset()
%Seems like AX and BX peak at different places, and I'll assume that avg = mirror offset
%Upon viewing, offset is weird, hexagonal peaks, don't fall on (1.4,0.9). Maybe need a bead to measure with precision.

[file, path] = uigetfile('*.dat');
if ~path, return, end
data = readDat([path file],1,8,'single',1);

mx = double(data(5,:));
my = double(data(6,:));
ax = double(data(3,:));

figure
plot3(mx, my, ax)

x = linspace(min(mx),max(mx),100);
y = linspace(min(my),max(my),100);

[xx, yy] = meshgrid(x,y);

zz = griddata(mx, my, ax, xx, yy);

figure
mesh(xx,yy,zz);