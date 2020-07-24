function outInd = wiggleSteps(inContour, inInds, ptWidth, stWidth)
%'Wiggles' the steps of a stepfcn by wiggling stWidth steps each by up to ptWidth points.
%Computation time goes as (2*ptW+1)^(2*stW+1) * (length(inInds)-2*stWidth+1)

%%SHELVE FOR NOW too complex; or just get newer MATLAB which has integer constraints

narginchk(2, inf)
inContour = double(inContour);
len = length(inContour);

Guess = inInds(2:end-1);
indmax = length(Guess);

if nargin < 3
    ptWidth  = ceil(length(inContour) / indmax / 2);
end

%Create lb, ub
lb = zeros(1, indmax);
ub = zeros(1, indmax);
for i = 1:indmax
    lb(i) = max(Guess(i)-ptWidth, inInds(i)); %inInds(i) = Guess(i-1)
    ub(i) = min(Guess(i)+ptWidth, inInds(i+2)); %inInds(i+2) = Guess(i+1)
end
inds = [1 Guess len];
lb = [1 lb len];
ub = [1 ub len];

qe = @(con, ind) C_qe(con - ind3tra([ind], con));
%No suitable integer constraint problem solver, so do this windowed approach

%For every window of steps
for i = 1:indmax-2*stWidth
    %inContour indicies to work with
    snipcon = inContour(inds(i):inds(i+2*stWidth));
    %Store best QE, new indexes
    bestQE = inf;
    bestind = inds(i:i+2*sWidth);
    %Wiggle every point
    for j = 1:2*stWidth+1
        testind = bestind;
        %Up to ptWidth
        for k = lb(j):ub(j)
            %Calc new QE, compare
            newind = testind;
            newind(j) = k;
            newQE = qe(snipcon, testind);
            if newQE < bestQE
                bestQE = newQE;
                bestind = newind;
            end
        end
    end
    
    
end
end