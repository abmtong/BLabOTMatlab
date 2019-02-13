function phageData = GheBareTTest(phages, average, win, phageData)
%This function calculates the T-test only, which is used later to automatically set the threshold for the tTest 
%
% Gheorghe Chistol, 15 June 2010

for i=1:length(phageData)
    phageInd(i) = phageData(i).phID;
    stepInd(i) = phageData(i).stID;
end

if length(phages) == 1
    phages(1) = phages;
end

%------------------------------- Run main loop, filter data & calculate t-test
temp = 0;
count = 0;
sgn_min_all = []; stepsize_all = []; dwelltime_all = []; stepsize_select_all = []; 
std_select_all = []; wid_all =[];
for i = 1:length(phageInd)
    if temp ~= phageInd(i)
        display(['Calculating T Test for phage #' num2str(phageInd(i)) ': ' phages(phageInd(i)).file]);
    end


    %------------------------------- Filter and decimate data
    contour = filter(ones(1,average), average, phages(phageInd(i)).contour{stepInd(i)});
    contour = contour(average:average:end);
    phageData(i).contour=contour;
    time = phages(phageInd(i)).time{stepInd(i)};
    time = time(average:average:end);
    dt = time(2)-time(1);
    phageData(i).time=time;

    if length(contour) > win % only use data longer than t-test window
        %------------------------------- Calculate t and sgn
        [t, sgn] = TTestWindow(contour, win, 'CalSign');
        phageData(i).t = t';
        phageData(i).sgn = sgn';
    else
        disp('Error: The t-test window is larger than the data.');
    end
end

%% Remove the unnecessary fields
Fields={'velocity' 'std' 'contourStart' 'contourEnd' ...
    'contourAv' 'hist' 'bin' 'filter' 'binsize' 'rank' 'start' ...
    'end' 'fft' 'freq' 'peak' 'visibleSteps' 'paused' 'contOffset' ...
    'timeAv' 'timeStart' 'timeEnd' 'numPoints' 'forceErr'};
for i=1:length(Fields)
    phageData=rmfield(phageData, Fields(i));
end