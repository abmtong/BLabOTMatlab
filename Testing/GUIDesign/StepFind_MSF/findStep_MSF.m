function [outInd, outMean, outTr, outMSF] = findStep_MSF( inContour, inWidth, verbose )
%Finds steps via the Moving Step Fit algorithm (Opfer 2012, doi:10.1371/journal.pone.0045896)
%Method is a hybrid with 

%Convert to double
if ~isa(inContour,'double')
    inContour = double(inContour);
end

if nargin < 3
    verbose = 0;
end

if nargin < 2 || isempty(inWidth)
    inWidth = 150;
end

startT = tic;
len = length(inContour);
outMSF = zeros(1,len);
for i = inWidth+1:len-inWidth+1
    x = i-inWidth:i+inWidth-1;
    y = inContour(x);
    [pwFit, linFit] = fitLines(y);
    outMSF(i) = calcRSS(1:2*inWidth,y,pwFit,linFit);
end



%Now choose the steps: Like ChiSq method - fit vs xfit
[pk, in] = findpeaks(outMSF,'SortStr','descend','MinPeakWidth',10);%,'MinPeakProminence',20);
%Can modify to allow reverse stepping (=findpeaks(-out))

%Store fit vs. xfit values
S = zeros(1,length(in));
for i = 1:length(in)
    S(i) = testXFit(inContour, [1 sort(in(1:i)) len]);
end

%Graphs
if verbose
    figure('Name','MSF Stats')
    subplot(3,1,[1 2])
    plot(outMSF)
    text(in,pk+100,num2str((1:numel(pk))'));
    subplot(3,1,3)
    plot(S);
end

[~,maxind] = max(S);

outInd = [1 sort(in(1:maxind)) len];
outMean = ind2mea(outInd, inContour);
outTr = ind2tra(outInd, outMean);

msg = [];
fprintf('MSF: Found %dst over %0.2fbp in %0.2fs. %s\n', length(outMean)-1, outMean(1)-outMean(end), toc(startT), msg);