function outData = evaluateStepFinding(stepFcn, fcnOpts, filOpts)
%Tests a function's performance, like they do in these papers
%Tests against trace from @genTestTrace using prop.s 
%-Filtering ({@mean, 1} is standard)
%-If the algorithm has a variable, that also needs to be tuned
%
%Or just test against real data? cf. eye?
%-Have a few representative traces (nice-looking vs trash), stepfit, and by eye decide num missed, num extra (lotsa work)

%define correct = within 5 points
%also do raw numbers (Nstep / Nreal, Ncorrect/Nreal)

%Testing params
numTrials = 100;
SNR = 10;
numSteps = 30;

nStep = zeros(1,numTrials);
nReal = zeros(1,numTrials);
nCorr = zeros(1,numTrials);
szStep = cell(1,numTrials);
for i = 1:numTrials
    [trNoi, ~, trInd] = genTestTrace(SNR, numSteps);

    %Real number of steps: sometimes edge steps cant be detected - then this isn't = numSteps
    if strcmp(func2str(stepFcn),'findStep_MSF')
        nReal(i) = sum(trInd > fcnOpts{1} & trInd < length(trNoi) - fcnOpts{1} + 1);
    else
        nReal(i) = numSteps;
    end
    
    trNoi = windowFilter(filOpts{1}, trNoi, filOpts{2:end});
    if length(filOpts) == 3;
        trInd = round(trInd / filOpts{3});
    end
    fprintf('%d ',i);
    [stInd, stMea, ~] = stepFcn(trNoi,fcnOpts{:});
    
    %Remove first (1) and last (length) step index
    stInd = stInd(2:end-1);
    trInd = trInd(2:end-1);
    
    %Determine whether the found steps are real or not
    count = 0;
    for j = 1:length(stInd)
        %If the step is within 5 of a real one, increment count and 'remove' it
        in = find(abs(stInd(j) - trInd) <= 5, 1);
        if in
            count = count + 1;
            trInd(in) = -1000; %wont show up in find() anymore - no double counting steps
        end
    end
    nStep(i) = length(stInd);

    nCorr(i) = count;
    szStep{i} = -diff(stMea);
end

%Gather data into struct
outData.szStep = szStep;
outData.nStep = nStep;
outData.nReal = nReal;
outData.nCorr = nCorr;
outData.pctFound = mean(nStep ./ nReal);
outData.pctCorrect = mean(nCorr ./ nReal);
outData.filOpts = filOpts;
outData.fcnOpts = fcnOpts;
outData.stepFcn = stepFcn;

%Print stats, plot histogram
fprintf('Found %0.2f%% of steps, %0.2f%% of which were real\n', outData.pctFound*100, outData.pctCorrect*100);
figure
hist(collapseCell(szStep),40)