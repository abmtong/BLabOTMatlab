function [ft, ripf] = pulldist(t10, spd, dx, verbose)

%Simulates the rip f dist of a pull

%input:
% t10: mean lifetime at 10pN. Just make up some number. Equals 1/k at 10pN
% spd: pulling speed, pN/s. At 5-30pN ish, the F-t graph is pretty linear, so just use this as a shortcut
% dx: scale k(F) = 1/t10 * exp( (F-10) * dx/kT ) ; kT = 4.14

%So , course-grain time, pull, roll the dice, then get a distribution


if nargin < 4
    verbose = 1;
end

f0 = 3; %Start force, pN
dt = .01/spd; %Timestep, just use 'small enough'
n = 1e5; %Times to simulate
fmax = 40; %Use some upper limit force

%Precalc some things
frng = f0:dt*spd:fmax;
kf = 1/t10 * exp( (frng-10)*dx/4.14 ) * dt;
%Cut off if kf > 1 for speed
ind = find(kf > 1, 1, 'first');
if ind
    kf = kf(1:ind);
    frng = frng(1:ind);
end

ripf = zeros(1,n);
for i = 1:n
    %Generate random numbers the same size of kf
    rr = rand(size(kf));
    ind = find(rr < kf, 1, 'first');
    if isempty(ind)
        %Probably won't happen, but just set as max
        ripf(i) = fmax;
    else
        ripf(i) = frng(ind);
    end 
end


[yy, xx] = hist(ripf, 100);

ynorm = yy / sum(yy) / (xx(2)-xx(1)); %Normalize
%Fit a skew gaussian, = normpdf * (1 + erf( (x-mu) * skew / sqrt(2) ) );
skgpdf = @(x0,x) normpdf(x, x0(1), x0(2) ) .*(1+ erf((x-x0(1))*x0(3)/sqrt(2)) ) *x0(4);
xg = [mean(ripf), std(ripf), skewness(ripf) , 1]; %Mean, SD, skew, height
lb = [0 0 -inf 0];
ub = inf(1,4);
ft = lsqcurvefit(skgpdf, xg, xx, ynorm, lb, ub);

%Plot if verbose
if verbose
    figure,
    bar(xx,ynorm, 'EdgeColor', 'none', 'BarWidth', 1)
    hold on
    plot(xx, skgpdf(ft, xx) , 'r', 'LineWidth', 1)
end

