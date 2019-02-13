function PWD_SelectionGUI_PNP(fcn)
% This function allows you to load a phage trace, select a
% portion of it and calculate the corresponding PWD
%
% Gheorghe Chistol, 23 Nov 2010

if (nargin==0)
   fcn = 0;
   
   clear global LeftHandle;
   clear global RightHandle;
end

    
switch fcn
   case 0 % Create the figure
      %close all; figure;
      %fig = figure('Units','Normalized',...
      %'Position',[.4 .4 .3 .3],'NumberTitle',...
      %'off','Name','Example','MenuBar','none',...
      %'Resize','off','WindowStyle','Normal');
%x=1:.1:10;
%y=(x.^2).*sin(2*x);
%plot(x,y,'b.');
%subplot(2,1,1);
hold on
zoom on

      button1 = uicontrol('Style',...
      'PushButton', 'Position',[85 605 100 20],...
      'String','Set Left Boundary','CallBack',...
      'PWD_SelectionGUI_PNP(1)');
      button2 = uicontrol('Style',...
          'PushButton','Position',[85+105 605 100 20],...
          'String','Set Right Boundary','CallBack',...
          'PWD_SelectionGUI_PNP(2)');
      button3 = uicontrol('Style',...
          'PushButton','Position',[85+2*105 605 100 20],...
          'String','Compute PWD','CallBack',...
          'PWD_SelectionGUI_PNP(3)');
      button4 = uicontrol('Style',...
          'PushButton','Position',[85+3*105 605 100 20],...
          'String','Zoom','CallBack',...
          'PWD_SelectionGUI_PNP(4)');
      button5 = uicontrol('Style',...
          'PushButton','Position',[85+4*105 605 100 20],...
          'String','Pan','CallBack',...
          'PWD_SelectionGUI_PNP(5)');

      
      %button3 = uicontrol('Style',...
      %    'PushButton','Position',[85+2*85 395 80 20],...
      %    'String','Reset Zoom','CallBack',...
      %    'example(3)');
   case 1 % take care of button
      % do your stuff
      global LeftLimit;
      global LeftHandle;
      
              but = 1;
        while but == 1
            [xi,~,but] = ginput(1);
            if ~isempty(LeftHandle)
                delete(LeftHandle);
            end
            YLim=get(gca,'YLim');
            
            LeftHandle=plot(xi*[1 1],YLim,'k:');
            LeftLimit = xi; 
            %n = n+1;
            %xy(:,n) = [xi;yi];
            but=2;
        end
        zoom on
   case 2 % take care of anything else you
          % want, maybe specify a deletefcn
          % or something
          global RightLimit;
          global RightHandle;
          but = 1;
          while but == 1
            [xi,~,but] = ginput(1);
            if ~isempty(RightHandle)
                delete(RightHandle);
            end
            YLim=get(gca,'YLim');
            RightHandle=plot(xi*[1 1],YLim,'k:');
            RightLimit=xi;
            %n = n+1;
            %xy(:,n) = [xi;yi];
            but=2;
          end
          zoom on
    case 3
        global RightLimit LeftLimit;
        global FilteredTime FilteredLength BinPWD;
        IndLess = FilteredTime<RightLimit;
        IndMore = FilteredTime>LeftLimit;
        Index   = logical(IndLess.*IndMore);
        CropTime   = FilteredTime(Index);
        CropLength = FilteredLength(Index);
        
        
        %HistBins = min(CropLength):BinPWD:max(CropLength);
        [N, D]   = PWD_BruteForce(CropLength,BinPWD);
        %normalize the PWD;
        N=N/sum(N);
        figure;
        plot(D,N,'r'); 
        xlabel('Pairwise Distance (bp)');
        ylabel('Brute-Force Normalized PWD');
     %   zoom reset;
      %  zoom on;
    case 4
        zoom on;
    case 5
        pan on;
end