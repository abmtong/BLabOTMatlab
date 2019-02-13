function [outInd, outMean, outTra, S] = findStepsChiSqV2(inContour, maxSteps )

%V2: xfit is middle of plateaus, instead of fit
%seems like minimal difference between C_chsq and C_qe (use C_qe since it makes more sense)
%seems like it likes minimal filtering (single outliers seem to wreck the detection sometimes because(?) xfit misbehaves
%seems worse than ChiSqV1

%Highly dependent on noise, maybe have a way to account for that?
%Search over findpeaks' answer?

%Using C code to calculate quadratic errors
%C_chsq = @(x) sum( (x-mean(x)).^2 /mean(x) );
%C_qe   = @(x) sum( (x-mean(x)).^2 );


%Steps should be about 10bp, so go until avg 1bp steps
%Going to far leads to adjacent steps, which throws an error (could just fix this error, though)
if nargin < 2 || isempty(maxSteps)
    maxSteps = round((inContour(1)-inContour(end)));
end

%C_qe requires double
inContour = double(inContour);
len = length(inContour);

%Store our steps here
inds = [zeros(1,maxSteps) 1 len];
S = zeros(1,maxSteps);
%Store already calculated ChSq's here in form [startInd endInd optCS optInd;]
histChiSq = zeros(maxSteps+1,4); %maxSteps+1: Need a slot for every segment
%Make a function that'll lookup the row of a given [startInd endInd]
findcell = @(mat, st, en)(find(mat(:,1) == st & mat(:,2) == en));
startT = tic;

%For each step ...
for i = 1:maxSteps
    %Extract the nonzero indices
    in = sort(inds(inds>0));
    %...loop over all segments...
    for j = 1:i
        %if we've already done this section, skip
        ind = findcell(histChiSq, in(j),in(j+1));
        if ind
            continue
        end
        minCS = inf;
        minInd = [];
        %Length of this segment
        hei = in(j+1)-in(j)+1;
        %ChSq of this segment, untouched
        csseg = C_qe(inContour(in(j):in(j+1)-1));
        %...and calculate the difference in ChSq gained by adding a step at any pt
        for k = 2:hei-1 %ignore placing a step at the very edges
            cs = C_qe(inContour(in(j)   :in(j)+k-1 )) ...
                +C_qe(inContour(in(j)+k :in(j+1)-1 )) ...
                - csseg;
            if minCS > cs
                minCS = cs;
                minInd = k + in(j)-1;
            end
        end
        if isempty(minInd)
            minInd = in(j)+1;
            %minCS will still be inf if this is reached
        end
        ind = find(histChiSq(:,1)==0,1,'first');
        histChiSq(ind,:) = [in(j) in(j+1) minCS minInd];
    end
    [~, ind] = min(histChiSq(:,3));
    inds(i) = histChiSq(ind, 4);
    histChiSq(ind,:) = [0 0 0 0];
    
    %Counterfit: fit a step to middle of each plateau
    %calc. S = ChiSq(fit) / ChiSq(xfit), should peak at proper numSteps
    %can speed up with a lookup table like the proper fit, will implement eventually
    in = sort(inds(inds>0));
%    xin = zeros(1,i+1);
    xcs = zeros(1,i+2);
    rcs = zeros(1,i+1);
    for j = 1:i+1
        rcs(j) = C_qe(inContour(in(j)   :in(j+1)-1 ));
    end
    xin = [1 round(([1 in] + [in len])/2) len];
    for j = 1:i+2
        xcs(j) = C_qe(inContour(xin(j)   :xin(j+1)-1 ));
    end
    S(i) = sum(xcs) / sum(rcs);
end

plot(S)

%Cherrypick maximum
% a = ginput(2);
% a = sort(a(:,1));
% keepind = floor(a(1)):ceil(a(2));
% %Max S > Victor
% [~, ind] = max(S(keepind));
% ind = ind -1 + floor(a(1));

[~, ind] = max(S);

%Warning message
msg = '';
if ind >= 0.9*maxSteps
    msg = 'Warning: max or near-max steps detected.';
end

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

fprintf('Chi: Found %dst over %0.2fbp in %0.2fs. %s\n', length(outMean)-1, outMean(1)-outMean(end), toc(startT), msg);