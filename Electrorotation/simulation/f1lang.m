function x = f1lang(trappos, inOpts)
%Langevin simulation of a particle (1D, = theta)

opts.x0 = 0;
opts.dt = 2.5e-4; %Seconds per tick, 4kHz
opts.tmax = 10; %Seconds to simulate
opts.fbarrier = 8; %pNnm, height of the F1 barrier (amplitude of sin wave)
opts.atp = 18; %kT
opts.trapk = 25; %kT /rad^2
opts.gam = 0.1; %Viscosity
opts.kT = 4.14;

if nargin < 1 || isempty(trappos)
    trappos = [0 0; 1 2*pi];
    opts.trapk = 0;
end

if nargin > 1
    opts = handleOpts(opts,inOpts);
end

%Unpackage some of the more popular opts
dt = opts.dt;
tmax = opts.tmax;
g = opts.gam;

%Force by F1, obtained from -del(U)
U = @(xx) opts.fbarrier/2*sin(3*xx) + opts.atp*3/2/pi*xx;
dU = @(xx) -3/2*opts.fbarrier*cos(3*xx) - opts.atp*3/2/pi;
%Trap gradient
T = @(xx) -opts.trapk * cos(2*xx);
dT = @(xx) -2*opts.trapk*sin(2*xx);

t = 0:dt:tmax;
n = length(t);
x = zeros(1,n);
x(1) = opts.x0;

tp = interp1(trappos(:,1), trappos(:,2), mod(t,trappos(end,1)));

% %Check magnitudes
% xm = linspace(0,2*pi,1e4);
% figure, plot(xm, dU(xm)), hold on, plot(xm,dT(xm))
% plot(xm,U(xm)), plot(xm, [diff(U(xm))/mean(diff(xm)) 1])

for i = 2:n
    x(i) = x(i-1)+ dT(x(i-1)-tp(i-1))/g*dt + dU(x(i-1))/g*dt + randn*sqrt(2*g*dt)/g;
end

% plot(t,x/2/pi), hold on, plot(t,tp/2/pi)