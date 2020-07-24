 function [PauseDensity NoPauses ContourLength] = Calculate_PauseDensity()
 %% Let the user select files
    NoPauses           = [];
    L0                 = 0;
    LF                 = 0;
    PauseDensity       = []
    ContourLength      = [];
    
    
    global analysisPath;
    [FileName, FilePath] = uigetfile([analysisPath filesep 'VelocityCalculation' filesep 'VelocityResults*.mat'],'MultiSelect','on');
    if ~iscell(FileName)
        temp = FileName; clear FileName;
        FileName{1} = temp; clear temp;
    end
   
    for f = 1:length(FileName)
        temp = load([FilePath filesep FileName{f}]); Data = temp.Data; clear temp;
        PausesCounter=0;    
            for fc = 1:length(Data);
                PausesCounter = PausesCounter + Data(fc).NoPauses;
            end
        NoPauses(f) =  PausesCounter;  
        LF=max(Data(1).Contour);
        L0=min(Data(length(Data)).Contour);
        ContourLength(f) = LF-L0;
        PauseDensity(f)=(NoPauses(f)/ContourLength(f))*1000;
    end
    %display(ContourLength)
    %display(NoPauses)
 end