function [outInd, outMean, outTra, fitRatio, allInds] = fsChSq(inContour, maxSteps, verbose )
%Finds steps in a trace using the Chi Square method (Kerssemakers et al)
%Place steps sequentially to reduce quadratic error
%End when the score compared to a counter-fit reaches a maximum
%Counter-fit is where steps are placed in the plateaus of the normal fit
%(V2): xfit uses center of plateaus, instead of being fit. Worse fitting, reveretd
%   b: Tidying up

%Uses C code for speed:
%C_qe = @(x) sum( (x-mean(x)).^2 );

if nargin < 3
    verbose = 0;
end

len = length(inContour);
%C_qe requires double
if ~isa(inContour, 'double')
    inContour = double(inContour);
end

%Find maxSteps steps - algorithm is very quick after the first few steps (scales as log(nmaxSteps), so finding a whole lot here isn't too taxing
if nargin < 2 || isempty(maxSteps)
    maxSteps = min(len-2,500);
end

%Store our steps here, in the order they were found. Tack on [... 1, len] so when sorted, gives a stepping index
allInds = [zeros(1,maxSteps) 1 len];
fitRatio = zeros(1,maxSteps);
%Store already calculated scores and indices here in form [startInd endInd mindQE minInd]
histChiSq = zeros(maxSteps,4);
%Store already calculated counterfit indices here in form [startInd endInd optInd]
histXfit = zeros(2*maxSteps, 3);

%Create a function that finds the best step to place within [ind1, ind2]. Use nested fcn to access inContour for free.
    function [outInd, outdQE] = findStep(ind1, ind2)
        outdQE = inf;
        outInd = [];
        hei = ind2-ind1;
        oldQE = C_qe(inContour(ind1:ind2-1));
        for ii = 2:hei
            testdQE = C_qe(inContour(ind1    :ind1+ii-2 )) ...
                     +C_qe(inContour(ind1+ii-1 :ind2-1 )) ...
                     -oldQE;
            if outdQE > testdQE
                outdQE = testdQE;
                outInd = ii + ind1-1;
            end
        end
        if isempty(outInd)
            outInd = ind1+1;
        end
    end

startT = tic;
%For each step to find, loop over all segments, and calculate the best difference in Quadratic Error by placing a step at any point
for i = 1:maxSteps
    %Extract our current trace by removing 0s and sorting
    in = sort(allInds(allInds>0));
    for j = 1:i
        %If we've already done this section (i.e. have its results stored in histChiSq from a previous iter.), skip
        ind = find(histChiSq(:,1) == in(j) & histChiSq(:,2) == in(j+1), 1);
        if ind
            continue
        end
        %Find the best score, point
        [minInd, mindQE] = findStep(in(j), in(j+1));
        %If the segment is too small, minInd is never set. Assign minInd to avoid array size errors.
        if isempty(minInd)
            minInd = -1;
            %mindQE will still be inf, so this step will never be picked
        end
        %Place our value in the first open slot of the array
        ind = find(histChiSq(:,1)==0,1);
        histChiSq(ind,:) = [in(j) in(j+1) mindQE minInd];
    end
    %Find the best change in score, choose it as our step. Erase the chosen data, so it's no longer selected from
    [~, ind] = min(histChiSq(:,3));
    allInds(i) = histChiSq(ind, 4);
    histChiSq(ind,:) = [0 0 0 0];
    
    %To tell when to stop, create a counterfit where a step is fit to each found plateau
    %fitRatio = QE(xfit) / QE(fit) should peak at proper numSteps
    %Code is similar to the above
    in = sort(allInds(allInds>0));
    %Vectors to store counter-fit index, xfit score, and real score
    xin = [zeros(1,i+1) 1 len];
    xQE = 0;
    rQE = 0;
    %Loop over segments
    for j = 1:i+1
        %Calculate real score of this segment
        rQE = rQE + C_qe(inContour(in(j):in(j+1)-1 ));
        %If we've already calculated the step for this, fetch it from history data
        ind = find(histXfit(:,1) == in(j) & histXfit(:,2) == in(j+1), 1);
        if ind
            xin(j) = histXfit(ind,3);
            continue
        end
        %Otherwise, calculate it
        xin(j) = findStep(in(j), in(j+1));
        %And place it in our array
        ind = find(histXfit(:,1)==0,1);
        histXfit(ind,:) = [in(j) in(j+1) xin(j)];        
    end
    %Assemble our xfit step index and calculate the score
    xin = sort(xin);
    for j = 1:i+2
        xQE = xQE + C_qe(inContour(xin(j):xin(j+1)-1));
    end
    fitRatio(i) = xQE/rQE;
end
endT = toc(startT);

if verbose == 1
    figure('Name','ChiSq Fit Ratio')
    plot(fitRatio)
    ylim([1, inf]);
elseif verbose == 2%zero out values outside ginput lines
    figure('Name','ChiSq Fit Ratio')
    plot(fitRatio)
    ylim([1, 10]);
    drawnow
    [x, ~] = ginput(2);
    x = sort(round(x));
    fitRatio((1:end)<x(1)) = 0;
    fitRatio((1:end)>x(2)) = 0;
end

%The true number of steps has the highest fitRatio
[~, ind] = max(fitRatio);
%Assemble stepping index
outInd = [1 sort(allInds(1:ind)) len];
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
end

fprintf('Chi: Found %dst over %0.2fbp in %0.2fs. %s\n', length(outMean)-1, outMean(1)-outMean(end), endT, msg);
end