function HistogramBinwidthOptimization(Data,BinWidthRange,PlotOption)
% Given the Data, this function will calculate the optimal binwidth size
% based on the method described here
% http://toyoizumilab.brain.riken.jp/hideaki/res/histogram.html 
%
% BinWidthRange provides the restricted search space
%
% USE:
%
% Gheorghe Chistol, 22 June 2011

%do 100 trials
N=100;
BinWidth = min(BinWidthRange):range(BinWidthRange)/N:max(BinWidthRange);
DeltaC = []; %the penalty/cost that has to be minimized in this case

for i=1:length(BinWidth)
    Bins = min(Data)+BinWidth(i)/2:BinWidth(i):max(Data)-BinWidth(i)/2;
    [n x] = hist(Data,Bins); %compute the bin occupancy
    clear Mean Var;
    Mean = mean(n);
    Var  = std(n,1); %using the biased variance method, normalize by N instead of (N-1)
    DeltaC(i) = (2*Mean-Var)/(BinWidth(i))^2;
end

close all; 
plot(BinWidth,DeltaC,'.b');