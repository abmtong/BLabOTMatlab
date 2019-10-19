function [rsd, rsdraw] = calcResid(inx, iny)
%Calculates the 'straightness' of a protocol
%Fits a line with the required slope, outputs mean square error

%Rotation rate
hz = 1/inx(end);
%Rate to slope
m = 2*pi*hz;

%Get sign of slope
sgn = sign(iny(end) - iny(1));

if sgn > 0
    lin = @(x0,x) m * x + x0;
else
    lin = @(x0,x) -m * x + x0;
end

lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
[~, rsd, rsdraw] = lsqcurvefit(lin, 0, inx, iny, [], [], lsqopts);
rsd = rsd / length(inx); %rsd is sum square error, convert to MSE