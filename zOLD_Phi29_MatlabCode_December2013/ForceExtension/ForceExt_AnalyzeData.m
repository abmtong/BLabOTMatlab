function ForceExt_AnalyzeData()
% This function loads a force-extension file and plots it. Then you select
% the portion of the pulling curve that you want to fit the Worm Like Chain
% to. 
%
% Gheorghe Chistol, 10 Feb 2012

    global analysisPath;

    [FileName, FilePath] = uigetfile([analysisPath filesep 'ForceExtension*.mat'], 'MultiSelect','off','Pick a Force Extension Curve');
    load([FilePath filesep FileName]);

    %prepare data that will be shared among plotting and fitting functions
    Data.Time      = ContourData.time;
    Data.Force     = ContourData.force;
    Data.Extension = ContourData.extension;
    Data.FileName  = FileName;
    Data.FilePath  = FilePath;
    
    N=20; %filtering parameter
    Data.Time      = ForceExt_FilterAndDecimate(Data.Time,      N);
    Data.Force     = ForceExt_FilterAndDecimate(Data.Force,     N);
    Data.Extension = ForceExt_FilterAndDecimate(Data.Extension, N);

    figure('Units','normalized','Position', [6e-3 0.06 0.49 0.87]);
    subplot(2,1,1);
    plot(Data.Time, Data.Force);
    xlabel('Time (sec)'); ylabel('Force (pN)');
    subplot(2,1,2);
    plot(Data.Extension, Data.Force);
    ylabel('Force (pN)'); xlabel('Extension (nm)');
    title([Data.FileName],'Interpreter','none');
    
    guidata(gcf,Data); %save the data structure to the figure. This allows us to share data among various functions without global variables (which I hate)
    ForceExt_SelectPortion();
end