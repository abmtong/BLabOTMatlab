%function Data = z_TestingKernelDensityDiagnostics()
%the point is to be able to identify what traces have a large number of identifyable steps
% filter data to a set of frequencies and compare the KD for the same trace
close all;
    Bandwidth = 2500;
    FiltFreq = [100];
    Offset = 0.3; PeakThr = 1.2;
    global analysisPath;
    FileName = 'phage052311N70.mat';
%    FC = 36; %the feedback cycle of interest
    Tmin = 27.5; Tmax = 33;
    
    load([analysisPath filesep FileName]);
    for fc = 1:length(stepdata.time)
        t = stepdata.time{fc};
        Ind = t>Tmin & t<Tmax;
        if sum(Ind)>0
            y = stepdata.contour{fc};
            T = t(Ind);
            Y = y(Ind);
        end
    end
%     
    
    %% Compute Kernel Density
    Data = [];    
    for f = 1:length(FiltFreq)
        Data(f).FiltFreq = FiltFreq(f);
        Data(f).FiltFact = round(Bandwidth/FiltFreq(f));
        [Data(f).KernelGrid Data(f).KernelValue] = Adaptive_CalculateKernelDensity(Y,Data(f).FiltFact);
    end
    
    %% plot the KD on top of each Other

    figure; hold on;
    for f = 1:length(FiltFreq)
        plot(Data(f).KernelGrid,Data(f).KernelValue+Offset*(f-1));
        LocalMaxima = Adaptive_IdentifyLocalMaxima(Data(f).KernelGrid, Data(f).KernelValue, PeakThr);
        Data(f).LocalMaxima = LocalMaxima;
        ValidInd = LocalMaxima.LocalMaxInd(logical(LocalMaxima.IsValid));
        x = Data(f).KernelGrid(ValidInd);
        y = Data(f).KernelValue(ValidInd);
        plot(x,y+Offset*(f-1),'.k');
        
    end
    axis tight;
    XLim = get(gca,'XLim');
    x = max(XLim)+range(XLim)*0.01;
    for f = 1:length(FiltFreq)
    text(x,Offset*(f-1),[num2str(FiltFreq(f)) 'Hz']);
    end
    set(gca,'Box','on');
    set(gca,'YTick',[]);
    title([FileName]);
%end