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
      ButtonIncreaseXLim = uicontrol('Style',...
      'PushButton', 'Position',[10 690 40 27],...
      'String','XLim+','CallBack',...
      'BurstSize__Main_GUI(''IncreaseXLim'')');   
      ButtonIncreaseYLim = uicontrol('Style',...
      'PushButton', 'Position',[10 660 40 27],...
      'String','YLim+','CallBack',...
      'BurstSize__Main_GUI(''IncreaseYLim'')');  
      ButtonLoadTrace = uicontrol('Style',...
      'PushButton', 'Position',[60 690 150 27],...
      'String','Load Phi29 Trace','CallBack',...
      'BurstSize__Main_GUI(''LoadTrace'')');
      ButtonUseFeedbackCycle = uicontrol('Style',...
      'PushButton', 'Position',[60 660 75 27],...
      'String','Use Cycle #:','CallBack',...
      'BurstSize__Main_GUI(''UseFeedbackCycle'')');
      ButtondecreaseCycleNumber = uicontrol('Style',...
      'PushButton', 'Position',[60+75+5 660 20 27],...
      'String','-','CallBack',...
      'BurstSize__Main_GUI(''DecreaseCycleNumber'')');  
      EditFeedbackCycle = uicontrol('Style',...
      'Edit', 'Position',[60+75+5+20 660 30 27],'Callback','BurstSize__Main_GUI(''UseFeedbackCycle'')',...
      'String','1','BackgroundColor','w','Tag','EditFeedbackCycle');
      ButtonIncreaseCycleNumber = uicontrol('Style',...
      'PushButton', 'Position',[60+75+5+20+30 660 20 27],...
      'String','+','CallBack',...
      'BurstSize__Main_GUI(''IncreaseCycleNumber'')');  
      ButtonPanPlot = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+10 690 50 27],...
      'String','Pan','CallBack',...
      'BurstSize__Main_GUI(''PanPlot'')');
      ButtonZoomPlot = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+10 660 50 27],...
      'String','Zoom','CallBack',...
      'BurstSize__Main_GUI(''ZoomPlot'')');
      ButtonSetLeftBound = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+50+20 690 90 27],...
      'String','Set Left Bound','CallBack',...
      'BurstSize__Main_GUI(''SetLeftBound'')');
      ButtonSetRightBound = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+50+20+90+5 690 90 27],...
      'String','Set Right Bound','CallBack',...
      'BurstSize__Main_GUI(''SetRightBound'')');
      ButtonApplyBoundaries = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+50+20 660 185 27],...
      'String','Apply Bounds & Get Kernel','FontWeight','bold','CallBack',...
      'BurstSize__Main_GUI(''ApplyBoundaries'')');
      TextFilterFrequency = uicontrol('Style',...
      'Text', 'Position',[80+120+20+50+20+90+5+90+20 685 120 27],...
      'HorizontalAlignment','right','String','Filter Frequency (Hz):  ',...
      'BackgroundColor',get(gcf,'Color'),'Tag','TextFilterFrequency'); % no need for callback function here
      EditFiltFreq = uicontrol('Style',...
      'Edit', 'Position',[80+120+20+50+20+90+5+90+20+120 690 35 27],...
      'String','100','BackgroundColor','w','Tag','EditFiltFreq');
      ButtonFindDwells = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+50+20+90+5+90+20 660 120 27],...
      'String','Find Dwell Number:','CallBack',...
      'BurstSize__Main_GUI(''FindDwells'')');
      EditNumberOfDwells = uicontrol('Style',...
      'Edit', 'Position',[80+120+20+50+20+90+5+90+20+120 660 35 27],'Callback','BurstSize__Main_GUI(''FindDwells'')',...
      'String','NaN','BackgroundColor','w','Tag','EditNumberOfDwells');
      ButtonSaveResults = uicontrol('Style',...
      'PushButton', 'Position',[80+120+20+50+20+90+5+90+20+120+35+20 660 100 57],...
      'String','Save Results','FontWeight','bold','CallBack',...
      'BurstSize__Main_GUI(''SaveResults'')');  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IncreaseXLim'
        axes(findobj(gcf,'Tag','PlotAxes'));%focus on the PlotAxes
        XLim = get(gca,'XLim');
        XLim(1) = XLim(1)-0.5; %move by half a second
        XLim(2) = XLim(2)+0.5;
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    case 'SetRightBound'
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        Trace = guidata(gcf);
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ~isnan(Trace.RightBoundH)
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
    case 'ApplyBoundaries' 
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
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
        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        Trace = guidata(gcf);
        %set the axis limits according to the selected left/right boundaries
        IndKeep = Trace.FiltTime>Trace.LeftBoundT & Trace.FiltTime<Trace.RightBoundT;
        T = Trace.FiltTime(IndKeep);
        Y = Trace.FiltContour(IndKeep);
        F = Trace.FiltForce(IndKeep);
        NumDwells = str2double(get(findobj(gcf,'Tag','EditNumberOfDwells'),'String')); %filter frequency
        Dwells = BurstSize_SIC_FindSteps(T,Y,F,NumDwells);
        Trace.Dwells = Dwells;
        %plot the new staircase plot
        delete(findobj(gcf,'Tag','StaircasePlot')); %delete the old filtered data plot
        h = plot(Dwells.StaircaseTime,Dwells.StaircaseContour,'-','Color','b','LineWidth',2); set(h,'Tag','StaircasePlot');
        %write the dwell durations labels
        delete(findobj(gca,'Tag','DwellDurationLabel'));%delete the old burst size labels
        delete(findobj(gca,'Tag','DwellLocationMark'));%delete the horizontal line marking dwell location
        for d=1:length(Dwells.DwellLocation)
            %first plot horizontal dashed lines to mark dwell location
            XLim = get(gca,'XLim');
            x = [Dwells.FinishTime(d) XLim(2)];
            y = Dwells.DwellLocation(d)*[1 1];
            h = plot(x,y,':k'); set(h,'Tag','DwellLocationMark');
            %now write the dwell duration next to each dwell
            %x = double(Dwells.FinishTime(d)+0.2);
            x = double(XLim(2)-0.12*range(XLim));
            y = double(Dwells.DwellLocation(d));
            DwellDuration = sprintf('%3.2f',Dwells.DwellDuration(d));
            h = text(x,y,[' ' DwellDuration ' s']); set(h,'Tag','DwellDurationLabel','FontWeight','bold','Color','b','BackgroundColor','w','EdgeColor','b','FontSize',12);

        end
        
        axes(findobj(gcf,'Tag','KernelAxes')); 
        %set(gca,'YGrid','on','YTick',sort(Trace.Dwells.DwellLocation));
        delete(findobj(gca,'Tag','BurstSizeLabel'));%delete the old burst size labels
        %diplay new burst size labels
        for d=1:length(Dwells.DwellLocation)-1
            x = -1.05;
            y = double(mean(Dwells.DwellLocation(d:(d+1))));
            BurstSize = sprintf('%2.2f',range(Dwells.DwellLocation(d:d+1)));
            h = text(x,y,[BurstSize ' bp']); set(h,'Tag','BurstSizeLabel','FontWeight','bold','FontSize',12);
        end
        %plot error bar marks at 2 sigma
        delete(findobj(gca,'Tag','ErrorBarMark'));
        for d=1:length(Dwells.DwellLocation)
            x = get(gca,'XLim');
            y = Dwells.DwellLocation(d)*[1 1];
            yerr = Dwells.DwellLocationErr(d)*[1 1];
            hold on;
            h = plot(x,y+yerr,'-','Color',0.8*[1 1 1]); set(h,'Tag','ErrorBarMark');
            h = plot(x,y,'-','Color',0*[1 1 1]); set(h,'Tag','ErrorBarMark');
            h = plot(x,y-yerr,'-','Color',0.8*[1 1 1]); set(h,'Tag','ErrorBarMark');
        end
        
        guidata(gcf,Trace);
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
        set(findobj(gcf,'Tag','TextFilterFrequency'),'BackgroundColor','w');
        
        SaveFolder = 'C:\aPhi29_Files\_ANALYSIS\HIP_Paper_2012\BurstSize_ManualIndexing_Results';
        if ~exist(SaveFolder,'dir')
            mkdir(SaveFolder);
        end
        SaveFileName = [Trace.FileName(6:end-4) '_FC' num2str(Trace.FeedbackCycle) '_' sprintf('%3.2f',Trace.LeftBoundT) 's-' sprintf('%3.2f',Trace.RightBoundT) 's' '.mat'];
        SaveImgName  = [Trace.FileName(6:end-4) '_FC' num2str(Trace.FeedbackCycle) '_' sprintf('%3.2f',Trace.LeftBoundT) 's-' sprintf('%3.2f',Trace.RightBoundT) 's' '.png'];
        save([SaveFolder filesep SaveFileName],'Trace');
        saveas(gcf,[SaveFolder filesep SaveImgName]);
        %change background color back to gray
        set(findobj(gcf,'Tag','TextFilterFrequency'),'BackgroundColor',get(gcf,'Color'));
        axes(findobj(gcf,'Tag','PlotAxes')); cla; 
        axes(findobj(gcf,'Tag','KernelAxes')); cla; set(gca,'XTick',[],'YTick',[]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
end
end