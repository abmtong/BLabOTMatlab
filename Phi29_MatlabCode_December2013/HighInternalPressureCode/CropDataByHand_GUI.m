function CropDataByHand_GUI(fcn)

if (nargin==0)
   fcn = 0;
end
    
switch fcn
    case 0 
    hold on; zoom on;

    button1 = uicontrol('Style', 'PushButton', 'Units','Normalized',...
                        'Position',[.1 .95 .15 .03],...
                        'String','Set Left Boundary','FontSize',8,...
                        'CallBack','CropDataByHand_GUI(1)');

    button2 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15 .95 .15 .03],...
                        'String','Set Right Boundary','FontSize',8,'CallBack',...
                        'CropDataByHand_GUI(2)');
                    
    button3 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*2 .95 .15 .03],...
                        'String','Apply Boundaries','FontSize',8,'CallBack',...
                        'CropDataByHand_GUI(3)');
                    
    button4 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*3 .95 .11 .03],...
                        'String','Save Index','FontSize',8,'CallBack',...
                        'CropDataByHand_GUI(4)');
                    
    button5 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*3+.11 .95 .11 .03],...
                        'String','Zoom','FontSize',8,'CallBack',...
                        'CropDataByHand_GUI(5)');
                    
    button6 = uicontrol('Style', 'PushButton','Units','normalized',...
                        'Position',[.1+.15*3+.11*2 .95 .11 .03],...
                        'String','Pan','FontSize',8,'CallBack',...
                        'CropDataByHand_GUI(6)');
    global Boundaries;
    Boundaries.Left        = [];
    Boundaries.LeftHandle  = [];
    Boundaries.Right       = [];
    Boundaries.RightHandle = [];

    case 1 %Define the left boundary
        global Boundaries;
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ishandle(Boundaries.LeftHandle)
               delete(Boundaries.LeftHandle);
            end
            YLim=get(gca,'YLim');
            Boundaries.LeftHandle = plot(xi*[1 1],YLim,'w:');
            Boundaries.Left       = xi; 
            but=0;
        end

   case 2 %define right boundary
        global Boundaries;
        but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ishandle(Boundaries.RightHandle)
               delete(Boundaries.RightHandle);
            end
            YLim=get(gca,'YLim');
            Boundaries.RightHandle = plot(xi*[1 1],YLim,'w:');
            Boundaries.Right       = xi; 
            but=0;
        end
        
    case 3 %apply boundaries
        global Boundaries PhageTrace
        %look through the data to figure out what the Y-axis limits should be for properly scaled display
        IndexLB = find(PhageTrace.MergedFiltTime>Boundaries.Left, 1,'first'); %the index of the first point belonging to the crop-selection
        IndexRB = find(PhageTrace.MergedFiltTime<Boundaries.Right,1,'last');  %the index of the last point belonging to the crop-selection
        
        Boundaries.Top    = max(PhageTrace.MergedFiltContour(IndexLB:IndexRB)); %limits for the Yaxis
        Boundaries.Bottom = min(PhageTrace.MergedFiltContour(IndexLB:IndexRB));
                
        RangeX = Boundaries.Right-Boundaries.Left; %the duration of the useful portion of the trace
        RangeY = Boundaries.Top-Boundaries.Bottom; %the extent of the useful portion of the trace

        set(gca,'XLim',[Boundaries.Left-0.1*RangeX    Boundaries.Right+0.1*RangeX]);
        set(gca,'YLim',[Boundaries.Bottom-0.1*RangeY  Boundaries.Top+0.1*RangeY]);
        
    case 4 %Save The Boundary Data
        global Boundaries PhageTrace
        IndexFolder = [PhageTrace.TracePath filesep 'CropFiles' filesep];
        if ~isdir(IndexFolder); %if the folder does not exist
            mkdir(IndexFolder);%create the folder
        end
        
        SaveFile = [IndexFolder PhageTrace.TraceFile(6:end-4) '.crop'];
        if exist(SaveFile,'file') %if this index file already exists
            %ask if you want to overwrite the old index file
            Option = questdlg('There already exists an event index file for this trace. Do you want to overwrite it?','Warning !');
            if strcmp(Option,'Yes') %overwrite the file
                FID = fopen(SaveFile,'w');
                fprintf(FID, '%f \n', Boundaries.Left);
                fprintf(FID, '%f \n', Boundaries.Right);
                fclose(FID);
                disp(['Crop successfuly saved for ' PhageTrace.TraceFile]);
                disp('--------------------------------------------');
                close gcf;
            else
                disp(['DID NOT save crop index for ' PhageTrace.TraceFile]);
            end
        else
                FID = fopen(SaveFile,'w');
                fprintf(FID, '%f \n', Boundaries.Left);
                fprintf(FID, '%f \n', Boundaries.Right);
                fclose(FID);
                disp(['Crop successfuly saved for ' PhageTrace.TraceFile]);
                disp('--------------------------------------------');
                close gcf;
        end
    case 5 %zoom on
        zoom on;
    case 6 %pan on
        pan on;
    end
end