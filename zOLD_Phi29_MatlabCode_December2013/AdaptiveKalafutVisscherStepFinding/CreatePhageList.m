function CreatePhageList( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% Ask for parameters
global analysisPath; %set the analysis path if neccessary

%% Select the Phage Traces for Analysis
File = uigetfile([ [analysisPath filesep] 'phage*.mat'], 'Please Selecte Phage that will be further analyzed:','MultiSelect', 'on');
if isempty(File); disp('No *.mat phage files were selected'); return; end;
if ~iscell(File); temp=File; clear File; File{1}=temp; end; %if there is only one file, make it into a cell, for easier processing later

[IndexFile,IndexFilePath] = uiputfile([analysisPath filesep 'PhageList_.txt'],'Save the list of the phage files');
FID = fopen([IndexFilePath filesep IndexFile], 'wt+');

    for p=1:length(File) %p is the phage index
        CropFile = [analysisPath filesep 'CropFiles' filesep File{p}(6:end-4) '.crop'];
        if ~exist(CropFile,'file') %if the crop file doesn't exist
            disp([File{p} ' was skipped, it has no CROP file']);
        else %proceed to generate PWDs
            disp(['Creating list of Feedback Cycles for ' File{p}]);
            StartT=tic; %start the timer to measure the duration of calculation
            load([analysisPath filesep File{p}]);
            phage=stepdata; clear stepdata;

            FID2 = fopen(CropFile); %open the *.crop file
            Tstart = sscanf( fgetl(FID2),'%f'); %parse the first line, which is the start time
            Tstop  = sscanf( fgetl(FID2),'%f'); %parse the second line, which is the stop time
            fclose(FID2);

            SelectedFeedbackCycles=[]; %FCs that we want to have PWDs for
            for fc=1:length(phage.time) %fc is the index of Feedback Cycles
                if min(phage.time{fc})>Tstart && max(phage.time{fc})<Tstop
                    if length(phage.time{fc})>10
                    %this FC will be used in its entirety
                    SelectedFeedbackCycles(end+1)=fc;
                    end
                end
            end


          line = [File{p}(6:end-4) '  '];
          for j=1:length(SelectedFeedbackCycles);
            line = [line ' ' num2str(SelectedFeedbackCycles(j))];
          end
          fprintf(FID,'%s \n',line);
        end
    end
fclose(FID);

end

