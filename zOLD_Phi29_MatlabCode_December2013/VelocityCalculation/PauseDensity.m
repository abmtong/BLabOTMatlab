 function [NoPauses ContourLength] = Calculate_PauseDensity()
 %% Let the user select files
    global analysisPath;
    [FileName, FilePath] = uigetfile([analysisPath filesep 'VelocityCalculation' filesep 'VelocityResults*.mat'],'MultiSelect','on');
    if ~iscell(FileName)
        temp = FileName; clear FileName;
        FileName{1} = temp; clear temp;
    end
    NoPauses=0;
    L0=0;
    LF=0;
    temp = load([FilePath filesep FileName{1}]); Data = temp.Data; clear temp;
        for fc = 1:length(Data);
            NoPauses=NoPauses+Data(fc).NoPauses;
        end
        LF=max(Data(1).Contour);
        L0=min(Data(length(Data)).Contour);
        ContourLength=LF-L0;
 end