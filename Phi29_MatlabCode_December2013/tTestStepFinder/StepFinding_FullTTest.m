function [Transitions Data] = StepFinding_FullTTest(Data,tWin,tTestThr)
% This function calculates the T-test and saves that info in Data.
% The structure "Data" has the following fields
% Data.Time
% Data.Contour
% Data.FilteredTime
% Data.FilteredContour
% Data.FilteringFactor
% Data.t   - t-test value
% Data.sgn - t-test significance value
%
% tWin     : window size for T-test
% tTestThr : T-test Threshold for identifying transitions
%
% USE: [Transitions Data] = StepFinding_FullTTest(Data,tWin,tTestThr)
%
% Gheorghe Chistol, 15 March 2011



%------------------------------- Run main loop, filter data & calculate t-test
temp = 0;
count = 0;
sgn_min_all = []; stepsize_all = []; dwelltime_all = []; stepsize_select_all = []; 
std_select_all = []; wid_all =[];

display(['... Running Full T-Test, tWin = ' num2str(tWin) 'pts']);

%the data has been filtered and decimated already, so use that
contour = Data.FilteredContour;
time    = Data.FilteredTime;
dt      = time(2)-time(1);

if length(contour) > tWin % only use data longer than t-test window
    %------------------------------- Calculate t and sgn
    [t, sgn] = StepFinding_TTestWindow(contour, tWin);
    %add t and sgn to the Data structure, replacing the obsolete values from the last round of t-test calculation
    Data.t   = t';
    Data.sgn = sgn';

    xav = contour;
    tav = time;

    %------------------------------- Find minima in sgn (they correspond to transitions)
    %sometimes tTestThr is too low, causing the function to crash, so we're
    %dealing with this here, Gheorghe Chistol, 27Jan2011
    ind=Data.sgn<tTestThr;

    if tTestThr>min(Data.sgn) && tTestThr<max(Data.sgn)
        %there is at least one transition in this data, go ahead
        [Transitions, xfit] = StepFinding_SelectTransitions(xav,Data.sgn,[tTestThr 1]);
    else
        %disp('!!!! Ding Ding Ding !!!');
        %threshold is too low or too high, there are no transitions in here
        Transitions=[];
        xfit=mean(xav)*ones(size(xav));
    end
    % Export tav and xfit for easy use later JM 01/29/08
    Data.FitContour = xfit;
    Data.FitTime    = tav;
end