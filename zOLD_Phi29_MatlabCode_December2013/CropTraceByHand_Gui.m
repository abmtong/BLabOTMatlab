function CropTraceByHand_Gui(fcn)

if (nargin==0)
   fcn = 0;
end
    
switch fcn
    case 0 
    hold on; zoom on;

    button1 = uicontrol('Style', 'PushButton', 'Units','Normalized',...
                        'Position',[.1 .95 .15 .03],...
                        'String','Set Left Boundary','FontSize',8,...
                        'CallBack','CropTraceByHand_Gui(1)');

    button2 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15 .95 .15 .03],...
                        'String','Set Right Boundary','FontSize',8,'CallBack',...
                        'CropTraceByHand_Gui(2)');
                    
    button3 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*2 .95 .15 .03],...
                        'String','Apply Boundaries','FontSize',8,'CallBack',...
                        'CropTraceByHand_Gui(3)');
                    
    button4 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*3 .95 .11 .03],...
                        'String','Save Index','FontSize',8,'CallBack',...
                        'CropTraceByHand_Gui(4)');
                    
    button5 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*3+.11 .95 .11 .03],...
                        'String','Zoom','FontSize',8,'CallBack',...
                        'CropTraceByHand_Gui(5)');
                    
    button6 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*3+.11*2 .95 .11 .03],...
                        'String','Pan','FontSize',8,'CallBack',...
                        'CropTraceByHand_Gui(6)');
        
    case 1 %Define the left boundary
        Trace = guidata(gcf);
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ishandle(Trace.Boundaries.LeftHandle)
               delete(Trace.Boundaries.LeftHandle);
            end
            YLim=get(gca,'YLim');
            Trace.Boundaries.LeftHandle = plot(xi*[1 1],YLim,'g:');
            Trace.Boundaries.Left       = xi; 
            guidata(gcf,Trace);
            but=0;
        end

   case 2 %define right boundary
        Trace = guidata(gcf);
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ishandle(Trace.Boundaries.RightHandle)
               delete(Trace.Boundaries.RightHandle);
            end
            YLim=get(gca,'YLim');
            Trace.Boundaries.RightHandle = plot(xi*[1 1],YLim,'r:');
            Trace.Boundaries.Right       = xi; 
            guidata(gcf,Trace);
            but=0;
        end
        
    case 3 %apply boundaries
        Trace = guidata(gcf); %get guidata
        %look through the data to figure out what the Y-axis limits should be for properly scaled display
        IndexLB = find(Trace.MergedTime > Trace.Boundaries.Left, 1,'first'); %the index of the first point belonging to the crop-selection
        IndexRB = find(Trace.MergedTime < Trace.Boundaries.Right,1,'last');  %the index of the last point belonging to the crop-selection
        
        Trace.Boundaries.Top    = max(Trace.MergedContour(IndexLB:IndexRB)); %limits for the Yaxis
        Trace.Boundaries.Bottom = min(Trace.MergedContour(IndexLB:IndexRB));
                
        RangeX = Trace.Boundaries.Right - Trace.Boundaries.Left;   %the duration of the useful portion of the trace
        RangeY = Trace.Boundaries.Top   - Trace.Boundaries.Bottom; %the extent of the useful portion of the trace

        set(gca,'XLim',[Trace.Boundaries.Left-0.1*RangeX    Trace.Boundaries.Right+0.1*RangeX]);
        set(gca,'YLim',[Trace.Boundaries.Bottom-0.1*RangeY  Trace.Boundaries.Top+0.1*RangeY]);
        guidata(gcf,Trace); %update guidata
        
    case 4 %Save The Boundary Data
        Trace = guidata(gcf); %get guidata
        IndexFolder = [Trace.FilePath filesep 'CropFiles' filesep];
        if ~isdir(IndexFolder); %if the folder does not exist
            mkdir(IndexFolder);%create the folder
        end
        
        SaveFile = [IndexFolder Trace.FileName(6:end-4) '.crop'];
        if exist(SaveFile,'file') %if this index file already exists
            %ask if you want to overwrite the old index file
            Option = questdlg('There already exists an event index file for this trace. Do you want to overwrite it?','Warning !');
            if strcmp(Option,'Yes') %overwrite the file
                FID = fopen(SaveFile,'w');
                fprintf(FID, '%f \n', Trace.Boundaries.Left);
                fprintf(FID, '%f \n', Trace.Boundaries.Right);
                fclose(FID);
                disp(['Crop saved for ' Trace.FileName]);
                disp('--------------------------------------------');
                close gcf;
            else
                disp(['DID NOT save crop index for ' Trace.FileName]);
            end
        else
                FID = fopen(SaveFile,'w');
                fprintf(FID, '%f \n', Trace.Boundaries.Left);
                fprintf(FID, '%f \n', Trace.Boundaries.Right);
                fclose(FID);
                disp(['Crop saved for ' Trace.FileName]);
                disp('--------------------------------------------');
                close gcf;
        end
    case 5 %zoom on
        zoom on;
    case 6 %pan on
        pan on;
    end
end