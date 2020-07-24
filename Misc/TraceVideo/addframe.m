function addframe(fn, fh, dt)
%Adds a frame to a gif (or creates it, if it doesn't exist)
%Inputs: FileName, FunctionHandle, DTime

%Print the current figure handle
[im, cm] = rgb2ind(frame2im(getframe(fh)),256);

%While @getframe is faster, if you want to use @print for special options, use below
% [im, cm] = rgb2ind(print(fh, '-RGBImage', '-r96'),256);

%Add to the .gif: Right now goes for no looping
if ~exist(fn, 'file')
    imwrite(im, cm, fn, 'gif', 'Loopcount', 0, 'DelayTime', dt)
else
    imwrite(im, cm, fn, 'gif', 'WriteMode', 'Append', 'DelayTime', dt)
end