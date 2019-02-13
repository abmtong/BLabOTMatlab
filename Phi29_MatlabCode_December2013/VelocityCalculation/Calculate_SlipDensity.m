 function [SlipDensity, NumberOfSlips, TraceLength] = Calculate_SlipDensity()
 %% Let the user select files
 
 SlipDensity=[];
 NumberOfSlips=[];
 TraceLength=[];
    global analysisPath;
    [FileName, FilePath] = uigetfile([analysisPath filesep 'VelocityCalculation' filesep 'VelocityResults*.mat'],'MultiSelect','on');
    if ~iscell(FileName)
        temp = FileName; clear FileName;
        FileName{1} = temp; clear temp;
    end
    
    for  f= 1:length(FileName);
    NoSlips=0;
    L0=0;
    LF=0;
    temp = load([FilePath filesep FileName{f}]); Data = temp.Data; clear temp;
        for fc = 1:length(Data);
            NoSlips=NoSlips+length(Data(fc).Slips.SlipSize);
        end
        LF=max(Data(1).Contour);
        L0=min(Data(end).Contour);
        ContourLength=LF-L0;
        
        SlipDensity(f)=(NoSlips/ContourLength)*1000;
        NumberOfSlips(f)=NoSlips;
        TraceLength(f)=ContourLength;
        %SlipDensityError=sqrt(NoSlips)/ContourLength;
    end
 end