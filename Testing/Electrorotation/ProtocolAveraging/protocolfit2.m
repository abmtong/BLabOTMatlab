function [out, fitfcn] = protocolfit2(inx, iny)
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

%Find inx spacing
dth = round(median(diff(inx))); %this requires integer dth, can come up with solutions for non-integer dth
%Assert that it's evenly spaced, i.e. difference < eps
assert(all(diff(inx) - dth < 1e-9), 'inx must be evenly spaced') %why is the difference ~ 1e-12, cf. eps ~ 1e-13
%For circgauss to work, 180/dth must be integer, so
assert(round(180/dth) == 180/dth, 'inx spacing must evenly divide 180')

oldy = iny;
%Convert to velocity?
%via sgolay
% iny = sgolaydiff(iny([end 1:end 1 2]), {1 3}); %add fwid before, fwid + 1 after
%via diff
% iny = diff(iny([1:end 1]));
% iny = circsmooth(iny, 5);

%cos(3 x)
fitfcn = @(x0,x) x0(1) * cos(2*pi*3*x/360 - x0(2)) + x0(3);
integfitfcn = @(x0,x) x0(1) * sin(2*pi*3*x/360 - x0(2)) * 360 / 6 / pi /2 /pi + x0(3);
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
xg = [range(iny)/2 max(iny) mean(iny)];
lb = [-inf -inf -inf ];
ub = [inf inf inf];
fit = lsqcurvefit( fitfcn, xg, inx, iny, lb, ub, lsqopts);
% figure, plot(inx, iny), hold on, plot(inx, fitfcn(fit, inx))
% subplot(2,1,2), plot(inx, oldy), hold on, plot(inx, integfitfcn(fit, inx) + mean(oldy))
out = fit;
end