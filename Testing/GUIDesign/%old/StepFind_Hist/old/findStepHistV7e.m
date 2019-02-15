function [outInd, outMean, outS] = findStepHistV7e(inContour, inYRes, inNoise, p, inDec)
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
% e: "bead dynamics"
if nargin < 5
    inDec = 1;
end
%nargin < 4 is below
if nargin < 3 || isempty(inNoise)
    inNoise = estimateNoise(inContour,125/inDec);
end
if nargin < 2 || isempty(inYRes)
    inYRes = 0.2;
end

%a is our vector of y-values, with which we coarse-grain our search
%Make a fall on "nice" numbers, minimizes float errors(?)
minC = floor(min(inContour));
maxC = ceil(max(inContour));
a = minC:inYRes:maxC+inYRes;

len = length(inContour);
hei = length(a);

pen = 9; %Penalty factor, Aggarwal has it as 9 (arguing that 3*sd [=9*var] should mean a significant change)
%Precalculate W(j,:) = penalty vector for moving to the jth point
if nargin < 4 || isempty(p)
    %Default is a flat penalty of pen*inNoise, with 0 along the diagonal (= no penalty for no step)
    W = pen*inNoise*ones(hei);
    W = W - diag(diag(W)); %Zeroes the diagonal
else
    %If we're given a distribution, calculate W by interpolating. Penalty is proportional to -log(p)
    W = zeros(hei);
    for j = 1:hei
        W(j,:) = -pen/4.5*inNoise*log( interp1(p(:,1),p(:,2),a(j)-a) ); %Packaging is a positive step size, by this def'n
        W(j,j) = 0;
    end
    %Interp1 doesn't like interping values outside the given range, so set them to something (large) - this is the value Aggarwal had
    W(isnan(W)) = pen/4.5*50*inNoise;
    %And log(0) = -Inf
    W(isinf(W)) = pen/4.5*50*inNoise;
end

%J stores the current score. We start at the first point, so it's just the quadratic error
J = (inContour(1) - a).^2;

%Timing
startT = tic;

%Find the optimal path to traverse to any ending y-point by searching one time-point at a time
%dS is where we'll store the optimal path information: if the optimal path is (t,a(p)) to (t+1,a(q)) then dS(t,q) = p
dS = zeros(len-1,hei);
%Speed: Only consider points within a neighborhood
neigh = max(30, 1.1*max(abs(diff(inContour)))); %consider max(upper envelope - lower envelope) - ends up about the same
histlen = ceil(80/inDec); %80 is a fudged value - seems to fit well through different decimation values
for i = 1:len-1
    %Bdy values
    ymin = max(1  , find(a > inContour(i+1)-neigh, 1, 'first') );
    ymax = min(hei, find(a < inContour(i+1)+neigh, 1, 'last' ) );
    yRange = ymin:ymax;
    
    %New additions
    %beadPos is the last histlen-1 points of each surviving trace.
    %Add the candidate point and divide by histlen to get the "bead position" to use when calculating Quad. Error
    beadPos = zeros(1,length(yRange));
    for j = 1:length(yRange)
        hlen = min(i+1,histlen);
        hist = zeros(1,hlen-1);
        hist(end) = yRange(j);
        for k = hlen-2:-1:1
            hist(k) = dS(i- (hlen-1-k),hist(k+1));
            if hist(k) == 0
                break;
            end
        end
        if hist > 0
            beadPos(j) = sum(a(hist));
        else
            beadPos(j) = Inf;
        end
    end
    
    %Q = ((hlen-1 positions up to time i) + (new position at time i+1)) / hlen
    Q = bsxfun(@plus, beadPos', a(yRange))/hlen;
    %Q = (BeadPosition - TracePosition).^2
    Q = bsxfun(@minus, Q, inContour(yRange)).^2;
    
    %Minimization matrix(i,j) = stored cost J(i) + step cost W(i,j) + QError Q(i,j); minimize along columns
    [dJ, ddS] = min( bsxfun(@plus,J(yRange)',W(yRange,yRange)) + Q,[],1);
    dS(i,yRange) = ddS+ymin-1;
    J = Inf(1,hei);
    J(yRange) = dJ;
end

%Now we have J and dS for the whole trace, just need to pick the victor, assemble the trace
[~, ind] = min(J);

%Translate dS into the trace, outS
Sind = zeros(1,len);
Sind(len) = ind;
for i = len-1:-1:1
    Sind(i) = dS(i,Sind(i+1));
end
outS = a(Sind);

[outInd, outMean] = tra2ind(outS);

fprintf([ 'Hst: Found ' num2str(length(outMean)-1) 'st over ' num2str(outMean(1) - outMean(end))  'bp in ' num2str(roundn(toc(startT),-2)) 's. Penalty = 9*' num2str(inNoise) '\n']);