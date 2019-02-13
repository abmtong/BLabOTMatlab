function StepFinding_ATPgS_SuperimposeKernels_AfterData
    % Load ***_ResultsKV_BeforeExtra_Valid files and load them one by one
    % add their CumulativeValidData together to get the final Kernel
    % Density Function
    %
    % Gheorghe Chistol, 18 July 2011
    
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    [DataFile DataPath] = uigetfile([ [analysisPath filesep ] '*_ResultsKV_AfterExtra_AfterValid.mat'], 'Please select After Data files','MultiSelect', 'on');
    if ~iscell(DataFile)
        temp=DataFile; clear DataFile; DataFile{1} = temp;
    end    
    
    X = -30:0.2:60;
    Y = 0*X;
    ClusterPeak = [];
    figure('Units','normalized','Position',[0.0037    0.2448    0.5564    0.6628]); 
    hold on;
    mf = 1; %movie frame index
    
    for f=1:length(DataFile)
        clear CumulativeValidData; %to avoid contamination from the previous round
        load([DataPath filesep DataFile{f}],'CumulativeValidData');
        
        for i=1:length(CumulativeValidData)
            CurrData = CumulativeValidData(i);
            Anchor1  = CurrData.KernelX(CurrData.Peak1Ind);
            Anchor2  = CurrData.KernelX(CurrData.Peak2Ind);
            Offset   = (Anchor1+Anchor2)/2-5;

            x    = CurrData.KernelX-Offset;
            y    = CurrData.KernelY;
            temp = interp1(x,y,X,'linear',0);
            Y    = Y+temp;
            
            h=plot(x,y,'b','LineWidth',2);
            h2 = plot(x(CurrData.OffsetInd)*[1 1],[0 1.1],'r','LineWidth',2);
            ClusterPeak(end+1) = x(CurrData.OffsetInd);
            set(gca,'YLim',[0 1.1])
            set(gca,'XLim',[-30 50]);
            set(gca,'Box','on','Layer','top');
            xlabel('Contour Length Distance (bp)');
            ylabel('Probability Density');
            
            pause(.1);
            M(mf) = getframe;
            mf = mf+1;
            delete(h2);
            set(h,'Color',0.7*[1 1 1],'LineWidth',1);
        end
    end    
    
    
    figure('Units','normalized','Position',[0.0037    0.059    0.4927    0.3906]); 
    hold on;
    area(X,Y,'FaceColor','y','LineStyle','none');
    plot(X,Y,'k','LineWidth',1.5);
    set(gca,'XGrid','on','Layer','top');
    set(gca,'XLim',[-30 50]);
    xlabel('Contour Length Distance (bp)');
    ylabel('Cumulative Kernel Density');
    set(gca,'YTick',[],'Box','on');
    title('Real Data, [ATP]=25uM');
end

