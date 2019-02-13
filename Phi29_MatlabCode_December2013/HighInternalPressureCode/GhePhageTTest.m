function [Transitions, PhageData] = GhePhageTTest(PhageData, tWin, tTestThr, FeedbackCycle)
% This function calculates the T-test and saves that info in PhageData.
% Use this function instead of the one in the NewAnalysis folder
% tWin     : window size for T-test
% tTestThr : T-test Threshold for identifying transitions
%
% USE: [Transitions, PhageData] = PhageTTest(PhageData, tWin, tTestThr, FeedbackCycle)
%
% Gheorghe Chistol, 25 Oct 2010



%------------------------------- Run main loop, filter data & calculate t-test
temp = 0;
count = 0;
sgn_min_all = []; stepsize_all = []; dwelltime_all = []; stepsize_select_all = []; 
std_select_all = []; wid_all =[];

display(['... T-Test for Phage: ' PhageData.file ', Feedback Cycle: ' num2str(FeedbackCycle) ', tWin = ' num2str(tWin) 'pts']);

    
%the data has been filtered and decimated already, so use that
contour = PhageData.contourFiltered{FeedbackCycle};
time    = PhageData.timeFiltered{FeedbackCycle};
dt      = time(2)-time(1);

if length(contour) > tWin % only use data longer than t-test window
    %------------------------------- Calculate t and sgn
    [t, sgn] = TTestWindow(contour, tWin, 'CalSign');
    %add t and sgn to the PhageData structure, replacing the obsolete values from the last round of t-test calculation
    PhageData.t{FeedbackCycle}   = t';
    PhageData.sgn{FeedbackCycle} = sgn';

    xav = contour;
    tav = time;

    %------------------------------- Find minima in sgn (they correspond to transitions)
    %sometimes tTestThr is too low, causing the function to crash, so we're
    %dealing with this here, Gheorghe Chistol, 27Jan2011
    ind=PhageData.sgn{FeedbackCycle}<tTestThr;

    if tTestThr>min(PhageData.sgn{FeedbackCycle}) && tTestThr<max(PhageData.sgn{FeedbackCycle})
        %there is at least one transition in this data, go ahead
        [Transitions, xfit] = SelectTransitions(xav,PhageData.sgn{FeedbackCycle},[tTestThr 1]);
    else
        %disp('!!!! Ding Ding Ding !!!');
        %threshold is too low or too high, there are no transitions in here
        Transitions=[];
        xfit=mean(xav)*ones(size(xav));
    end
    % Export tav and xfit for easy use later JM 01/29/08
    PhageData.contourFit{FeedbackCycle} = xfit;
    PhageData.timeFit{FeedbackCycle}    = tav;
end