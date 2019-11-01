function x = f1langkaw(trappos, inOpts)
%Langevin simulation of a particle (1D, = theta)
% Uses kawaguchi model of potential ('quick switching')

if nargin < 1 || isempty(trappos)
    trappos = [0 0; 1 2*pi];
end

opts.x0 = 0;
opts.dt = 2.5e-4; %Seconds per tick, 4kHz
opts.tmax = 10; %Seconds to simulate
opts.fbarrier = 8; %pNnm, height of the F1 barrier (amplitude of sin wave)
opts.atp = 18; %kT
opts.trapk = 25; %kT /rad^2
opts.gam = 0.1; %Viscosity
opts.kT = 4.14;

if nargin > 1
    opts = handleOpts(opts,inOpts);
end

%Unpackage some of the more popular opts
dt = opts.dt;
tmax = opts.tmax;
g = opts.gam;


%Potential of F1 and its -gradient

U = @(xx) opts.fbarrier * xx^2 / 2- log( exp(-opts.fbarrier*opts.fsstep*xx) + exp(opts.atp + opts.fbarrier*opts.fsstep^2/2) );
dU = @(xx) -opts.fbarrier*xx - opts.fbarrier*opts.fsstep* ( 1+exp(opts.atp + opts.fbarrier*opts.fsstep^2/2 + opts.fbarrier*opts.fsstep*xx) )^-1;

%Keq for switching from n to n+1 (syn) or reverse (hyd)
Rsyn = @(xx) exp( U(xx) - U(xx+120) + opts.atp );
Rhyd = @(xx) exp( U(xx) - U(xx-120) - opts.atp );

%Trap and -gradient
T = @(xx) -opts.trapk * cos(2*xx); %#ok<NASGU>
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

figure
for i = 2:n
    %Movement due to forces = F * dt / dC, + random brownian motion with variance 2kT/dC
%     dx1 = (dU(x(i-1)))* dt / dC;
%     dx11 = (dT(x(i-1)-tp(i)))* dt / dC;
%     dx2 = randn * sqrt(2*kT*dt/dC);
%     [dx1 dx11 dx2]
%     x(i) = x(i-1) + (dT(x(i-1)-tp(i-1)) + dU(x(i-1))) * dt / dC + randn * sqrt(2*kT*dt/dC);

%Below works ish, 15Hz
%     x(i) = x(i-1)+ dT(x(i-1)-tp(i-1))*opts.kT/g*dt + dU(x(i-1))*opts.kT/g*dt + randn*sqrt(2*g*opts.kT*dt)/g;
    
    %^ *kT is wrong, remove; better, ~4Hz
    x(i) = x(i-1)+ dT(x(i-1)-tp(i-1))/g*dt + dU(x(i-1))/g*dt + randn*sqrt(2*g*dt)/g;
    
%     x(i) = x(i-1)+ (dT(x(i-1)-tp(i-1)) + dU(x(i-1)) + randn*sqrt(2*g))/g*dt;
%     x(i) = x(i-1)+vg/g*dt;
    
%     if mod(i,1e5)==0
%         plot(x/2/pi)
%         drawnow
%     end
end


% plot(t,x/2/pi), hold on, plot(t,tp/2/pi)