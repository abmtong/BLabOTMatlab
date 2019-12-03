function out = circsmooth(x, width)
%Like @smooth but handles edges by wrapping around

if nargin < 2
    width = 5;
end

%assert width is odd
hw = floor(width/2);
width = hw*2+1;
%pad front and back, filter, then clip front
out = filter(ones(1,width)/width, 1, x([end-hw+1:end 1:end 1:hw]));
out = out(width:end);