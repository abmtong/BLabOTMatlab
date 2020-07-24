function [outInd, outMean, outS] = findStepHistV8c(inContour, inYRes, inNoise, p, inDec)
%Follows Aggarwal's method for iterative step detection
%V2: Made ~10x quicker (but more memory-intensive) by interpolating first, out of the loop
%V3: Increasing performance for wide-Y values by skipping some large step calculations (dBP > 30)
%V4: Handles p maybe slightly better?
%V5-6: Sloppy implementation of bead dynamics. If I implement, I'll do it right (i.e. measure bead response, create a filter that mimics it)
%V7: Revert to V4, speedup: store differential S, assemble it at the end (instead of assembling the best S every iter.)
%    5380-point long trace computation times: V7=16s; V4=138s [speed is now linear with points, not power law]
%    Waitbar removed, as extreme slowness is no longer an issue
%V8: Finding minimal dS(i,:) is done by matrix ops, no longer by looping, but lose speed for not skipping far values, though
%    Overall ~20% slower, but ends up faster for small inYRes, but slower for large Y range
% b: Bead dynamics: Bead position = average of last N points (response lag)
% c: Speedup by vectorizing

if nargin < 5 || isempty(inDec)
    inDec = 1;
end
if nargin < 3 || isempty(inNoise)
    inNoise = estimateNoise(inContour,125/inDec);
end
if nargin < 2 || isempty(inYRes)
    inYRes = 0.2;
end

%a is our vector of y-values, with which we granularize our search
%Make a fall on "nice" numbers, so float errors do not occur
minC = floor(min(inContour));
maxC = ceil(max(inContour));
a = minC:inYRes:maxC+inYRes;
ap = a'; %necessary for some silly column-vs-row vector shenanigans

len = length(inContour);
hei = length(a);

pen = 9; %Penalty factor, Aggarwal has it as 9 (arguing that 3*sd [=9*var] should mean a significant change)
%Precalculate W(j,:) = penalty vector for moving to the jth point
if nargin < 4 || isempty(p)
    %Default is a flat penalty of pen*inNoise, with 0 along the diagonal (= no penalty for no step)
    W = pen*inNoise*ones(hei);
    W = W - diag(diag(W));
else
    %If we're given a distribution, calculate W by interpolating. Penalty is proportional to -log(p)
    W = -pen/4.5*inNoise*log(bsxfun( @(x, y)(interp1(p(:,1),p(:,2),x-y)), a', a));
    %Interp1 doesn't like interping values outside the given range, so set them to something (large) - this is the value Aggarwal had
    W(isnan(W)) = pen/4.5*50*inNoise;
    %And log(0) = -Inf
    W(isinf(W)) = pen/4.5*50*inNoise;
    %Zero the diagonal (no penalty for no step)
    W = W - diag(diag(W));
end

%J stores the current score. We start at the first point, so it's just the quadratic error
J = (inContour(1) - a).^2;

%Timing
startT = tic;

%Find the optimal path to traverse to any ending y-point by searching one time-point at a time
%dS is where we'll store the optimal path information: if the optimal path is (t,a(p)) to (t+1,a(q)) then dS(t,q) = p
dS = zeros(len-1,hei);
Fs = 50e3;
histlen = ceil(Fs/5e3); %Fc is ~5kHz, so assume linear response in 1/Fc time
for i = 1:len-1
    %Fetch the last few points of each surviving trace
    tmin = max(1,i-histlen+1);
    history = zeros(hei, i-tmin+1);
    %Fetch optimal path to any point on a
    history(:,1) = 1:hei;
    index = 1;
    for k = i-1:-1:tmin
        history(:,index+1) = dS(k, history(:,index));
        index = index + 1;
    end
    %One part of the effective bead position, used to calculate the actual quadratic error
    beadPos = sum(ap(history), 2);
    %Calculate quadratic errors
    Q = (bsxfun(@plus, beadPos, a)/(size(history,2)+1) - inContour(i+1)).^2;
    %Sum costs and take the minimum at each end point
    [J, dS(i,:)] = min( bsxfun(@plus,J',W) + Q,[],1);
end
%Now we have J and dS for the whole trace, just need to pick the victor, assemble the trace
[~, ind] = min(J);

%Store trace indexes (of a) first
Sind = zeros(1,len);
Sind(len) = ind;
for i = len-1:-1:1
    Sind(i) = dS(i,Sind(i+1));
end
outS = a(Sind);

[outInd, outMean] = tra2ind(outS);

fprintf('Hst: Found %d st over %0.2fbp in %0.2fs.\n',length(outMean)-1,outMean(1) - outMean(end),toc(startT));