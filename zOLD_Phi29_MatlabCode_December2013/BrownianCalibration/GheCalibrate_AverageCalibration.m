function GheCalibrate_AverageCalibration()
% Load several calibration files and average them together for a better
% estimation of the stiffness and the alpha coefficients. You can generate
% the calibration files apriori using 'GheCalibrate.m'
%
% USE: GheCalibrate_AverageCalibration()
%
% Gheorghe Chistol, 10 Feb 2012


global analysisPath;

    [CalFileName CalFilePath] = uigetfile([ analysisPath filesep 'cal*.mat'],'Select calibration files','MultiSelect','on');
    if isempty(CalFileName) %if no files were selected
        error('No files were selected');
    end

    if ~iscell(CalFileName) %convert into a cell for convenience
        temp = CalFileName; CalFileName=''; CalFileName{1}=temp; clear temp;    
    end
    
    avCal.path         = CalFilePath;
    avCal.file         = 'avCal.mat';
    avCal.file_list    = CalFileName;
    avCal.stamp        = now;
    avCal.date         = date;
    avCal.beadRadiusA  = NaN(1,length(CalFileName)); %initially this will be a list
    avCal.beadRadiusB  = NaN(1,length(CalFileName)); %the we'll use unique to make sure they are all the same value
    avCal.dragCoeffA   = NaN;
    avCal.dragCoeffB   = NaN;
    avCal.alphaAX      = NaN;
    avCal.alphaAY      = NaN;
    avCal.alphaBX      = NaN;
    avCal.alphaBY      = NaN;
    avCal.kappaAX      = NaN;
    avCal.kappaAY      = NaN;
    avCal.kappaBX      = NaN; 
    avCal.kappaBY      = NaN;
    avCal.alphaAX_list = NaN(1,length(CalFileName));
    avCal.alphaAY_list = NaN(1,length(CalFileName));
    avCal.alphaBX_list = NaN(1,length(CalFileName));
    avCal.alphaBY_list = NaN(1,length(CalFileName));
    avCal.kappaAX_list = NaN(1,length(CalFileName));
    avCal.kappaAY_list = NaN(1,length(CalFileName));
    avCal.kappaBX_list = NaN(1,length(CalFileName));
    avCal.kappaBY_list = NaN(1,length(CalFileName));
    avCal.alphaAX_std  = NaN;
    avCal.alphaAY_std  = NaN;
    avCal.alphaBX_std  = NaN;
    avCal.alphaBY_std  = NaN;
    avCal.kappaAX_std  = NaN;
    avCal.kappaAY_std  = NaN;
    avCal.kappaBX_std  = NaN; 
    avCal.kappaBY_std  = NaN;    
    
    for f = 1:length(CalFileName)
        cal = load([CalFilePath filesep CalFileName{f}],'cal'); cal = cal.cal;

        avCal.beadRadiusA(f)  = cal.beadRadiusA;
        avCal.beadRadiusB(f)  = cal.beadRadiusB;
        avCal.dragCoeffA      = cal.dragCoeffA;
        avCal.dragCoeffB      = cal.dragCoeffB;
        avCal.alphaAX_list(f) = cal.alphaAX;
        avCal.alphaAY_list(f) = cal.alphaAY;
        avCal.alphaBX_list(f) = cal.alphaBX;
        avCal.alphaBY_list(f) = cal.alphaBY;
        avCal.kappaAX_list(f) = cal.kappaAX;
        avCal.kappaAY_list(f) = cal.kappaAY;
        avCal.kappaBX_list(f) = cal.kappaBX;
        avCal.kappaBY_list(f) = cal.kappaBY;
    end
    
    %check that all files have the same beads sizes
    avCal.beadRadiusA = unique(avCal.beadRadiusA);
    avCal.beadRadiusB = unique(avCal.beadRadiusB);
    if length(avCal.beadRadiusA)~=1 || length(avCal.beadRadiusB)~=1
        error('GheCalibrate_AverageCalibration: Bead sizes are not all the same :(');
    end
    
    avCal.alphaAX      = mean(avCal.alphaAX_list);
    avCal.alphaAY      = mean(avCal.alphaAY_list);
    avCal.alphaBX      = mean(avCal.alphaBX_list);
    avCal.alphaBY      = mean(avCal.alphaBY_list);
    avCal.kappaAX      = mean(avCal.kappaAX_list);
    avCal.kappaAY      = mean(avCal.kappaAY_list);
    avCal.kappaBX      = mean(avCal.kappaBX_list);
    avCal.kappaBY      = mean(avCal.kappaBY_list);
    avCal.alphaAX_std  = std( avCal.alphaAX_list);
    avCal.alphaAY_std  = std( avCal.alphaAY_list);
    avCal.alphaBX_std  = std( avCal.alphaBX_list);
    avCal.alphaBY_std  = std( avCal.alphaBY_list);
    avCal.kappaAX_std  = std( avCal.kappaAX_list);
    avCal.kappaAY_std  = std( avCal.kappaAY_list);
    avCal.kappaBX_std  = std( avCal.kappaBX_list);
    avCal.kappaBY_std  = std( avCal.kappaBY_list);

    clc;
    disp( '----[ List ]------------------------------------------------------');
    for f = 1:length(CalFileName)
    disp([CalFileName{f} ': Kax = ' num2str(avCal.kappaAX_list(f),'%1.3f') ','...
                          ' Kbx = ' num2str(avCal.kappaBX_list(f),'%1.3f') ','...
                          ' Aax = ' num2str(avCal.alphaAX_list(f),'%4.0f') ','...
                          ' Abx = ' num2str(avCal.alphaBX_list(f),'%4.0f') ]);
    end
    disp( '----[ Mean ]------------------------------------------------------');
    disp(['    kappaAX = ' num2str(avCal.kappaAX,'%1.3f') ' pN/nm' ' (+/- ' num2str(100*avCal.kappaAX_std/avCal.kappaAX,'%2.1f') '%)']); 
    disp(['    kappaBX = ' num2str(avCal.kappaBX,'%1.3f') ' pN/nm' ' (+/- ' num2str(100*avCal.kappaBX_std/avCal.kappaBX,'%2.1f') '%)']); 
    disp(['    alphaAX = ' num2str(avCal.alphaAX,'%4.0f') ' nm/NV' ' (+/- ' num2str(100*avCal.alphaAX_std/avCal.alphaAX,'%2.1f') '%)']); 
    disp(['    alphaBX = ' num2str(avCal.alphaBX,'%4.0f') ' nm/NV' ' (+/- ' num2str(100*avCal.alphaBX_std/avCal.alphaBX,'%2.1f') '%)']); 
    disp( '------------------------------------------------------------------');
    
    cal = avCal; %for saving
    uisave('cal',[analysisPath filesep 'avCal.mat']);
end