function out = calcWork(x, kap)

%Calculates work by F dot dr
%input: x (position relative to trap center) and kap (spring constant)
%  How to figure out what is the trap center if there is always a force?
%  Simulate it, and find the difference

if nargin < 2
    kap = 1;
end


%change x(t) to dx(t)
dx = diff(x);

%fbar = avg_x * kap
xf = (x(1:end-1) + x(2:end))/2 * kap ;

%w = f * dr. Sign...?
out = sum(xf .* dx);