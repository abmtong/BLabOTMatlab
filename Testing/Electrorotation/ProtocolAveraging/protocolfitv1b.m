function [out, fitfcn, rsd] = protocolfitv1b(inx, iny, dth)
%input: x,y of protocol/position prob. vs theta

%inx must be in degrees, check to make sure
mxx = max(inx);
if mxx <= 1
    inx = inx * 360;
    warning('inx detected to be in rotations, changed to deg')
elseif mxx <= 2*pi
    inx = inx / pi * 180;
    warning('inx detected to be in radians, changed to deg')
end

if nargin < 3
    %Find inx spacing
    dth = round(median(diff(inx))); %this requires integer dth, can come up with solutions for non-integer dth
    %Assert that it's evenly spaced, i.e. difference < eps
    assert(all(diff(inx) - dth < 1e-9), 'inx must be evenly spaced') %why is the difference ~ 1e-12, cf. eps ~ 1e-13
    %For circgauss to work, 180/dth must be integer, so
    assert(round(180/dth) == 180/dth, 'inx spacing must evenly divide 180')
end

%Constant + 3 gaussians?
% Also fit position histogram to this, to see if there's a correlation

%These have to be circular gaussians...
%For ease, granularize mu/x? NO I can probably just shift/ rotate x to get the job done ... ?
function p = circgauss(mu, sig)
    p = normpdf(inx , 180+rem(mu, dth), sig);
    p = p/max(p);
    p = circshift(p, [0,180/dth+floor(mu/dth)]);
end

fitfcn = @(x0) circgauss(x0(1), x0(2))*x0(3) +...
               circgauss(x0(4)+120, x0(5))*x0(6) +...
               circgauss(x0(7)+240, x0(8))*x0(9) + x0(10);
opfcn = @(x0) sqrt(abs(fitfcn(x0) - iny));
%x0 = [mn/sd/amp 1, 2, 3, const] : function of 10 numbers
mx = max(iny);
mn = min(iny);
rn = mx-mn;
xg = [0 30 rn 0 30 rn 0 30 rn mn];
lbs = [-30 0 0 -30 0 0 -30 0 0 mn];
ubs = [30 100 mx 30 100 mx 30 100 mx mn];

lsqopts = optimoptions('lsqnonlin');
lsqopts.Display = 'none';
[fit , rsd] = lsqnonlin(opfcn, xg, lbs, ubs, lsqopts); % , lbs, ubs);
% figure, plot(inx, iny), hold on, plot(inx, fitfcn(fit))
out = fit;
end