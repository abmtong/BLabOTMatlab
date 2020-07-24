function [SelectedPhages SelectedTraces CropStartTimes CropStopTimes] = LLP_LoadPhageList(IndexFile)
% This function is customized for step finding in HIP traces. It requires an
% IndexFile that has a line of data for each sub-trace. It simply reads the
% names of all phage traces and returns them. If the index is specified as
% 'crop' SelectedTraces{i} has 3 row. 
%
% PhageName FeedbackCycle#
%
% Example:
% 070108N90     9 10 11 12 13
% 092008N40     23 24 25
% 091608N15     1 4 8
% 091608N16     5-10  %also acceptable
% 091608N17     crop  %also acceptable, given that the file has crop marks
%
% USE: [SelectedPhages SelectedTraces CropStartTimes CropStopTimes] = LLP_LoadPhageList(IndexFile)
%
% Gheorghe Chistol, 30 Nov 2012

    global analysisPath;
    SelectedPhages  = {};
    SelectedTraces  = {};
    CropStartTimes  = [];
    CropStopTimes   = [];

    fid = fopen(IndexFile);
    tline = fgetl(fid);

    while ischar(tline)%the phage name is at the beginning of the line
        CurrPhage = tline(1:10); %for a 3 digit file number like 021310N120
        if strcmp(CurrPhage(end),' ')
            CurrPhage(end)=''; %remove the space at the end for a 2 digit file number like 021310N12
        end
         
        CropFile = [analysisPath '\CropFiles\' CurrPhage '.crop']; %check if the crop file exists, if it doesn't, don't process the phage file at all
        if exist(CropFile,'file') 
            FID    = fopen(CropFile); %open the *.crop file
            Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
            Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
            fclose(FID);
            SelectedPhages{end+1} = CurrPhage; %only consider the phage if it has a crop file
            CropStartTimes(end+1) = Tstart;
            CropStopTimes(end+1)  = Tstop;
        
            %>>> Now get the feedback cycles specified in the index file
            if ~isempty(findstr(tline(11:end),'-')) %we cal accomodate compact notation like 091608N15 2-7 separately
                temp=sscanf(tline(11:end),'%u-%u'); %if there is a dash in the string, we have a compact notation
                if length(temp)==2 %we have the start and the finish
                    if temp(2)>temp(1)
                        SelectedTraces{end+1} = temp(1):temp(2); %range from start to finish
                    end
                end
            elseif ~isempty(findstr(tline(11:end),'crop')) %if the user wants to use the crop region
                PhageFile=[analysisPath '\' 'phage' SelectedPhages{end} '.mat'];
                load(PhageFile); %load the corresponding phage file
                Trace = stepdata; clear stepdata; %load the data and clear intermediate data
                ListOfFeedbackCycles = [];
                for fc=1:length(Trace.time) %fc is the index of Feedback Cycles
                    if sum(Trace.time{fc}>Tstart & Trace.time{fc}<Tstop)>0 %there are data points in this FC within the crop marks
                        ListOfFeedbackCycles(end+1) = fc; 
                    end
                end
                SelectedTraces{end+1} = ListOfFeedbackCycles;
            else %we have the long form notation
                SelectedTraces{end+1} = sscanf(tline(11:end),'%u')'; %#ok<*AGROW>
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end