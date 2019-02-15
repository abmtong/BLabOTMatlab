function outS = findStepHistV1(inContour, inYRes, inNoise, p)
%Follows Aggarwal's method for iterative step detection
if nargin < 3 || isempty(inNoise)
    inNoise = estimateNoise(inContour);
end
if nargin < 2
    inYRes = 0.1;
end

len = length(inContour);

%a is our vector of y-values, with which we granularize our search
a = min(inContour):inYRes:max(inContour);

if nargin < 4
    %Start with p = exp(-4.5), or W=9*noise
    p = [-100000, exp(-4.5); 100000, exp(-4.5)];
    %As iterates, pass the previous hist as p
end
%Or seed with, say, a gaussian around 10bp

%S is a j x i matrix; S(j,:) is the best path to get to a(j), with each row being the path to a(k).
S = a';

%J stores the current score at each point.
J = (inContour(1) - a).^2;

%Some timing stuff
wb = waitbar(1/len,'Finding steps...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
startT = tic;

%Find the optimal path to traverse to any ending pt. by going one point at a time
for i = 1:len-1
    
    %Some timing stuff
    if rem(i, 2) == 0
        t = toc(startT) * (len/i - 1);
        if t > 60
            tm = floor(t / 60);
            ts = round(rem(t,60));
            tmsg = [num2str(tm) 'm' num2str(ts) 's'];
        else
            ts = round(t);
            tmsg = [num2str(ts) 's'];
        end
        waitbar(i/len,wb,['Finding steps, ETA: ' tmsg])
    end
    %Create new 
    Jnew = zeros(1,length(a));
    Snew = zeros(length(a),i+1);
    for j = 1:length(a) %calculate cost of going from any point at time i to a(j) at time i+1
        
        %If cancel, end.
        if getappdata(wb,'canceling')
            delete(wb);
            return
        end
        u = a(j) - a; %relative step sizes, to calculate penalty W
        
        %Penalty = -2*noise*log( probability  ) unless no step, u = 0 at j
        W = -2*inNoise*log( interp1(p(:,1),p(:,2),u) );
        W(j) = 0;
        
        %Calculate new additional quadratic error for each trajectory
        g = (inContour(i+1) - a(j)).^2 + W;
        %And add it to the rolling sum, find its minimum
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
%Now we have J and S full, just need to pick the victor
[~, ind] = min(J);
outS = S(ind,:);
   