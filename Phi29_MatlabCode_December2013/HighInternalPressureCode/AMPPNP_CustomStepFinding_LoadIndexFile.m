function [SelectedPhages SelectedFeedbackCycles SelectedTStart SelectedTFinish SelectedBandwidth] = AMPPNP_CustomStepFinding_LoadIndexFile(IndexFile)
% This function is used by AMPPNP_CustomStepFinding to load a very specific
% kinf of index file that completely specifies a AMPPNP induced pause (see
% example below)
%
%     070108N60 #16  220-228sec         50Hz
%     070108N60 #17  230-235sec         50Hz
%     070108N60 #18  237.5-241.5sec 	50Hz
%
% Gheorghe Chistol, 02 Mar 2011

SelectedPhages         = {};
SelectedFeedbackCycles = [];
SelectedTStart         = [];
SelectedTFinish        = [];
SelectedBandwidth      = [];

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
    
    tempBandwidth = regexp(tline,'\w*Hz','match'); %at this point we have '50Hz' for example
    if ~isempty(tempBandwidth)
        tempBandwidth=str2num(tempBandwidth{1}(1:end-2));
    end
    if ~isempty(tempPhageName) && ~isempty(tempFeedbackCycle) && ~isempty(tempTStart) && ~isempty(tempTFinish) && ~isempty(tempBandwidth)
        SelectedPhages{end+1}         = tempPhageName;
        SelectedFeedbackCycles(end+1) = tempFeedbackCycle; %#ok<*AGROW>
        SelectedTStart(end+1)         = tempTStart;
        SelectedTFinish(end+1)        = tempTFinish;
        SelectedBandwidth(end+1)      = tempBandwidth;
    end
    tline = fgetl(fid);
end
fclose(fid);