function [ft, fitfcn] = fitP29ForVel(f, v, inOpts)

%For-Vel should be dwell (constant) + burst (F-dep, Arrhenius)

%Convert bp/s to avg cycle time
% cyc = 10./v;

%Curvefit: Cycletime = dwell + prefactor * exp(F*x0/kT)
% x0 = [dwell prefactor x0]
fitfcn = @(x0,x) 10./ (x0(1) + x0(2) * exp(x*x0(3)/4.14));

gu = [0.100 0.030 2.5*.34]; %100ms, 30ms, 2.5bp

lb = [0 0 0];
ub = [inf inf inf];

% lb = [0 0 .57];
% ub = [inf inf .57];

ft = lsqcurvefit(fitfcn, gu, f, v, lb, ub);

figure('Name', sprintf('Dwelltime %0.1f ms, dx %0.3f nm', 1000*ft(1), ft(3)))
plot(f, v), hold on, plot(f, fitfcn(ft,f))