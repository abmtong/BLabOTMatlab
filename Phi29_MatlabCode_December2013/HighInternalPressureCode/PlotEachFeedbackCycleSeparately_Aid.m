function PlotEachFeedbackCycleSeparately_Aid(PhageData)
% This function comes as a helper function when using its sister
% PlotEachFeedbackCycleSeparately.m The idea is that only the feedback cycles
% toward the end of the packaging trace contain data with good stepping. You can
% plot absolutely all feedback cycles in a trace (falling within the crop region)
% but that may overwhelm your computer. Instead you can use this function to ask 
% "Which Feedback Cycles fall within the Crop Region?" and then plot only 
% a subset of those (the last half or so). 
%
% USE: PlotEachFeedbackCycleSeparately_Aid(PhageData) 
%
% Gheorghe Chistol, 25 Oct 2010

global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

%all feedback traces
FeedbackCycles = 1:1:length([PhageData.time]);
FirstOne=0; %the very first feedback cycle within the crop region
LastOne=0;  %the very last feedback cycle within the crop region

for fc=1:length(FeedbackCycles) %index "fc" stands for "feedback cycle"
    %open the crop file
    CropFile = [analysisPath '\CropFiles\' PhageData.file(1:end-4) '.crop']; 
    % this is the complete address of the crop file that should 
    % correspond to the current phage *.mat file

    if exist(CropFile,'file') %check if the crop file exists, if it doesn't, don't process the phage file at all
        FID = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
        fclose(FID);
    else
        disp('There is no *.CROP file for this Phage trace, quitting.');
        return;
    end

    Condition1 = PhageData.time{fc}(1) > Tstart;
    Condition2 = PhageData.time{fc}(end) < Tstop;
    Condition3 = PhageData.time{fc}(end) > Tstart;
    Condition4 = PhageData.time{fc}(1) < Tstop;
    InTheMiddle = Condition1*Condition2;
    PartiallyCroppedFirst = Condition2*Condition3*(~Condition1);
    PartiallyCroppedLast  = Condition1*Condition4*(~Condition2);

   % if InTheMiddle || PartiallyCroppedFirst || PartiallyCroppedLast
    if InTheMiddle
        %this feedback cycle is either fully or partially contained in the crop region
        if FirstOne==0
            %this is the very first feedback cycle of interest
            FirstOne=FeedbackCycles(fc);
        else
            %this portion will keep updating itself until the end
            %the very last recorded value will be in fact
            %the very last feedback cycle of interest
            LastOne=FeedbackCycles(fc);
        end
    end
end

disp(['The following Feedback Cycles fall within the Crop region: ' num2str(FirstOne) '-' num2str(LastOne)]);
