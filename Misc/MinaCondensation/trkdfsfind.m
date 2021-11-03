function outtr = trkdfsfind(intr, pkloc)

%Max- and min-filter the trace to create an envelope
% Interp at each pkloc to get boundaries
filwid = 10; %For true gaussian noise, this gets ~95% there in ~10pts

ub = windowFilter(@max, intr, filwid, 1);
lb = windowFilter(@min, intr, filwid, 1);

%Get direction (or set direction)
pf = polyfit(1:length(intr), intr, 1);
dir = sign(pf(1));

%Transform by dir, making this trace 'increasing'
ub = ub * dir;
lb = lb * dir;

%Find crossing pts of line y=pkloc(i)
cra = arrayfun(@(x) find( 1 == diff( [0 ub>x] )), pkloc*dir);
crb = arrayfun(@(x) find( 1 == diff( [0 lb>x] )), pkloc*dir);

%Create output trace
outx = [cra; crb];
outx = outx(:)';
outy = [pkloc; pkloc];
outy = outy(:)';

%If I want the output to be like a 'trace' (i.e. uniformly spaced in x:
%Resample using resample?
% outtr = resample( timeseries(outx, outy), 1:length(intr), 'linear');
%Should handle duplicate values here. Also 
% outtr = interp1([-1 outx length(intr)+1 ], [intr(1) outy intr(end)], (1:length(intr)));

%If I don't care, and are okay with say a column-vector:
outtr = [[1 outx length(intr)]' [intr(1) outy intr(end)]'];