function x = f1sim(trappos, inOpts)

if nargin < 1
    trappos = [0 0; 1 1];
end

opts.dt = 1e-5; %Seconds per tick
opts.tmax = 1; %Seconds to simulate
opts.kT = 4.14; %kT, pNnm
opts.fbarrier = 300; %pNnm, height of the F1 barrier (amplitude of sin wave)
%Calculate the energy of hydrolysis of 3 ATPs: 3ATP -> 3ADP + 3Pi
% opts.atp3 = -3 * (30.5e3/6.02e2 + opts.kT * log(10*1e3));
opts.atp3 = 200;
opts.trapk = 20000; %pNnm /rad^2
opts.dC = 6*pi*1e-9*1*20; %'Drag coefficient' of the bead
% opts.dC = 1e-2;

if nargin > 1
    opts = handleOpts(opts,inOpts);
end

%Unpackage some of the more popular opts
dt = opts.dt;
tmax = opts.tmax;
kT = opts.kT;
dC = opts.dC;


%Potential of F1 itself. Define sign to be "change in ATP" (+ is synthesis)
% U=@(xx) -opts.fbarrier*cos(6*pi*xx) - opts.atp3*xx;
dU = @(xx) -opts.fbarrier*sin(6*pi*xx) + opts.atp3;
%a1 is the height of the F1 barrier
%a2 is the energy of ATP hydrolysis per rev.

%Trap gradient
dT = @(xx) -opts.trapk*cos(4*pi*xx);

t = 0:dt:tmax;
n = length(t);
x = zeros(1,n);

tp = interp1(trappos(:,1), trappos(:,2), mod(t,trappos(end,1)));

% %Check magnitudes
% xm = linspace(0,1,1e4);
% figure, plot(xm, dU(xm)), hold on, plot(xm,dT(xm))
% plot([0 1], opts.atp3*[1 1])

v=0;

figure
for i = 2:n
    %Movement due to forces = F * dt / dC, + random brownian motion with variance 2kT/dC
%     dx1 = (dU(x(i-1)))* dt / dC;
%     dx11 = (dT(x(i-1)-tp(i)))* dt / dC;
%     dx2 = randn * sqrt(2*kT*dt/dC);
%     [dx1 dx11 dx2]
%     x(i) = x(i-1) + (dT(x(i-1)-tp(i-1)) + dU(x(i-1))) * dt / dC + randn * sqrt(2*kT*dt/dC);
    
    a = (dT(x(i-1)-tp(i-1)) + dU(x(i-1))) + randn * sqrt(2*kT/dC);
    v = v + a*dt;
    x(i) = x(i-1)+v*dt;
    
    if mod(i,1e5)==0
        plot(x)
        drawnow
    end
end


plot(t,x)