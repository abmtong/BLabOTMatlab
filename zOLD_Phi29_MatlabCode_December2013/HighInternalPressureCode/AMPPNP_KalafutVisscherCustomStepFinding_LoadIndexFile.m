function [SelectedPhages SelectedFeedbackCycles SelectedTStart SelectedTFinish] = AMPPNP_KalafutVisscherCustomStepFinding_LoadIndexFile(IndexFile)
% This function is used by AMPPNP_KalafutVisscherCustomStepFinding_Main to
% load a very specific kind of index file that completely specifies a
% AMPPNP induced pause (see example below). This is very similar to the
% LoadIndexFile used by the t-test AMPPNP_CustomStepFinding, except that
% here we don't need to specify a filtering bandwidth.
%
%     070108N60 #16  220-228sec
%     070108N60 #17  230-235sec
%     070108N60 #18  237.5-241.5sec
%
% Gheorghe Chistol, 03 May 2011

SelectedPhages         = {};
SelectedFeedbackCycles = [];
SelectedTStart         = [];
SelectedTFinish        = [];

fid = fopen(IndexFile);
tline = fgetl(fid);
%disp([tline]);
while ischar(tline)
    tempPhageName = regexp(tline,'\w*N\w*','match');
    tempPhageName = tempPhageName{1};

    tempFeedbackCycle = regexp(tline,'\w*\#\w*','match'); %at this point we have '#17' for example
    if ~isempty(tempFeedbackCycle)
        tempFeedbackCycle=round(str2num(tempFeedbackCycle{1}(2:end)));
    end
    
    tempTStart = regexp(tline,'(([0-9]+\.[0-9])|([0-9]+))-','match'); %at this point we have either '230-' or '53.5-'
    if ~isempty(tempTStart)
        tempTStart=str2num(tempTStart{1}(1:end-1));
    end
    
    tempTFinish = regexp(tline,'-(([0-9]+\.[0-9])|([0-9]+))sec','match'); %at this point we have '-450sec' or '-150.5sec'
    if ~isempty(tempTFinish)
        tempTFinish=str2num(tempTFinish{1}(2:end-3));
    end
    
    if ~isempty(tempPhageName) && ~isempty(tempFeedbackCycle) && ~isempty(tempTStart) && ~isempty(tempTFinish)
        SelectedPhages{end+1}         = tempPhageName;
        SelectedFeedbackCycles(end+1) = tempFeedbackCycle; %#ok<*AGROW>
        SelectedTStart(end+1)         = tempTStart;
        SelectedTFinish(end+1)        = tempTFinish;
    end
    tline = fgetl(fid);
end
fclose(fid);