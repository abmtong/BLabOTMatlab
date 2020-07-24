function PhageData = BareTTest(PhageData, AvgNum, tWinStart, FeedbackCycle)
% This function calculates the T-test only, which is used later to automatically set the threshold for the tTest 
%
% USE: PhageData = BareTTest(PhageData, AvgNum, tWinStart, FeedbackCycle)
%
% Gheorghe Chistol, 25 Oct 2010

% PhageData = 
%              path: 'D:\Phi29\2010_DATA\091310\'
%              file: '091310N12.dat'
%     date_modified: '16-Sep-2010'
%             stamp: 7.3440e+005
%           calpath: 'D:\Phi29\2010_ANALYSIS\091310_21kb_250uM_ATP\'
%           calfile: 'avCal.mat'
%          calstamp: {1x6 cell}
%              time: {1x15 cell}
%           contour: {1x15 cell}
%             force: {1x15 cell}
%        forceX_err: {1x15 cell}
%        forceY_err: {1x15 cell}
%             trapX: {1x15 cell}
%             trapY: {1x15 cell}

%------------------------------- Run main loop, filter data & calculate t-test
temp = 0;
count = 0;
sgn_min_all = []; stepsize_all = []; dwelltime_all = []; stepsize_select_all = []; 
std_select_all = []; wid_all =[];

disp(['... Calculating T-Test for Phage #' PhageData.file ', Feedback Cycle #: ' num2str(FeedbackCycle)]);

%------------------------------- Filter and decimate data
%we are only calculating the t-test for the specified feedback cycle, to make the computation faster
contour = filter(ones(1,AvgNum), AvgNum, PhageData.contour{FeedbackCycle});
contour = contour(AvgNum:AvgNum:end);
PhageData.contourFiltered{FeedbackCycle} = contour;

time = PhageData.time{FeedbackCycle};
time = time(AvgNum:AvgNum:end);
dt = time(2)-time(1);
PhageData.timeFiltered{FeedbackCycle}=time;

if length(contour) > tWinStart % only use data longer than t-test window
    %------------------------------- Calculate t and sgn
    [t, sgn] = TTestWindow(contour, tWinStart, 'CalSign');
    PhageData.t{FeedbackCycle} = t';
    PhageData.sgn{FeedbackCycle} = sgn';
else
    disp('... ! Error: The t-test window is larger than the data.');
end

% %% Remove the unnecessary fields
% Fields={'velocity' 'std' 'contourStart' 'contourEnd' ...
%     'contourAv' 'hist' 'bin' 'filter' 'binsize' 'rank' 'start' ...
%     'end' 'fft' 'freq' 'peak' 'visibleSteps' 'paused' 'contOffset' ...
%     'timeAv' 'timeStart' 'timeEnd' 'numPoints' 'forceErr'};
% for i=1:length(Fields)
%     phageData=rmfield(phageData, Fields(i));
% end