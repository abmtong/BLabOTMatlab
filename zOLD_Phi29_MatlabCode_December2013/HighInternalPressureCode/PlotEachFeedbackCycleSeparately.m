function PlotEachFeedbackCycleSeparately(PhageData, Bandwidth, SelectedFeedbackCycles)
% This function plots each feedback cycle in a separate window. It was written
% to help select traces for the step finding program. This can only be done 
% by visually screening the data and compiling an index "*.ind" file. 
% 
% A lot of traces have long portions that we don't need, and if you plot those
% parts too it becomes too much. You can use the sister function 
% PlotEachFeedbackCycleSeparately_Aid to find out which FeedbackCycles fall within
% the "*.crop" file. It is recommended that you plot 10-20 Feedback Cycles at a time
% Any more than that will overwhelm the computer and make it sluggish.
%
% Bandwidth      : the desired bandwidth for plotting
% FeedbackCycles : the list of all feedback cycles that you want to plot
%
% USE: PlotEachFeedbackCycleSeparately(Phage, Bandwidth, FeedbackCycles)
%      This plots only the specified FeedbackCycles (a vector of integers)
%
% Gheorghe Chistol, 26 Oct 2010

% if nargin == 3
%     SelectedFeedbackCycles = FeedbackCycles;
% else
%     %all feedback traces will be plotted
%     SelectedFeedbackCycles = 1:1:length([PhageData.time]);
% end

average = round(2500/Bandwidth); %the amount of averaging to be done for filtering

global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

if nargin >1
    for fc=1:length(SelectedFeedbackCycles) %index "fc" stands for "feedback cycle"
        %if no FeedbackCycles have been specified, open the crop file and figure out what portion of the phage trace should be plotted
        CropFile = [analysisPath '\CropFiles\' PhageData.file(1:end-4) '.crop']; 
        % this is the complete address of the crop file that should 
        % correspond to the current phage *.mat file
        
%         if exist(CropFile,'file') %check if the crop file exists, if it doesn't, don't process the phage file at all
%             FID = fopen(CropFile); %open the *.crop file
%             Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
%             Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
%             fclose(FID);
%         else
%             disp('There is no *.CROP file for this Phage trace, quitting.');
%             return;
%         end
        
        %if the duration of the feedback cycle is smaller than 1 sec
        %this feedback cycle is probalby crap, don't bother plotting it
        Condition1 = PhageData.time{fc}(end)-PhageData.time{fc}(1)>1;
%         Condition2 = PhageData.time{fc}(1) > Tstart;
%         Condition3 = PhageData.time{fc}(end) < Tstop;
%         Condition4 = (~Condition2)*Condition3; %partially cutoff first cycle
%         Condition5 = (~Condition3)*Condition2; %partially curoff last cycle
%         Condition6 = Condition2*Condition3; %cycle somewhere in the middle of the crop region
        
        %if the duration of the cycle is longer than 1 second and at least some portion of the 
        %feedback cycle belongs to the crop region, plot it
        if Condition1
            figure();
            tempContour = filter(ones(1, average), average, PhageData.contour{SelectedFeedbackCycles(fc)});
            tempContour = tempContour(average+1:end); %#ok<*NASGU>
            %ind = 1:average:length(temp);
            tempTime = PhageData.time{SelectedFeedbackCycles(fc)}(average+1:end);
            plot(tempTime, tempContour);
            title(['Phage: ' PhageData.file, ' Feedback Cycle: ', num2str(SelectedFeedbackCycles(fc))]);
            Coord=get(0,'ScreenSize'); %get the screen size
            set(gcf,'Position',Coord);
        end
    end
else
    disp('    PlotEachFeedbackCycleSeparately: You have to specify the bandwidth')
    disp('    Example: PlotEachFeedbackCycleSeparately(Phage, Bandwidth) ');
end
