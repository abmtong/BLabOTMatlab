function [outInd, outMean, outTra, fitRatio] = findStepsChiSqV1(inContour, maxSteps, verbose )
%Finds steps in a trace using the Chi Square method (Kerssemakers et al)
%Place steps sequentially to reduce quadratic error
%End when the score compared to a counter-fit reaches a maximum
%Counter-fit is where steps are placed in the plateaus of the normal fit
%(V2): xfit uses center of plateaus, instead of being fit. Worse performance.

%Uses C code for speed:
%C_qe = @(x) sum( (x-mean(x)).^2 );

if nargin < 3
    verbose = 0;
end

%Find maxSteps steps - algorithm is very quick after the first few steps (scales as log(nmaxSteps), so finding a whole lot here isn't too taxing
if nargin < 2 || isempty(maxSteps)
    maxSteps = 500;
end

len = length(inContour);
%C_qe requires double
if ~isa(inContour, 'double')
    inContour = double(inContour);
end

%Store our steps here, in the order they were found. Tack on [... 1, len] so when sorted, gives a stepping index
inds = [zeros(1,maxSteps) 1 len];
fitRatio = zeros(1,maxSteps);
%Store already calculated scores and indices here in form [startInd endInd optCS optInd]
histChiSq = zeros(maxSteps,4);
%Store already calculated counterfit indices here in form [startInd endInd optInd]
histXfit = zeros(2*maxSteps, 3);
%Make a function that'll lookup the row of a given [startInd endInd] (or return [] if not found)
fndRow = @(mat, st, en)(find(mat(:,1) == st & mat(:,2) == en));
startT = tic;

%For each step to find...
for i = 1:maxSteps
    %Extract our current trace (remove 0s and sort)
    in = sort(inds(inds>0));
    %...loop over all segments...
    for j = 1:i
        %If we've already done this section (have its results stored in histChiSq from a previous iter.), skip
        ind = fndRow(histChiSq, in(j),in(j+1));
        if ind
            continue
        end
        %Store best score and point here
        minCS = inf;
        minInd = [];
        %Length of this segment
        hei = in(j+1)-in(j)+1;
        %ChSq of this whole segment
        csseg = C_qe(inContour(in(j):in(j+1)-1));
        %...and calculate the best difference in ChSq gained by placing a step at any point
        for k = 2:hei-1 %A step at the edge is no step - just skip (wouldn't get picked, anyway)
            %cs is the net change in ChiSq: (new - old)
            cs = C_qe(inContour(in(j)   :in(j)+k-1 )) ...
                +C_qe(inContour(in(j)+k :in(j+1)-1 )) ...
                - csseg;
            %If this is better than any we've had, update it as the best
            if minCS > cs
                minCS = cs;
                minInd = k + in(j)-1;
            end
        end
        %If the segment is too small, minInd is never set. Assign minInd to avoid errors
        if isempty(minInd)
            minInd = in(j)+1;
            %minCS will still be inf, so this step will never be picked
        end
        %Place our value in the first open slot of the array
        ind = find(histChiSq(:,1)==0,1,'first');
        histChiSq(ind,:) = [in(j) in(j+1) minCS minInd];
    end
    %Find the best change in score, choose it as our step. Erase the chosen data, so it's no longer selected from
    [~, ind] = min(histChiSq(:,3));
    inds(i) = histChiSq(ind, 4);
    histChiSq(ind,:) = [0 0 0 0];
    
    %To tell when to stop, create a counterfit where a step is fit to each found plateau
    %S = ChiSq(xfit) / ChiSq(fit) should peak at proper numSteps
    %Code is similar to the above
    in = sort(inds(inds>0));
    %Vectors to store counter-fit index, xfit score, and real score
    xin = zeros(1,i+1);
    xcs = 0;
    rcs = 0;
    %Loop over segments
    for j = 1:i+1
        %Calculate real score of this segment
        rcs = rcs + C_qe(inContour(in(j):in(j+1)-1 ));
        %If we've already calculated the step for this, take it
        ind = fndRow(histXfit, in(j),in(j+1));
        if ind
            xin(j) = histXfit(ind,3);
            continue
        end
        %Otherwise, calculate it in a similar way as above
        minCS = inf;
        minInd = [];
        hei = in(j+1)-in(j)+1;
        for k = 2:hei-1
            cs = C_qe(inContour(in(j)   :in(j)+k-1 )) ...
                +C_qe(inContour(in(j)+k :in(j+1)-1 ));
            if minCS > cs
                minCS = cs;
                minInd = k + in(j)-1;
            end
        end
        if isempty(minInd)
            minInd = in(j)+1;
        end
        xin(j) = minInd;
        ind = find(histXfit(:,1)==0,1,'first');
        histXfit(ind,:) = [in(j) in(j+1) xin(j)];

    end
    %Assemble our xfit step index and calculate the score
    xin = [1 xin len];  %#ok<AGROW>
    for j = 1:i+2
        xcs = xcs + C_qe(inContour(xin(j):xin(j+1)-1));
    end
    fitRatio(i) = xcs/rcs;
end

if verbose
    plot(fitRatio)
end

%The true number of steps has the highest fitRatio
[~, ind] = max(fitRatio);
%Assemble stepping index
outInd = [1 sort(inds(1:ind)) len];
%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end

if nargout >= 3
    outTra = ind2tra(outInd, outMean);
end

%Warning message
msg = '';
if ind >= 0.9*maxSteps
    msg = 'Warning: max or near-max steps detected.';
    %Maybe invalidate results, too?
end

fprintf('Chi: Found %dst over %0.2fbp in %0.2fs. %s\n', length(outMean)-1, outMean(1)-outMean(end), toc(startT), msg);