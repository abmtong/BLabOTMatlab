function [outInd, outMean, outTra] = AFindStepsV4b(inContour, inPenalty, maxSteps )
%Applies the Klafut-Visscher stepfinding algorithm to input trace inContour.
%V4: Modifying @findStepsChSq code to do K-V, as earlier versions are inefficient
% b: Editable criterion @KVcrierion, 

%Calculate Quadratic Error, sum((mean(A)-A).^2), quickly with C code
%C_qe requires double; data is saved as single
if ~isa(inContour, 'double')
    inContour = double(inContour);
end
len = length(inContour);

%Defaults
%Could write maxSteps out of the code, but it's very convenient to have an upper limit
if nargin < 3 || isempty(maxSteps)
    maxSteps = 500;
end

if nargin < 2 || isempty(inPenalty)
    inPenalty = 1 * log(len);
end
%If inPenalty is passed as a single, treat as a multiple of the default
if isa(inPenalty, 'single')
    inPenalty = inPenalty * log(len);
end

%Store our steps here
inds = [zeros(1,maxSteps) 1 len];
%Store already calculated QEs here in form [startInd endInd optCS optInd;]
histData = zeros(maxSteps,4); %Need a slot for every segment
msg = ', max steps found (consider increasing maxSteps)'; %Warning message if max steps found (i.e. for loop exited not by break)
startT = tic;

%For each step we're trying to add...
for i = 1:maxSteps
    %Extract the nonzero indices
    in = sort(inds(inds>0));
    %...loop over all segments...
    segQE = zeros(1, i);
    for j = 1:i
        %...and calculate the difference in QE gained by adding a step at any pt
        %Look if we've already done this section, if so: skip
        ind = find(histData(:,1) == in(j) & histData(:,2) == in(j+1));
        if ind
            continue
        end
        %Store this segment's current best dQE, index of that step
        mindQE = inf;
        minInd = [];
        %Length of this segment (includes in(j), but not in(j+1))
        hei = in(j+1)-in(j);
        %ChSq of this segment, untouched
        segQE(j) = C_qe(inContour(in(j):in(j+1)-1));
        %else calculate the best step to put here. There's already a step at k=1, so skip it
        for k = 2:hei-1
            %Calculate the change in QE
            testdQE = C_qe(inContour(in(j)   :in(j)+k-1 )) ...
                     +C_qe(inContour(in(j)+k :in(j+1)-1 )) ...
                     -segQE(j);
            if mindQE > testdQE
                mindQE = testdQE;
                minInd = k + in(j)-1;
            end
        end
        if isempty(minInd) %hei = 1: Adjacent points
            minInd = -1; %Used to be in(j)+1, shouldn't be selected (mindQE=inf), cant be empty since it is inserted into an array
        end
        %Store our result in histData
        ind = find(histData(:,1)==0,1);
        histData(ind,:) = [in(j) in(j+1) mindQE minInd];
    end
    %Find the best step to add by searching histData
    [dQE, ind] = min(histData(:,3));
    
    %Check SIC criterion
    if ~KVcriterion(sum(segQE),dQE, inPenalty)
        msg = '';
        break
    end
    
    %Step passed, add it to inds, 
    inds(i) = histData(ind, 4);
    histData(ind,:) = [0 0 0 0];
end

%Assemble stepping index
outInd = sort(inds(inds>0));

%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end

if nargout >= 3
    outTra = ind2tra(outInd, outMean);
end

fprintf('K-V: Found %dst over %0.2fbp in %0.2fs, Penalty=%0.2f%s\n', length(outMean)-1, outMean(1)-outMean(end), toc(startT), inPenalty, msg);