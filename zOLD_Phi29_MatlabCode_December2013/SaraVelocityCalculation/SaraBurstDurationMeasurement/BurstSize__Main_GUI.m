function BurstSize__Main_GUI(Instructions)
% This function allows you to load a phage trace, select a
% portion of it and calculate the corresponding PWD
%
% Gheorghe Chistol, 23 Nov 2010

%set the phage file to figure('Name','phage021210N50.mat') 
%use the figure and axes 'UserData' to store shared data (i.e. all data)
%use strings for "Control" variable
%use guidata(H,Data) to store and Data=guidata(H) to retrieve data
switch Instructions
   case 'Initialize' 
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.0067    0.9405    0.0296    0.0402],...
                'String','XLim+','CallBack','BurstSize__Main_GUI(''IncreaseXLim'')');   
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.0067    0.8958    0.0296    0.0402],...
                'String','YLim+','CallBack','BurstSize__Main_GUI(''IncreaseYLim'')');  
            
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.0437    0.9405    0.1111    0.0402],...
                'String','Load Phi29 Trace','CallBack','BurstSize__Main_GUI(''LoadTrace'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.0067    0.79    0.0511    0.0402],...
                'String','No.Dwells','CallBack','BurstSize__Main_GUI(''ComputeNumberofDwells'')');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.0067    0.74    0.0259    0.0402],...
               'Callback','BurstSize__Main_GUI(''ComputeNumberofDwells'')',...
               'String',2.3,'BackgroundColor','w','Tag','EditPenaltyFactor');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.0437    0.8958    0.0556    0.0402],...
                'String','Use Cycle #:','CallBack','BurstSize__Main_GUI(''UseFeedbackCycle'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.1030    0.8958    0.0148    0.0402],...
                'String','-','CallBack','BurstSize__Main_GUI(''DecreaseCycleNumber'')');  
      uicontrol('Style','Edit','Units','Normalized','Position',[0.1178    0.8958    0.0222    0.0402],...
                'String','1','BackgroundColor','w','Tag','EditFeedbackCycle',...
                'Callback','BurstSize__Main_GUI(''UseFeedbackCycle'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.1400    0.8958    0.0148    0.0402],...
                'String','+','CallBack','BurstSize__Main_GUI(''IncreaseCycleNumber'')'); 
            
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.1696    0.9405    0.0370    0.0402],...
                'String','Pan','CallBack','BurstSize__Main_GUI(''PanPlot'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.1696    0.8958    0.0370    0.0402],...
                'String','Zoom','CallBack','BurstSize__Main_GUI(''ZoomPlot'')');
            
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.2141    0.9405    0.0667    0.0402],...
                'String','Set Left Bound','CallBack','BurstSize__Main_GUI(''SetLeftBound'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.2844    0.9405    0.0667    0.0402],...
                'String','Set Right Bound','CallBack','BurstSize__Main_GUI(''SetRightBound'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.2141    0.8958    0.1370    0.0402],...
                'String','Apply Bounds & Get Kernel','FontWeight','bold',...
                'CallBack','BurstSize__Main_GUI(''ApplyBoundaries'')');
            
      uicontrol('Style','Text','Units','Normalized','Position',[0.3659    0.9330    0.0889    0.0402],...
                'HorizontalAlignment','right','String','Filter Frequency (Hz):  ',...
                'BackgroundColor',get(gcf,'Color'),'Tag','TextFilterFrequency');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.4548    0.9405    0.0259    0.0402],...
                'String','100','BackgroundColor','w','Tag','EditFiltFreq');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.3659    0.8958    0.0889    0.0402],...
                'String','Find Dwell Number:','CallBack','BurstSize__Main_GUI(''FindDwells'')');
      ND = uicontrol('Style','Edit','Units','Normalized','Position',[0.4548    0.8958    0.0259    0.0402],...
               'Callback','BurstSize__Main_GUI(''FindDwells'')',...
               'String', 'NaN' ,'BackgroundColor','w','Tag','EditNumberOfDwells');

      uicontrol('Style','Text','Units','Normalized','Position',[0.4874    0.9330    0.0889    0.0402],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','MinTestBurstSize (bp): ','Tag','TextMinBurstSize');
      uicontrol('Style','Edit','Units','Normalized','Position',[ 0.5763    0.9405    0.0259    0.0402],...
                'String','8.0','BackgroundColor','w','Tag','EditMinBurstSize'); 
  
      uicontrol('Style','Text','Units','Normalized','Position',[0.4874    0.8884    0.0889    0.0402],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','MaxTestBurstSize (bp): ','Tag','TextMaxBurstSize');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.5763    0.8958    0.0259    0.0402],...
                'String','12.0','BackgroundColor','w','Tag','EditMaxBurstSize');  
  
      uicontrol('Style','Text','Units','Normalized','Position',[0.6052    0.9330    0.0741    0.0402],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','TestBurstIncr (bp): ','Tag','TextBurstIncr');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.6807    0.9405    0.0259    0.0402],...
                'String','0.2','BackgroundColor','w','Tag','EditBurstIncr'); 
  
      uicontrol('Style','Text','Units','Normalized','Position',[0.6052    0.8884    0.0741    0.0402],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','GridOffsetIncr (bp): ','Tag','TextGridOffsetIncr');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.6807    0.8958    0.0259    0.0402],...
                'String','0.2','BackgroundColor','w','Tag','EditGridOffsetIncr');  
            
      uicontrol('Style','Text','Units','Normalized','Position',[0.7970    0.9568    0.0741    0.0223],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','OptimalBurst (bp): ','Tag','TextOptimalBurst');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.8704    0.9539    0.0259    0.0268],...
                'String','10.0','BackgroundColor','w','Tag','EditOptimalBurst'); 
            
      uicontrol('Style','Text','Units','Normalized','Position',[0.7970    0.9256    0.0741    0.0223],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','OptimalOffset (bp): ','Tag','TextOptimalOffset');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.8704    0.9226    0.0259    0.0268],...
                'String','0','BackgroundColor','w','Tag','EditOptimalOffset');
            
      uicontrol('Style','Text','Units','Normalized','Position',[0.7933    0.8899    0.0778    0.0268],...
                'HorizontalAlignment','right','BackgroundColor',get(gcf,'Color'),...
                'String','SearchWindow (%): ','Tag','TextSearchWindow');
      uicontrol('Style','Edit','Units','Normalized','Position',[0.8704    0.8914    0.0259    0.0268],...
                'String','30','BackgroundColor','w','Tag','EditSearchWindow');
            
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.7141    0.9405    0.0741    0.0402],...
                'String','Run WordWrap','CallBack','BurstSize__Main_GUI(''RunWordWrap'')');
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.7141    0.8958    0.0741    0.0402],...
                'String','Plot Akaike Score','CallBack','BurstSize__Main_GUI(''PlotAkaikeScore'')');
            
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.9133    0.9405    0.0741    0.0402],...
                'String','Identify Bursts','CallBack','BurstSize__Main_GUI(''IdentifyBursts'')');  
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.9133    0.8958    0.0741    0.0402],...
                'String','Save Results','FontWeight','bold','CallBack','BurstSize__Main_GUI(''SaveResults'')'); 
      uicontrol('Style','PushButton','Units','Normalized','Position',[0.0067    0.8535    0.0650    0.0400],...
                'String','MergeDwells','CallBack','BurstSize__Main_GUI(''MergeDwells'')');      
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IncreaseXLim'
        axes(findobj(gcf,'Tag','PlotAxes'));%focus on the PlotAxes
        XLim = get(gca,'XLim');
        XLim(1) = XLim(1)-0.1; %move by half a second
        XLim(2) = XLim(2)+0.1;
        set(gca,'XLim',XLim);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IncreaseYLim'
        axes(findobj(gcf,'Tag','PlotAxes'));%focus on the PlotAxes
        YLim = get(gca,'YLim');
        YLim(1) = YLim(1)-10; %move by one second
        YLim(2) = YLim(2)+10;
        set(gca,'YLim',YLim); 
        set(findobj(gcf,'Tag','KernelAxes'),'YLim',YLim); %change the axis limits for the kernel plot too
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    case 'DecreaseCycleNumber'
        H=findobj(gcf,'Tag','EditFeedbackCycle');
        CurrentFC = round(str2double(get(H,'String')));
        set(H,'String',num2str(CurrentFC-1));
        BurstSize__Main_GUI('UseFeedbackCycle');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    case 'IncreaseCycleNumber'   
        H=findobj(gcf,'Tag','EditFeedbackCycle');
        CurrentFC = round(str2double(get(H,'String')));
        set(H,'String',num2str(CurrentFC+1));
        BurstSize__Main_GUI('UseFeedbackCycle');        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    case 'LoadTrace'
        %organize data into structure "Trace", to use with "guidata"
        set(findobj(gcf,'Tag','EditFeedbackCycle'),'String','1'); 

        global analysisPath;
        [Trace.FileName, Trace.FilePath] = uigetfile([analysisPath filesep 'phage*.mat'], 'MultiSelect','off','Pick a Phi29 Trace');
        temp = load([Trace.FilePath filesep Trace.FileName],'stepdata');
        %Trace.FilePath
        PhageData   = temp.stepdata; clear temp;
        set(gcf,'Name',Trace.FileName);
        set(gcf,'UserData',PhageData); %save the raw data to the 'UserData'
        Trace.FeedbackCycle = NaN;
        Trace.Bandwidth   = 2500; %in Hz
        Trace.FiltFreq    = str2double(get(findobj(gcf,'Tag','EditFiltFreq'),'String')); %filter frequency
        Trace.FiltFact    = round(Trace.Bandwidth/Trace.FiltFreq); %filter factor
        Trace.FiltFactLow = round(Trace.Bandwidth/Trace.FiltFreqPeaks)
        Trace.Time        = NaN; %initialize the structure that stores data
        Trace.Force       = NaN; %the data for a particular feedback cycle
        Trace.Contour     = NaN;
        Trace.FiltTime    = NaN;
        Trace.FiltForce   = NaN;
        Trace.FiltContour = NaN;
        Trace.LeftBoundT  = NaN; %time of the left boundary
        Trace.RightBoundT = NaN;
        Trace.LeftBoundH  = NaN; %hande of the left bundary line
        Trace.RightBoundH = NaN;
        Trace.KernelGrid  = [];
        Trace.KernelValue = [];
        axes(findobj(gcf,'Tag','PlotAxes')); cla; hold on;
        axes(findobj(gcf,'Tag','KernelAxes')); cla; hold on;
        
        guidata(gcf,Trace); %save the trace data as guidata
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    case 'ComputeNumberofDwells'
        Trace = guidata(gcf);
        %set the axis limits according to the selected left/right boundaries
        IndKeep = Trace.FiltTime>Trace.LeftBoundT & Trace.FiltTime<Trace.RightBoundT;
        T = Trace.FiltTime(IndKeep);
        Y = Trace.FiltContour(IndKeep);
        F = Trace.FiltForce(IndKeep);
        PenaltyFactor = str2double(get(findobj(gcf,'Tag','EditPenaltyFactor'),'String'));
        DwellInd = Adaptive_FindSteps(Y,PenaltyFactor);
        Dwells = BurstSize_SIC_FindSteps_OrganizeResults(T,Y,F,DwellInd);
        Dwells.FiltT = T; %save the vector used
        Dwells.FiltY = Y;
        Dwells.FiltF = F;
        Trace.Dwells = Dwells;
        guidata(gcf,Trace);
        NumDwells = length(Dwells.StartInd)-1;
        set(findobj('Tag','EditNumberOfDwells'),'String',num2str(NumDwells))
        BurstSize__Main_GUI_PlotNewDwellStaircase(Dwells);
  
        % %filter frequency
        %figure;
        %plot(Trace.FiltTime, Trace.FiltContour, 'r');
        %hold on; 
        %plot(Dwells.StaircaseTime,Dwells.StaircaseContour,'b');
        % Trace = guidata(gcf);
        % T = Trace.FiltTime;
        % Y = Trace.FiltContour;
        % F = Trace.FiltForce;
        % Dwells = Adaptive_FindSteps(Y,3);   
         
        % Dwells.FiltT = T; %save the vector used
        % Dwells.FiltY = Y;
        % Dwells.FiltF = F;
        % Trace.Dwells = Dwells;
        % BurstSize__Main_GUI_PlotNewDwellStaircase(Dwells);
        % guidata(gcf,Trace);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    case 'UseFeedbackCycle'
        FC = round(str2double(get(findobj(gcf,'Tag','EditFeedbackCycle'),'String'))); %to be sure it's an integer number
        axes(findobj(gcf,'Tag','KernelAxes')); cla; set(gca,'YTick',[],'XTick',[]);
        PhageData = get(gcf,'UserData');
        Trace     = guidata(gcf);
        
        if FC>=1 && FC<=length(PhageData.time) && ~isnan(FC)
            Trace.FeedbackCycle = FC; 
            Trace.Time     = PhageData.time{FC};
            Trace.Force    = PhageData.force{FC};
            Trace.Contour  = PhageData.contour{FC};
            axes(findobj(gcf,'Tag','PlotAxes')); cla; hold on; %focus on the PlotAxes, clear it, hold plots
            h = plot(Trace.Time,Trace.Contour,'-','Color',0.85*[1 1 1]); set(h,'Tag','RawDataPlot'); axis tight;
            
            Trace.FiltFreq = str2double(get(findobj(gcf,'Tag','EditFiltFreq'),'String')); %filter frequency
            Trace.FiltFact = round(Trace.Bandwidth/Trace.FiltFreq); %filter factor            
            Trace.FiltTime    = BurstSize_FilterAndDecimate(Trace.Time,   Trace.FiltFact);
            Trace.FiltForce   = BurstSize_FilterAndDecimate(Trace.Force,  Trace.FiltFact);
            Trace.FiltContour = BurstSize_FilterAndDecimate(Trace.Contour,Trace.FiltFact);
            h = plot(Trace.FiltTime,Trace.FiltContour,'-','Color','k'); set(h,'Tag','FiltDataPlot');
            
            Trace.LeftBoundT  = NaN; %time of the left boundary
            Trace.RightBoundT = NaN;
            Trace.LeftBoundH  = NaN; %hande of the left bundary line
            Trace.RightBoundH = NaN;
            
            guidata(gcf,Trace); %save as guidata
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    case 'PanPlot'
        axes(findobj(gcf,'Tag','PlotAxes'));%focus on the PlotAxes
        pan on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    case 'ZoomPlot'
        axes(findobj(gcf,'Tag','PlotAxes'));%focus on the PlotAxes
        zoom on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    case 'SetLeftBound'
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        Trace = guidata(gcf);
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ~isnan(Trace.LeftBoundH)
                delete(Trace.LeftBoundH);
            end
            InitialYLim=get(gca,'YLim');
            Trace.LeftBoundT  = xi;
            Trace.LeftBoundH = plot(xi*[1 1],[min(Trace.Contour)-range(Trace.Contour) max(Trace.Contour)+range(Trace.Contour)],'b:','LineWidth',2);
            set(gca,'YLim',InitialYLim); %in case plotting the boundary changed the axis 
            but=2;
        end
        guidata(gcf,Trace);
        zoom on;
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'SetRightBound'
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        Trace = guidata(gcf);
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ishandle(Trace.RightBoundH)
                delete(Trace.RightBoundH);
            end
            InitialYLim=get(gca,'YLim');
            Trace.RightBoundT  = xi;
            Trace.RightBoundH = plot(xi*[1 1],[min(Trace.Contour)-range(Trace.Contour) max(Trace.Contour)+range(Trace.Contour)],'r:','LineWidth',2);
            set(gca,'YLim',InitialYLim); %in case plotting the boundary changed the axis 
            but=2;
        end
        guidata(gcf,Trace);
        zoom on;      
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'RunWordWrap'
        addpath('..\WordWrap'); %to use the wordwrap code
        set(findobj(gcf,'Tag','EditOptimalBurst'),'String','NaN');
        set(findobj(gcf,'Tag','EditOptimalOffset'),'String','NaN');
        pause(.1);
        axes(findobj(gcf,'Tag','PlotAxes')); hold on;
        Trace = guidata(gcf);
        MinTestBurst      = str2double(get(findobj(gcf,'Tag','EditMinBurstSize'),'String'));
        MaxTestBurst      = str2double(get(findobj(gcf,'Tag','EditMaxBurstSize'),'String'));
        TestBurstIncr     = str2double(get(findobj(gcf,'Tag','EditBurstIncr'),'String'));
        GridOffsetIncr    = str2double(get(findobj(gcf,'Tag','EditGridOffsetIncr'),'String'));

        [BestBurstSize, BestGridOffset, ~ , AkaikeScore, AkaikeTestBurst] = WordWrap_TestBurstSize(...
                           Trace.Dwells.DwellLocation,Trace.Dwells.DwellDuration,...
                           MinTestBurst,MaxTestBurst,TestBurstIncr,GridOffsetIncr);
        Trace.Dwells.BestBurstSize   = BestBurstSize;
        Trace.Dwells.BestGridOffset  = BestGridOffset;
        Trace.Dwells.AkaikeScore     = AkaikeScore;
        Trace.Dwells.AkaikeTestBurst = AkaikeTestBurst;

        set(findobj(gcf,'Tag','EditOptimalBurst'),'String',num2str(BestBurstSize));
        set(findobj(gcf,'Tag','EditOptimalOffset'),'String',num2str(BestGridOffset));
        guidata(gcf,Trace);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'PlotAkaikeScore'
        Trace = guidata(gcf);
        figure;
        plot(Trace.Dwells.AkaikeTestBurst,Trace.Dwells.AkaikeScore,'.m');
        xlabel('Test Burst Size (bp)');
        ylabel('Akaike Score');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'ApplyBoundaries' 
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        delete(findobj(gca,'Tag','DotPlot'));
        delete(findobj(gca,'Tag','LinePlot'));
        delete(findobj(gca,'Tag','DwellPlot'));
        Trace = guidata(gcf);
        CurrFiltFreq = str2double(get(findobj(gcf,'Tag','EditFiltFreq'),'String')); %filter frequency

        %if the current filter frequency is different from the one on file, update the filtered data plot and filtered data
        if CurrFiltFreq~=Trace.FiltFreq
            Trace.FiltFreq = CurrFiltFreq;
            Trace.FiltFact = round(Trace.Bandwidth/Trace.FiltFreq); %filter factor            
            Trace.FiltTime    = BurstSize_FilterAndDecimate(Trace.Time,   Trace.FiltFact);
            Trace.FiltForce   = BurstSize_FilterAndDecimate(Trace.Force,  Trace.FiltFact);
            Trace.FiltContour = BurstSize_FilterAndDecimate(Trace.Contour,Trace.FiltFact);
            delete(findobj(gcf,'Tag','FiltDataPlot')); %delete the old filtered data plot
            h = plot(Trace.FiltTime,Trace.FiltContour,'-','Color','k'); set(h,'Tag','FiltDataPlot'); %plot the new filtered data
            %plot the boxcar filtered data instead
            %BoxcarT = BurstSize_BoxcarFilter(Trace.Time,   Trace.FiltFact);
            %BoxcarY = BurstSize_BoxcarFilter(Trace.Contour,Trace.FiltFact);
            %h = plot(BoxcarT,BoxcarY,'-','Color','k'); set(h,'Tag','FiltDataPlot'); %plot the new filtered data
        end
        
        %set the axis limits according to the selected left/right boundaries
        IndKeep     = Trace.Time>Trace.LeftBoundT & Trace.Time<Trace.RightBoundT;
        CropTime    = Trace.Time(IndKeep);
        CropContour = Trace.Contour(IndKeep);
        DeltaCrop = 0.3; %how much extra to show for cropping
        TimeLim = [min(CropTime)-DeltaCrop*range(CropTime) max(CropTime)+DeltaCrop*range(CropTime)];
        DeltaCrop = 0;
        ContLim = [min(CropContour)-DeltaCrop*range(CropContour) max(CropContour)+DeltaCrop*range(CropContour)];
        axis([TimeLim ContLim]);
        guidata(gcf,Trace); %update the gui data
        
        %Calculate the kernel density and Plot it on the 'KernelAxes'
        [Trace.KernelGrid Trace.KernelValue] = BurstSize_CalculateKernelDensity(CropContour,Trace.FiltFact);
        axes(findobj(gcf,'Tag','KernelAxes')); cla; hold on; %focus on the KernelAxes, hold plots clear old figures
        h=plot(-Trace.KernelValue, Trace.KernelGrid,'m','LineWidth',2); set(h,'Tag','KernelPlot');
        set(gca,'XLim',[-1.1 0]);
        set(gca,'YLim',ContLim);
        legend(Trace.FileName,'Location','N');
        guidata(gcf,Trace); %update the gui data
        
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'FindDwells'
        Trace = guidata(gcf);
        %set the axis limits according to the selected left/right boundaries
        IndKeep = Trace.FiltTime>Trace.LeftBoundT & Trace.FiltTime<Trace.RightBoundT;
        T = Trace.FiltTime(IndKeep);
        Y = Trace.FiltContour(IndKeep);
        F = Trace.FiltForce(IndKeep);
        NumDwells = str2double(get(findobj(gcf,'Tag','EditNumberOfDwells'),'String')); %filter frequency
        Dwells = BurstSize_SIC_FindSteps(T,Y,F,NumDwells);
        Dwells.FiltT = T; %save the vector used
        Dwells.FiltY = Y;
        Dwells.FiltF = F;
        Trace.Dwells = Dwells;
        BurstSize__Main_GUI_PlotNewDwellStaircase(Dwells);
        guidata(gcf,Trace);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    case 'SaveResults'
        Trace = guidata(gcf);
        %retain only the raw data pertaining to the region of interest to reduce file size
        IndKeep = Trace.Time>=Trace.LeftBoundT & Trace.Time<=Trace.RightBoundT;
        Trace.Time    = Trace.Time(IndKeep);
        Trace.Force   = Trace.Force(IndKeep);
        Trace.Contour = Trace.Contour(IndKeep);
        IndKeep = Trace.FiltTime>=Trace.LeftBoundT & Trace.FiltTime<=Trace.RightBoundT;
        Trace.FiltTime    = Trace.FiltTime(IndKeep);
        Trace.FiltForce   = Trace.FiltForce(IndKeep);
        Trace.FiltContour = Trace.FiltContour(IndKeep);
        
        %for a little change the background to white, then back to gray
        set(findobj(gcf,'Style','Text'),'BackgroundColor','w');
        
        SaveFolder = [Trace.FilePath filesep 'SaraBurstDurationAnalysis'];
        if ~exist(SaveFolder,'dir')
            mkdir(SaveFolder);
        end
        SaveFileName = ['BurstDur_' Trace.FileName(6:end-4) '_FC' num2str(Trace.FeedbackCycle) '_' sprintf('%3.2f',Trace.LeftBoundT) 's-' sprintf('%3.2f',Trace.RightBoundT) 's' '.mat'];
        save([SaveFolder filesep SaveFileName],'Trace'); %save the data
        
        Extension = 'png';
        SaveImgName  = ['BurstDur_' Trace.FileName(6:end-4) '_FC' num2str(Trace.FeedbackCycle) '_' sprintf('%3.2f',Trace.LeftBoundT) 's-' sprintf('%3.2f',Trace.RightBoundT) 's' '.' Extension];
        BurstSize__Main_GUI_ScreenCapture([SaveFolder filesep SaveImgName],Extension);%use the screenprint for faster image saving
        %saveas(gcf,[SaveFolder filesep SaveImgName]);
        
        %change background color back to gray
        set(findobj(gcf,'Style','Text'),'BackgroundColor',get(gcf,'Color'));
        axes(findobj(gcf,'Tag','PlotAxes')); cla; 
        axes(findobj(gcf,'Tag','KernelAxes')); cla; set(gca,'XTick',[],'YTick',[]);
        delete(findobj(gcf,'Tag','PWDAxes'));%delete the old burst size labels
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IdentifyBursts'
        addpath('C:\aPhi29_Files\Phi29_MatlabCode\WordWrap'); %to use the wordwrap code
        Trace = guidata(gcf);

