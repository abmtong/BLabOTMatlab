 function [x] = Calculate_PauseDensity()
 %% Let the user select files
    global analysisPath;
    [FileName, FilePath] = uigetfile([analysisPath filesep 'VelocityCalculation' filesep 'VelocityResults*.mat'],'MultiSelect','on');
    if ~iscell(FileName)
        temp = FileName; clear FileName;
        FileName{1} = temp; clear temp;
    end
    x=0;
    temp = load([FilePath filesep FileName{1}]); Data = temp.Data; clear temp;
        for fc = 1:length(Data);
            x=x+Data(fc).NoPauses;
        end
 end