function [outInd, outMean, outS] = findStepHistV7dlomemiter(inContour, inYRes, inNoise, p, inDec)
%Follows Aggarwal's method for iterative step detection
%V2: Made ~10x quicker (but more memory-intensive) by interpolating first, out of the loop
%V3: Increasing performance for wide-Y values by skipping some large step calculations (dBP > 30)
%V4: Handles p maybe slightly better?
%V5-6: Sloppy implementation of bead dynamics. If I implement, I'll do it right (i.e. measure bead response, create a filter that mimics it)
%V7: Revert to V4, speedup: store differential S, assemble it at the end (instead of assembling the best S every iter.)
%    5380-point long trace computation times: V7=16s; V4=138s [speed is now linear with points, not power law]
%    Waitbar removed, as extreme slowness is no longer an issue
% b: Some shortcuts in calculating dS(i,:), slight speedup (<10%)
% c: Matrix ops instead of second loop for 3x speed increase
% d: Further matrix ops for another ~2x speedup
% lomem: Right now, all of W is preallocated, when it might just be constant with 0 diagonal.
%        Make W made in loop (probably slower, but will work on infinitely long traces)

%%Ugh going to need to do some legwork to trim down dS: probably need dS(len x neigh) and dsOffset(1x len)

if nargin < 5 || isempty(inDec)
    inDec = 1;
end

if nargin < 3 || isempty(inNoise)
    inNoise = estimateNoise(inContour,125/inDec);
end
if nargin < 2 || isempty(inYRes)
    inYRes = 0.2;
end

%a is our vector of y-values, with which we coarse-grain our search
%Make a fall on "nice" numbers
minC = floor(min(inContour));
maxC = ceil(max(inContour));
a = minC:inYRes:maxC+inYRes;

len = length(inContour);
hei = length(a);

pen = 3^2; %Penalty factor, Aggarwal has it as 9 (arguing that 3*sd [=9*var] should mean a significant change)

%J stores the current score. We start at the first point, so it's just the quadratic error
J = (inContour(1) - a).^2;

%Timing
startT = tic;

%Only consider points within a neighborhood
neigh = max(30, 1.1*max(abs(diff(inContour))));
neighwid = ceil(neigh/inYRes);
neighpt = 2*neighwid+1;
%Find the optimal path to traverse to any ending y-point by searching one time-point at a time
%dS is where we'll store the optimal path information: if the optimal path is (t,a(p)) to (t+1,a(q)) then dS(t,q) = p
%Old dS = newdS(i,:) + dSoffset(i)
dS = zeros(len-1,neighpt);
dSoffset = zeros(1,len-1);

if nargin<4 || isempty(p)
    %Standard W
    W = pen*inNoise*ones(neighpt);
    W(1:neighpt+1:end) = 0; %Zero the diagonal
else
    %If we're given a distribution, calculate W by interpolating. Penalty is proportional to -log(p)
    W = zeros(neighpt);
    for j = 1:neighpt
        W(j,:) = -pen/4.5*inNoise*log( interp1(p(:,1),p(:,2), inYRes * (j-(1:neighpt)) ) ); %Packaging is a positive step size, by this def'n
        W(j,j) = 0;
    end
    %Interp1 doesn't like interping values outside the given range, so set them to something (large) - this is the value Aggarwal had
    W(isnan(W)) = pen/4.5*50*inNoise;
    %And log(0) = -Inf
    W(isinf(W)) = pen/4.5*50*inNoise;
end

%Progress meter
fprintf('[')

for i = 1:len-1
    %Bdy values
    %Max/min's seem unnecessary
%     ymin = max(1  , find(a > inContour(i+1)-neigh, 1, 'first') );
%     ymax = min(hei, find(a < inContour(i+1)+neigh, 1, 'last' ) );
    ymin = find(a > inContour(i+1)-neigh, 1);
    ymax = find(a < inContour(i+1)+neigh, 1, 'last');
    yRange = ymin:ymax;
    dSoffset(i) = ymin-1;
    yr = length(yRange);
    
    [dJ, ddS] = min( bsxfun(@plus,J(yRange)', W(1:yr,1:yr)),[],1);
    dS(i,:) = [ddS zeros(1,neighpt-length(ddS))]+ymin-1;
    J = Inf(1,hei);
    J(yRange) = dJ + (inContour(i+1) - a(yRange)).^2;
    
    %update waitbar
    if ~mod(i, floor((len-1)/10))
        fprintf('|')
    end
end
fprintf(']')

%Now we have J and dS for the whole trace, just need to pick the victor, assemble the trace
[~, ind] = min(J);

%Translate dS into the trace, outS
Sind = zeros(1,len);
Sind(len) = ind;
for i = len-1:-1:1
    Sind(i) = dS(i,Sind(i+1)-dSoffset(i));
end
outS = a(Sind);

[outInd, outMean] = tra2ind(outS);
fprintf('Hst: Found %d st over %0.2fbp in %0.2fs.\n',length(outMean)-1,outMean(1) - outMean(end),toc(startT));