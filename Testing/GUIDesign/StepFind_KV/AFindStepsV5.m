function [outInd, outMean, outTra] = AFindStepsV5(inContour, inPenalty, maxSteps, verbose )
%Applies the Klafut-Visscher stepfinding algorithm to input trace inContour.
%V4: Modifying @findStepsChSq code to do K-V, as earlier versions are inefficient
%V5: Search is now completely in C, speedup of ~40%

%Later functions require double
if ~isa(inContour, 'double')
    inContour = double(inContour);
end
len = length(inContour);

%Defaults
if nargin<4 || isempty(verbose)
    verbose = 1;
end

%Could write maxSteps out of the code, but it's convenient to have an upper limit, for preallocation & endpoint if overfitting
if nargin < 3 || isempty(maxSteps)
    maxSteps = round(min(500, len/2));
end

%Step Penalty
if nargin < 2 || isempty(inPenalty)
    inPenalty = log(len);
elseif isa(inPenalty, 'single') %If inPenalty is passed as a single, treat as a multiple of the default
    if isscalar(inPenalty)
        inPenalty = inPenalty * log(len);
    else %[Decimation Factor, Penalty Factor]
        inPenalty = inPenalty(2) * estimateNoise(inContour, 125/inPenalty(1));
    end
end

% K-V's SIC = (k+2)*p + log(n) + n*log(QE/n)
% We only need to compare the SIC of a trace with i and i+1 steps,
%     so we can simplify the criterion to n*log(QE(i+1)/n)+p< n*log(QE(i)/n)
% Since QE>0, n>0, this further simplifies to QE(i+1)/QE(i) < exp(-p/n)
% Finally, QE(i+1)=QE(i)+dQE, so: dQE/QE(i)<exp(-p/n)-1=P (dQE is negative)
P = exp(-inPenalty/len)-1; %At default, since inPenalty = log(len), P = len^(1/len) - 1

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
        %QE of this segment, untouched
        segQE(j) = C_qe(inContour(in(j):in(j+1)-1));        
        %...and calculate the difference in QE gained by adding a step at any pt
        %Look if we've already done this section, if so: skip
        ind = find(histData(:,1) == in(j) & histData(:,2) == in(j+1));
        if ind
            continue
        end
        ind = find(histData(:,1)==0,1);
        %Result from C_qe_window is [mindQE minInd], but need to convert minInd to Matlab indicies
        a = C_qe_window(inContour(in(j):in(j+1)));
        a(2) = a(2) + in(j);
        histData(ind,:) = [in(j) in(j+1) a];
        %{
        C_qe_window is equivalent to this code below (from V4)
        %Store this segment's current best dQE, index of that step
        mindQE = inf;
        minInd = [];
        %Length of this segment (includes in(j), but not in(j+1))
        hei = in(j+1)-in(j);

        %else calculate the best step to put here. There's already a step at k=1, so skip it
        for k = 2:hei
            %Calculate the change in QE
            testdQE = C_qe(inContour(in(j)     :in(j)+k-2 )) ...
                     +C_qe(inContour(in(j)+k-1 :in(j+1)-1 )) ...
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
%}
    end
    %Find the best step to add by searching histData
    [dQE, ind] = min(histData(:,3));
    
    %Check SIC criterion
    if dQE/sum(segQE) >= P
        msg = '';
        break
    end
  
    %Step passed, add it to inds, remove it from histData
    inds(i) = histData(ind, 4);
    histData(ind,:) = [0 0 0 0];
end

%Assemble stepping index
outInd = sort(inds(inds>0));

%Calculate means - the step heights
outMean = ind2mea(outInd, inContour);

%Convert indicies to trace
if nargout >= 3
    outTra = ind2tra(outInd, outMean);
end

if verbose == 1
    fprintf('K-V: Found %dst over %0.2fbp in %0.2fs, Penalty=%0.2f%s\n', length(outMean)-1, outMean(1)-outMean(end), toc(startT), inPenalty, msg);
elseif verbose == 2
    fprintf('|')
elseif verbose == 3
    fprintf('\b|\n')
end