%         >> Trace.Dwells
%             StartInd: [1 10 14 28 33 47 57 77 81 98 103 112 117 145 149 163 166]
%            FinishInd: [9 13 27 32 46 56 76 80 97 102 111 116 144 148 162 165 182]
%            StartTime: [1x17 double]
%           FinishTime: [1x17 double]
%        DwellDuration: [1x17 double]
%        DwellLocation: [1x17 single]
%     DwellLocationErr: [1x17 single]
%           DwellForce: [1x17 single]
%       SizeStepBefore: [1x17 double]
%        SizeStepAfter: [1x17 single]
%        StaircaseTime: [1x34 double]
%     StaircaseContour: [1x34 double]
%                FiltT: [1x182 double]
%                FiltY: [1x182 single]
%                FiltF: [1x182 single]
%                 
        OptimalBurst      = str2double(get(findobj(gcf,'Tag','EditOptimalBurst'),'String'));
        OptimalOffset     = str2double(get(findobj(gcf,'Tag','EditOptimalOffset'),'String'));
        DwellSearchRegion = 0.01*str2double(get(findobj(gcf,'Tag','EditSearchWindow'),'String')); %in the main figure it's given in percent, we want it as a fraction

        ATPDwellInd = WordWrap_IdentifyDwellsBursts(...
                      Trace.Dwells.DwellLocation, Trace.Dwells.DwellDuration,...
                      OptimalBurst, OptimalOffset, DwellSearchRegion );

        axes(findobj(gcf,'Tag','PlotAxes')); hold on;
        delete(findobj(gca,'Tag','DwellPlot')); %any plot that denoted the location of the actual ATP-binding dwells
        for i=1:length(ATPDwellInd)
            d = ATPDwellInd(i);
            x = [Trace.Dwells.StartTime(d) Trace.Dwells.FinishTime(d)];
            y = Trace.Dwells.DwellLocation(d)*[1 1];
            plot(x,y,'r','LineWidth',3.5,'Tag','DwellPlot');
        end
        
        %now plot horizontal grid marks for the WordWrap method
        WordWrapGrid = (max(Trace.Dwells.DwellLocation)+OptimalOffset):-OptimalBurst:(min(Trace.Dwells.DwellLocation)-OptimalBurst);
        WordWrapGrid = WordWrapGrid(1:length(ATPDwellInd));
        set(gca,'YGrid','off','YTickMode','auto');
        XLim = get(gca,'XLim'); 
        for i=1:length(ATPDwellInd)
            d = ATPDwellInd(i);
            x = [XLim(1) Trace.Dwells.StartTime(d)];
            y = WordWrapGrid(i)*[1 1];
            plot(x,y,'--r','LineWidth',1,'Tag','DwellPlot');
        end
        
        Trace.Dwells.ATPDwellInd   = ATPDwellInd;
        Trace.Dwells.OptimalBurst  = OptimalBurst;
        Trace.Dwells.OptimalOffset = OptimalOffset;
        Trace.Dwells.WordWrapGrid  = WordWrapGrid;
        Trace.Dwells.ATPBindingDwells = BurstSize__Main_GUI_SortATPBindingDwells(Trace.Dwells,ATPDwellInd); 
        
        %plot only the main dwells in the kernel axes
        axes(findobj(gcf,'Tag','KernelAxes')); hold on; 
        delete(findobj(gca,'Tag','BurstSizeLabel'));%delete the old burst size labels
        %diplay new burst size labels
        for i=1:length(ATPDwellInd)-1
            cd = ATPDwellInd(i); %current dwell
            nd = ATPDwellInd(i+1); %next dwell            
            x = -1.05; y = double(mean(Trace.Dwells.DwellLocation([cd nd])));
            BurstSize = sprintf('%2.2f',range(Trace.Dwells.DwellLocation([cd nd])));
            h = text(x,y,[BurstSize ' bp']); set(h,'Tag','BurstSizeLabel','FontWeight','bold','FontSize',12);
        end
        %plot dashed lines to denote the ATP-binding Dwells
        %delete(findobj(gcf,'Tag','DwellPlot'));
        delete(findobj(gcf,'Tag','ErrorBarMark'));
        for i=1:length(ATPDwellInd)
            d = ATPDwellInd(i);
            x = get(gca,'XLim'); y = Trace.Dwells.DwellLocation(d)*[1 1];
            h = plot(x,y,':','Color',0*[1 1 1]); set(h,'Tag','ErrorBarMark');
        end
        %-----------RemoveDwellDuration Labels--------------
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        delete(findobj(gca,'Tag','DwellDurationLabel'));%delete the old burst size labels
        delete(findobj(gca,'Tag','DwellLocationMark'));%delete the horizontal line marking dwell location
        for i=1:length(ATPDwellInd)
            d = ATPDwellInd(i); %first plot horizontal dashed lines to mark dwell location
            XLim = get(gca,'XLim');
            x = [Trace.Dwells.FinishTime(d) XLim(2)];
            y = Trace.Dwells.DwellLocation(d)*[1 1];
            h = plot(x,y,':r'); set(h,'Tag','DwellLocationMark');
            %now write the dwell duration next to each dwell
            %x = double(Dwells.FinishTime(d)+0.2);
            x = double(XLim(2)-0.12*range(XLim));
            y = double(Trace.Dwells.DwellLocation(d));
            DwellDuration = sprintf('%4.0f',1000*Trace.Dwells.DwellDuration(d));
            h = text(x,y,[' ' DwellDuration ' ms']); set(h,'Tag','DwellDurationLabel','FontWeight','bold',...
                          'Color','r','BackgroundColor','w','EdgeColor','r','FontSize',12);
        end
        
        %----Plot the burst Duration value--------------------
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        for b=1:length(Trace.Dwells.ATPBindingDwells.Burst.Duration)
            XLim = get(gca,'XLim');
            x = [Trace.Dwells.ATPBindingDwells.Burst.FinishTime(b) XLim(2)];
            y = Trace.Dwells.ATPBindingDwells.Burst.MeanLocation(b)*[1 1];
            %h = plot(x,y,':b'); set(h,'Tag','DwellLocationMark');
            %now write the bust duration next to each burst
            x = double(XLim(2)-0.12*range(XLim));
            y = double(Trace.Dwells.ATPBindingDwells.Burst.MeanLocation(b));
            BurstDuration = sprintf('%4.0f',1000*Trace.Dwells.ATPBindingDwells.Burst.Duration(b));
            h = text(x,y,[' ' BurstDuration ' ms']); set(h,'Tag','DwellDurationLabel','FontWeight','bold',...
                          'Color','b','BackgroundColor','none','EdgeColor','none','FontSize',10);
        end
        %-----------------------------------------------------
        delete(findobj(gcf,'Tag','PWDAxes'));%delete the old burst size labels
        PWDAxes = axes('Units','normalized','Position',[0.1007    0.1152    0.2630    0.2586],...
                       'Box','on','Layer','top','Tag','PWDAxes');
        xlabel('Distance (bp)'); ylabel('Amp (arb)');
        
        %Now plot the PWD on the same plot for reference
        addpath('..\PairwiseDistanceDistribution');
        PwdRawInd = Trace.Time>Trace.LeftBoundT & Trace.Time<Trace.RightBoundT;
        L  = Pwd_BoxcarFilter(Trace.Contour(PwdRawInd), Trace.FiltFact);
        HistBinWidth = Trace.Dwells.OptimalBurst/20;
        HistogramBins  = min(L):HistBinWidth:max(L); %define the bins for the data, later used to calculate the PWD
        [Trace.Dwells.PwdAmplitude, Trace.Dwells.PwdDistance] = Pwd_ComputePairwiseDistanceDistribution(L,HistogramBins);
        plot(Trace.Dwells.PwdDistance,Trace.Dwells.PwdAmplitude,'m','LineWidth',2);
        set(gca,'XLim',[0 5*Trace.Dwells.OptimalBurst]);
        n = Trace.Dwells.PwdAmplitude;
        d = Trace.Dwells.PwdDistance;
        set(gca,'YLim',[0 1.1*max(n(d>0.5*Trace.Dwells.OptimalBurst & d<5*Trace.Dwells.OptimalBurst))]);
        set(gca,'YTick',[]);
        legend('Pairwise Distribution','Location','se');
        
        guidata(gcf,Trace);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'MergeDwells'
        
        if isempty(findobj(gcf,'Tag','StaircasePlot'))
            return; %there is no staircase dwell plot to work with
        end
        axes(findobj(gcf,'Tag','PlotAxes')); %bring focus to the main plot
        MergeRectangle = getrect(gca); 
        %MergeRectangle(1) start time (in sec)
        %MergeRectangle(2) start location (in bp) from the lower left corner
        %MergeRectangle(3) rectangle width (in sec)
        %MergeRectangle(4) rectangle height (in bp)
        %In order to merge dwells they have to be consecutive, and to be
        %fully enclosed in the selection rectangle
        % > Dwells.StartTime && Dwells.FinishTime <
        % > Dwells.Location < %within the rectangle  
        Trace = guidata(gcf);
        MinT = MergeRectangle(1);
        MaxT = MergeRectangle(1)+MergeRectangle(3);
        MinL = MergeRectangle(2);
        MaxL = MergeRectangle(2)+MergeRectangle(4);
        IndTime     = Trace.Dwells.StartTime>MinT & Trace.Dwells.FinishTime<MaxT;
        IndLocation = Trace.Dwells.DwellLocation>MinL & Trace.Dwells.DwellLocation<MaxL;
        MergeInd = IndTime & IndLocation;
        %if there are more than 1 dwells in the MergeInd, and these dwells
        %are consecutive, merge them
        if sum(MergeInd)>1
            FirstMergeInd = find(MergeInd>0,1,'first');
            LastMergeInd  = find(MergeInd>0,1,'last');
            if (LastMergeInd-FirstMergeInd+1)==sum(MergeInd)
                %merge all dwells between FirstMergeInd and LastMergeInd
                %prepare the DwellInd structure for merging
                temp.StartInd  = Trace.Dwells.StartInd;
                temp.FinishInd = Trace.Dwells.FinishInd;
                temp.FinishInd(FirstMergeInd) = temp.FinishInd(LastMergeInd);
                RemoveInd = (FirstMergeInd+1):LastMergeInd;
                temp.StartInd(RemoveInd)  = [];
                temp.FinishInd(RemoveInd) = [];
                for d = 1:length(temp.StartInd)
                    DwellInd(d).Start  = temp.StartInd(d);
                    DwellInd(d).Finish = temp.FinishInd(d);
                end
                Dwells = BurstSize_SIC_FindSteps_OrganizeResults(Trace.Dwells.FiltT,Trace.Dwells.FiltY,Trace.Dwells.FiltF,DwellInd);
                Dwells.FiltT = Trace.Dwells.FiltT; 
                Dwells.FiltY = Trace.Dwells.FiltY;
                Dwells.FiltF = Trace.Dwells.FiltF;
                Trace.Dwells = Dwells; %replace the old dwells structure witht the new structure
                BurstSize__Main_GUI_PlotNewDwellStaircase(Trace.Dwells);
                guidata(gcf,Trace);
            end
        end        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
end