function Result = BurstSize__SummarizeResults()
%
% USE: Result = BurstSize__SummarizeResults()
%
% gheorghe chistol, 05 Jan 2013

    global analysisPath;
    [FileName FilePath] = uigetfile([ [analysisPath filesep] '*N*_FC*.mat'], 'Please select the Step-Finding Results File','MultiSelect','on');

    if ~iscell(FileName)
        temp = FileName; clear FileName; FileName{1} = temp; clear temp;
    end
    
    Result.BurstSize           = [];
    Result.BurstSizeErr        = [];
    Result.BurstLocation       = [];
    Result.DurationDwellBefore = [];
    Result.DurationDwellAfter  = [];

    for f = 1:length(FileName)
        clear Trace Dwells;
        load([FilePath filesep FileName{f}]);
        Dwells = Trace.Dwells;
        
        for d = 1:length(Dwells.DwellDuration)-1
            Result.BurstSize(end+1)           = range(Dwells.DwellLocation(d:d+1)); 
            Result.BurstSizeErr(end+1)        = sum(Dwells.DwellLocationErr(d:d+1));
            Result.BurstLocation(end+1)       = mean(Dwells.DwellLocation(d:d+1));
            Result.DurationDwellBefore(end+1) = Dwells.DwellDuration(d);
            Result.DurationDwellAfter(end+1)  = Dwells.DwellDuration(d+1);
        end
    end
end