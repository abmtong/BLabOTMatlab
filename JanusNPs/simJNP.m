function out = simJNP()

%Bead radiii
r1 = 40;
r2 = 20;
dr = 50; %distances between centers

%Bead colors
c1 = [.8 .8 0]; %Au color2`
c2 = .8 * ones(1,3); %Ti color, lg gray

%Brownian noise
sig = 22; %nm, brownian noise sigma

%Flipping freq
tau = 60; %pts per flip, exponential mean. 30FPS

%Length is n flips
nflips = 10;

%Create a fictional trace with these noises
nf = ceil(exprnd(tau, 1, nflips));

%set up frame
fg = figure('Position', [ 0 0 960 540]);
fg.Color = ones(1,3);
ax = gca;
ax.XLim = [-200 200];
ax.YLim = [-200 200];
axis square

%Draw rectangles; want gold to show up over Ti so draw gold second
rec2 = rectangle('Position', [0 0 r2*2 r2*2], 'Curvature', 1, 'FaceColor', c2);
rec1 = rectangle('Position', [0 0 r1*2 r1*2], 'Curvature', 1, 'FaceColor', c1);

for i = 1:nflips
    x = randn(1, nf(i)) * sig;
    y = randn(1, nf(i)) * sig;
    for j = 1:nf(i)
        %get flip state
        if mod(i,2)
            x1 = x(j) + dr/2;
            x2 = x(j) - dr/2;
        else
            x1 = x(j) - dr/2;
            x2 = x(j) + dr/2;
        end
        %Position rectangles
        rec1.Position(1:2) = [x1-r1 y(j)-r1];
        rec2.Position(1:2) = [x2-r2 y(j)-r2];
%         drawnow
%         pause(.1)
        addframe('simjnp.gif', fg, .033, 1);
    end
end



%below: if we do it legit, but I just want to show it for illustrative purposes
%{
function out = simJNP(x, y, inOpts)
%Take AX and AY, 2-step HMM it, then plot what we "think" it is doing


%alphas
opts.ax = 1; %
opts.ay = 1; %Find a better estimate
opts.poldir = 1; %0 for x, 1 for y [trap A is Y-polarized, B is X-polarized]

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Two-state HMM
xhmm = stateHMMV2(x, struct('ns',2));
yhmm = stateHMMV2(y, struct('ns',2));
% Outputs are struct with fields start, finish; each with fields: a, mu, sig, pi, ns, fitmle, fit, fitnoopt
xhf = xhmm.finish.fit;
yhf = yhmm.finish.fit;

%

%Plot. Orient the centers at the same position, then 
%Create a of the jNP: this is Au with TiO2 doped, so large yellow + white sphere
r1 = 40; %Au radius
r2 = 20; %Ti radius
c1 = [.8 .8 0]; %Au color2`
c2 = .8 * ones(1,3); %Ti color, lg gray

%Hold coordinate of center of mass [say Ti and Au have equal enough masses, sue me]
xx = x - xhf;
yy = y - yhf;

x2 = xx;
y2 = yy;

%Convert from NV to nm
xx = xx * opts.ax;
yy = yy * opts.ay;
x2 = x2 * opts.ax;
y2 = y2 * opts.ay;

%Plot and output video
sph1 = rectangle('Position', [0 0 r1*2 r1*2], 'Curvature', 1, 'FillColor', c1);
sph2 = rectangle('Position', [0 0 r2*2 r2*2], 'Curvature', 1, 'FillColor', c2);

%}