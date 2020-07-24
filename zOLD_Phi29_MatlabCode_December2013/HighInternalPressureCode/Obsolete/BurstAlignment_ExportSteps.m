global analysisPath;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it');
    return;
else
    disp(['analysisPath has been set to: ' analysisPath]);
end

[Filename, Pathname] = uigetfile([[analysisPath '\'],'*.mat'], 'Pick a data file','MultiSelect', 'off');
load([Pathname '\' Filename]);
%FinalDwells is the name of the data structure
for p=1:length(FinalDwells) %p stands for phage index
    
    for fc=1:length(FinalDwells{p}) %fc stands for feedback cycle index
        if ~isempty(FinalDwells{p}{fc})
            temp=FinalDwells{p}{fc}.PhageFile;
            LastChar=temp(end); temp(end)=[];
            PhageFileName='';
            while ~strcmp(LastChar,'\')
                PhageFileName=[LastChar PhageFileName];
                LastChar=temp(end); temp(end)=[];
            end
            
            temp=analysisPath;
            ATP='';
            status='continue';
            while strcmp(status,'continue')
                character = temp(end);
                temp(end)='';
                if strcmp(character,'\')
                    status='stop';
                else
                    ATP=[character ATP];
                end
            end
            
            ExportStepsFolder = [analysisPath '\' 'ExportSteps\'];
            if ~isdir(ExportStepsFolder);
                mkdir(ExportStepsFolder);%create the directory
            end
            OutputFileName=[ExportStepsFolder '\' PhageFileName(6:end-4) '_' num2str(FinalDwells{p}{fc}.FeedbackCycle) '_' ATP '.steps'];
            %disp(OutputFileName)
            FID=fopen(OutputFileName,'w');

            results=[FinalDwells{p}{fc}.StepSize' ...
                     FinalDwells{p}{fc}.std(2:end)' ...
                     (FinalDwells{p}{fc}.std(2:end)./sqrt(FinalDwells{p}{fc}.Npts(2:end)))' ...
                     FinalDwells{p}{fc}.DwellTime(2:end)' ...
                     FinalDwells{p}{fc}.DwellLocation(2:end)'];
                 
            [Height ~]=size(results);
            %results(1:5,:)
            %return
            %print line by line
            fprintf(FID, 'StepSize  DwellStd(the dwell after the step)  DwellStErr  DwellTime  DwellLocation(Location means: the length of the DNA tether, we are packaging 21kb DNA \n');
            for h=1:Height
                %N=(results(h,2)/results(h,3))^2;
                %disp(['N = ' num2str(N)]);
                fprintf(FID,'%f %f %f %f %f \n',results(h,:));
            end
            fclose(FID);
        end
    end
end