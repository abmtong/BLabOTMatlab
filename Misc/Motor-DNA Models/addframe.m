function addframe(fn, fh, dt, res)
%Adds a frame to a gif (or creates it, if it doesn't exist)
%Inputs: FileName, FunctionHandle, DTime, Resolution scale


if nargin < 4
    res = 1;
end

if nargin < 3
    dt = 0.05;
end

%Print the current figure handle

if nargin < 4 || res == 1
    [im, cm] = rgb2ind(frame2im(getframe(fh)),256);
else
    %@getframe is faster for exporting 1x images, if you want to use @print for upscaling, use below
    [im, cm] = rgb2ind(print(fh, '-RGBImage', sprintf('-r%d', 96*res)),256);
end

%Add to the .gif
if ~exist(fn, 'file')
    imwrite(im, cm, fn, 'gif', 'Loopcount', inf, 'DelayTime', dt)
else
    imwrite(im, cm, fn, 'gif', 'WriteMode', 'Append', 'DelayTime', dt)
end