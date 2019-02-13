function tTestThr = AutoSetTTestThr(PhageData, Percentile, FeedbackCycle, PlotOption)
% This function automatically sets the threshold for the T-Test algorythm.
% Percentile: t-Test threshold percentile. The threshold will be
% set to have 10% of all the Sgn values below the t-Test threshold.
% Note that this function only performs the operation on a specified FeedbackCycle
%
% USE: tTestThr = AutoSetTTestThr(PhageData, Percentile, FeedbackCycle, PlotOption)
%
% Gheorghe Chistol, 25 Oct 2010

%% Automating the Thresholding for the T-Test
%generate the histogram using the log of the sgn value
[NrPts, Bin]=hist(log10(PhageData.sgn{FeedbackCycle}),1000); %using 1000bins

%Generate the cumulative distribution
for i=1:length(Bin)
    CumDistr(i) = sum(NrPts(1:i));
end
%normalize the Cumulative Distribution
CumDistr=CumDistr./CumDistr(end);

IndAbove=find(CumDistr>Percentile);
if isempty(IndAbove)
    tTestThr=[]; %nothing to set here
    disp('... ! Warning: Couldn not set the t-test threshold');
else
    tTestThr=10^Bin(IndAbove(1)); %convert from log10 to a number
    disp(['... T-Test threshold has been automatically set to ' num2str(tTestThr)]);
end

if ~strcmp(PlotOption,'NoPlot')
    figure;
    plot(Bin,CumDistr,'b');
    xlabel('Log10 of Sgn Value');
    ylabel('Normalized Cumulative Distribution');
    
    figure;
    semilogy(PhageData.time{FeedbackCycle}, PhageData.sgn{FeedbackCycle},'.-');
    hold on;
    plot(PhageData.time{FeedbackCycle}, tTestThr,'-r');
    xlabel('Time (sec)');
    ylabel('Log10 of Sgn Value');
end