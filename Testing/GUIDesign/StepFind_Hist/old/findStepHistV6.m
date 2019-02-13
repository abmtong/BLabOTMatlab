function outS = findStepHistV6(inContour, inYRes, inNoise, p)
%Follows Aggarwal's method for iterative step detection
%V2: Made ~10x quicker (but more memory-intensive) by interpolating first, out of the loop
%V3: Increasing performance for wide-Y values by skipping some large step calculations (dBP > 30)
%V4: Handles p maybe slightly better?
%V5: Kinda takes into account bead response, req data filtered to 100Hz, and assumes response lag is linear, 0.02s
%V6: Actually implemented ^ correctly, instead of borking it (just did equivalent to W*=4). Removed V3, at a cost of 3x slower - will probably reimplement

if nargin < 3 || isempty(inNoise)
    inNoise = estimateNoise(inContour,25);
end
if nargin < 2
    inYRes = 0.1;
end

%a is our vector of y-values, with which we granularize our search
%Make a fall on "nice" numbers, so float errors do not occur
minC = floor(min(inContour));
maxC = ceil(max(inContour));
a = minC:inYRes:maxC;

len = length(inContour);
hei = length(a);

if nargin < 4 || isempty(p)
    %Start with p = exp(-1), or W=9*noise
    ran = maxC - minC;
    x = -ran:inYRes:ran;
    y = exp(-4.5)*ones(1,length(x));
    p = [x', y'];
end

%Or seed with, say, a gaussian around 10bp

%Precalculate W(j,:) = penalty vector for jth iter. (zero at jth position)
W = zeros(hei);
for j = 1:hei
%Code had -2* here, but I think we need it stronger.
    W(j,:) = -2*inNoise*log( interp1(p(:,1),p(:,2),a(j)-a) );
    W(j,j) = 0;
end
W(isnan(W)) = 100*inNoise;

%S is a j x i matrix; S(j,:) is the best path to get to a(j)
S = a';

%J stores the current score at each point.
J = (inContour(1) - a).^2;

%Some timing stuff - speed isnt constant, since there's two parts: computation (constant) and memory allocation (linear with i)
wb = waitbar(0,'Finding steps...','Name','Finding steps...');
startT = tic;
dt = 10;
%Find the optimal path to traverse to any ending pt. by going one point at a time
for i = 1:len-1
    %Some timing stuff
    if rem(i, dt) == 0
        pct = (i/len);
        %2* is purely emprical
        t = 2* toc(startT) * ((1/pct) - 1);
        if t > 60
            tm = floor(t / 60);
            ts = floor(rem(t,60));
            tmsg = [num2str(tm) 'm' num2str(ts) 's'];
        else
            ts = floor(t);
            tmsg = [num2str(ts) 's'];
        end
        waitbar(pct,wb,['Finding steps, ETA: ' tmsg])
    end
    
    %Create new containers for J, S
    Jnew = Inf(1,hei);
    Snew = zeros(hei,i+1);
    %Calculate cost of going from any point to a(j) at time i+1
    for j = 1:hei
        %Treat the first point of a jump as only half as much away, to account for bead movement
        dx = abs(inContour(i+1) - a(j)/2 - a/2);
        %Calculate new (differential) quadratic error for each trajectory
        g = (dx).^2 + W(j,:);
        %And add it to the rest, find the minimum
        Jtemp = J+g;
        [val, ind] = min(Jtemp);
        %Collect our victor: write its new score J and new path S
        Jnew(j) = val;
        Snew(j,:) = [S(ind,:) a(j)];
    end
    %Save them for the next iteration
    J = Jnew;
    S = Snew;
end
delete(wb);
%Now we have J and S for the whole trace, just need to pick the victor
[~, ind] = min(J);
outS = S(ind,:);
toc(startT);
   