function [SelectedPhages SelectedTraces]= tTest_LoadPhageList(IndexFile)
% This function is customized for step finding in HIP traces. It requires an
% IndexFile that has a line of data for each sub-trace. It simply reads the
% names of all phage traces and returns them. If the index is specified as
% 'crop' SelectedTraces{i} has 3 row. Top row specifies the FC, second row 
% specifies the start crop mark for the corresponding FC, and the bottom
% row specifies the stop crop mark as shown below:
% SelectedTraces{end+1}=[ 2     3    4      
%                        1.2   NaN  NaN
%                        NaN   NaN  3.9 ]
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
% USE: [SelectedPhages SelectedTraces]= tTest_LoadPhageList(IndexFile)
%
% Gheorghe Chistol, 22 Oct 2010, modified 020211

SelectedPhages={};
SelectedTraces={};

fid = fopen(IndexFile);
tline = fgetl(fid);
%disp([tline]);
while ischar(tline)
    %the phage name is at the beginning of the line
    SelectedPhages{end+1}=tline(1:10); %for a 3 digit file number like 021310N120
    if strcmp(SelectedPhages{end}(end),' ')
        
        SelectedPhages{end}(end)=''; %remove the space at the end
                                     %for a 2 digit file number like 021310N120
        %disp([SelectedPhages{end} '--'])
    end
    
    %Now get the feedback cycles specified in the index file
    %we cal accomodate compact notation like 091608N15 2-7 separately
    if ~isempty(findstr(tline(11:end),'-'))
        %if there is a dash in the string, we have a compact notation
        temp=sscanf(tline(11:end),'%u-%u');
        if length(temp)==2 %we have the start and the finish
            if temp(2)>temp(1)
                SelectedTraces{end+1}=[temp(1):temp(2)]; %range from start to finish
            end
        end
    elseif ~isempty(findstr(tline(11:end),'crop')) %if the user wants to use the crop region
        %SelectedTraces{end+1}='crop';
        %instead of defining SelectedTraces{end+1}=[2 3 4 7 8] etc
        %we will now have to define Tstart and Tfinish for each feedback
        %trace as follows:
        %SelectedTraces{end+1}=[ 2     3    4      list of Feedback Cycles
        %                        1.2  NaN   NaN    start time
        %                        NaN  NaN   3.9 ]; stop time
        %in this context, NaN means the start of stop is not defined, i.e.
        %use everything. 
        global analysisPath;
        if isempty(analysisPath)
            disp('analysisPath was not previously defined. Please define it and try again.'); return;
        end

        CropFile = [analysisPath '\CropFiles\' SelectedPhages{end} '.crop'];
        
        %check if the crop file exists, if it doesn't, don't process the phage file at all
        if exist(CropFile,'file') 
            PhageFile=[analysisPath '\' 'phage' SelectedPhages{end} '.mat'];
            load(PhageFile); %load the corresponding phage file
            Trace = stepdata; clear stepdata; %load the data and clear intermediate data

            FID = fopen(CropFile); %open the *.crop file
            Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
            Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
            fclose(FID);
            
            %Trace.time={[1x7825 double] [1x7 double] [1x89729 double] [1x2924 double]};
            TempSelection=[]; %the index of the selected traces for this particular phage file
            TempSelectionInd=[];
            for fc=1:length(Trace.time) %fc is the index of Feedback Cycles
                if min(Trace.time{fc})>Tstart && max(Trace.time{fc})<Tstop
                    %this FC will be used in its entirety
                    TempSelection=[TempSelection [fc NaN NaN]'];
                    TempSelectionInd(end+1) = fc; 
                elseif min(Trace.time{fc})<Tstart && max(Trace.time{fc})<Tstop && max(Trace.time{fc})>Tstart
                    %this FC will be cropped from the beginning only
                    TempSelection=[TempSelection [fc Tstart NaN]'];
                elseif min(Trace.time{fc})>Tstart && max(Trace.time{fc})>Tstop && min(Trace.time{fc})<Tstop
                    %this FC will be cropped from the end only
                    TempSelection=[TempSelection [fc NaN Tstop]'];
                elseif min(Trace.time{fc})<Tstart && max(Trace.time{fc})>Tstop
                    %this FC will be cropped both from the start and end
                    TempSelection=[TempSelection [fc Tstart Tstop]'];
                end
            end
            %TempSelection
            %TempSelectionInd
            %SelectedTraces{end+1}=TempSelection;
            SelectedTraces{end+1}=TempSelectionInd;
        else %the crop file doesn't exist, this whole phage file is useless
            %remove the current phage filename from the list and move on
            SelectedPhages(end)='';
        end
    else
        %we have the long form notation
        SelectedTraces{end+1} = sscanf(tline(11:end),'%u')'; %#ok<*AGROW>
    end
    tline = fgetl(fid);
end
fclose(fid);