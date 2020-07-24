function Data = tTest_Bare(Data, AvgNum, WindowSize)
% This function calculates the T-test only, which is used later to
% automatically set the threshold for the tTest 
%
% Initially "Data" has the following structure
% Data.Time
% Data.Contour
%
% The current function will add the following fields
% Data.FilteredTime
% Data.FilteredContour
% Data.FilteringFactor
% Data.t   - t-test value
% Data.sgn - t-test significance value
%
%
% USE:  Data = tTest_Bare(Data, AvgNum, WindowSize)
%
% Gheorghe Chistol, 24 May 2012

disp('... Calculating bare T-Test:');

%------------------------------- Filter and decimate data
%we are only calculating the t-test for the specified feedback cycle, to make the computation faster
Data.FilteredTime    = tTest_FilterAndDecimate(Data.Time,AvgNum);
Data.FilteredContour = tTest_FilterAndDecimate(Data.Contour,AvgNum);
Data.FilteringFactor = AvgNum;

%dt = Data.FilteredTime(2)-Data.FilteredTime(1);

if length(Data.FilteredContour) > WindowSize % only use data longer than t-test window
    %------------------------------- Calculate t and sgn
    [t, sgn] = tTest_Window(Data.FilteredContour, WindowSize);
    Data.t = t';
    Data.sgn = sgn';
else
    disp('... ! Error: The t-test window is larger than the data.');
end