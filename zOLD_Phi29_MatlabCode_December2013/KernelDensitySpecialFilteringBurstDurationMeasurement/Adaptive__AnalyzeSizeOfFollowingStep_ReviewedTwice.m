function [ap, bp, cp, fp, I] = Adaptive__AnalyzeSizeOfFollowingStep_ReviewedTwice(NM,Threshold,FC,Bursts)
%This algorith first analyzes the previous and following bursts for those
%that do not lie in the 10 bp bin (8.75-11.25).

global analysisPath; % reads where are the files
   
    % To run this program you should run before BurstSize_SummarizeResults to do the
    % step finding analysis. It would recover all the validated dwells
    % Initializes all the arrays
    %Bursts.Size=Bursts;
    IsThisACompleteCycle=[];
    ThisWasAlreadyCount=zeros(length(Bursts.BurstSize));
    
    % this section asks what type of motor this is. If it is a WT motor
    % would plot everything in blue color, if it is a mutant, then it would plot
    % everything in red color. 
   % prompt = {'Type the number of molecule'};
   % NumberOfMotor = 'Input';
   % num_lines = 1;
   % def = {'00'}; 
   % answer = inputdlg(prompt,NumberOfMotor,num_lines,def);
   % NM=answer;
   % disp(NM)
   % if strcmp(answer,'W')==1
    %    lColor=[0 0 1];
    %elseif strcmp(answer,'M')==1
    %    lColor=[1 0 0];
    %end
    
    %Assigns the clases to temporl vectors so we don't haver to write the
    %whole variable all the time;
    
    TempBursts=Bursts.BurstSize;
    DwellsBefore=Bursts.DurationDwellBefore;
    DwellsAfter=Bursts.DurationDwellAfter;
    
    
    %-----------------------------------------------Initialize all the vectors
    Single10bpCycle=[];
    Single10bpDDB=[];
    Single10bpDDA=[];
    TwoStep10bpCycle=[];
    TwoStep10bpDDB=[];
    TwoStep10bpDDA=[];
    TwoStep20bpCycle=[];
    TwoStep20bpDDB=[];
    TwoStep20bpDDA=[];
    %ThreeStep20bpCycle=[];
    %ThreeStep20bpDDB=[];
    %ThreeStep20bpDDA=[];
    %ThreeStep30bpCycle=[];
    %ThreeStep30bpDDB=[];
    %ThreeStep30bpDDA=[];
    IncompleteCycles=[];
    IncompleteDDB=[];
    IncompleteDDA=[];
    NewDistribution=[];
    NewDwellDistribution=[];
    %-----------------------------------------------Initialize all the vectors
    
    %-------------------------------------Initialize values of counters
    counterFC=0;
    NumberFC=1;
    s=0;
    %-------------------------------------
   
    for k=1:length(TempBursts)-1
        s=FC(NumberFC)-counterFC;
        %Handles the current burst and dwells to a temporal variable
        ThisBurst=TempBursts(k);
        ThisBurstDDB=DwellsBefore(k);
        ThisBurstDDA=DwellsAfter(k);
        
if ThisWasAlreadyCount(k)==0; %this burst has not been seen before  
            %---------------------Assigns the values of the nextburst and nextnextburst depending on where in the cycle are we            
            %This what it does most if the time; s>2 for most of the cycle
            if s>2;
            % ThisBurst=TempBursts(k);
                NextBurst=TempBursts(k+1);  %Checks the value of the next burst
                if ~(k+2>length(TempBursts)) %Checks we are not at the end of the vector
                NextNextBurst=TempBursts(k+2); % assigns the value of the next next burst
                end
            %We are reaching the end of the cycle
            elseif s==1; 
                NextBurst=TempBursts(k+1);
                NextNextBurst=0;
            else % this burst is the last in this cycle (s=0);
                NextBurst=0;
                NextNextBurst=0;
            end;
            %------------------------------------------------Finishes assignignt those values    
            
            %------------------------------------------------Checks what tipe of cycle does this burst belongs to
            
            
    if ThisBurst >= 8.75 && ThisBurst <= 11.25 % Is this a single step 1*10 bp burst?
             IsThisACompleteCycle(k)=1; % Marks a single event (value 1) cycle and it was completed
             ThisWasAlreadyCount(k)=1;  % Marks this step was seen already
             Single10bpCycle=[Single10bpCycle ThisBurst]; % Includes this step in the vector single10bp
             Single10bpDDB=[Single10bpDDB DwellsBefore(k)]; % Includes the dwell in the vector Single10bpDDB
             Single10bpDDA=[Single10bpDDA DwellsAfter(k)]; % Includes the dwell in the vector Single10bpDDA
             NewDistribution=[NewDistribution ThisBurst]; % Includes the dwell in the vector NewDistribution as completed cycle
                    
    elseif (ThisBurst+NextBurst) >= 8.75 && (ThisBurst+NextBurst) <= 11.25 % Is this part of a two step a single 1*10 bp burst? 
         if ThisWasAlreadyCount(k)==0; 
              if DwellsBefore(k+1)<=Threshold % checks whether the dwell in between the two steps is fast
                TwoStep10bpCycle=[TwoStep10bpCycle ThisBurst NextBurst];  % Includes this step in the vector TwoStep10bp
                TwoStep10bpDDB=[TwoStep10bpDDB DwellsBefore(k) DwellsBefore(k+1)];     % Includesthis bursts' dwell & the next one in the vector TwoStep10bpDDB      
                TwoStep10bpDDA=[TwoStep10bpDDA DwellsAfter(k) DwellsAfter(k+1)];      % Includes this bursts' dwell & the next one in the vector TwoStep10bpDDB 
                NewDistribution=[NewDistribution ThisBurst+NextBurst]; %Includes the sum as the new entry in the NewDistribution Vector
                NewDwellDistribution=[NewDwellDistribution DwellsAfter(k)+DwellsAfter(k+1)];
                IsThisACompleteCycle(k)=2;   % Marks this as part of a multiple event (value 2) cycle and it was completed 
                ThisWasAlreadyCount(k)=1;  % This burst was already seen
                IsThisACompleteCycle(k+1)=2; % Marks this as part of a multiple event (value 2) cycle and it was completed 
                ThisWasAlreadyCount(k+1)=1;  % This burst was already seen
              else
                IncompleteCycles=[IncompleteCycles ThisBurst];
                %NewDistribution=[NewDistribution ThisBurst];
                IncompleteDDB=[IncompleteDDB DwellsBefore(k)];
                IncompleteDDA=[IncompleteDDA DwellsAfter(k)]; 
                IsThisACompleteCycle(k)=0; % this cycle was incomplete
                ThisWasAlreadyCount(k)=1; % this step was already seen
            end
         end
                    
    elseif (ThisBurst+NextBurst) >= 18.75 && (ThisBurst+NextBurst) <= 21.25 %Are this and the following burst 2*10 bp bursts together?
        if ThisWasAlreadyCount(k)==0;           
             if DwellsBefore(k+1)<=Threshold % checks whether the dwell in between the two steps is fast
             TwoStep20bpCycle=[TwoStep20bpCycle ThisBurst NextBurst];
             TwoStep20bpDDB=[TwoStep20bpDDB DwellsBefore(k) DwellsBefore(k+1)];    % Includes this bursts' dwell & the next one in the vector TwoStep10bpDDB      
             TwoStep20bpDDA=[TwoStep20bpDDA DwellsAfter(k) DwellsAfter(k+1)];      % Includes this bursts' dwell & the next one in the vector TwoStep10bpDDB 
             NewDistribution=[NewDistribution (ThisBurst+NextBurst)/2 (ThisBurst+NextBurst)/2]; % Splits the 20 bp burst as two 10 bp in the new distribution
             NewDwellDistribution=[NewDwellDistribution (DwellsAfter(k)+DwellsAfter(k+1))/2 (DwellsAfter(k)+DwellsAfter(k+1))/2];
             IsThisACompleteCycle(k)=2;  % Marks this as part of a two step (value 2) cycle and it was completed 
             ThisWasAlreadyCount(k)=1;   % This burst was already seen
             IsThisACompleteCycle(k+1)=2;  % Marks this as part of a two step (value 2) cycle and it was completed 
             ThisWasAlreadyCount(k+1)=1;  % This burst was already seen
             end
        else
            IncompleteCycles=[IncompleteCycles ThisBurst];
            %NewDistribution=[NewDistribution ThisBurst];
            IncompleteDDB=[IncompleteDDB DwellsBefore(k)];
            IncompleteDDA=[IncompleteDDA DwellsAfter(k)]; 
            IsThisACompleteCycle(k)=0; % this cycle was incomplete
            ThisWasAlreadyCount(k)=1; % this step was already seen
        end
        
             
              %             if NextBurst<8.75 && NextNextBurst<8.75 && [(NextBurst+NextNextBurst >= 8.75) && (NextBurst+NextNextBurst <= 11.25)] %I do not know why I wote this
              %
              %                       IsThisACompleteCycle(k)=0;
              %                      IncompleteCycles=[IncompleteCycles ThisBurst];
              %                      TwoStep10bpCycle=[TwoStep10bpCycle NextBurst NextNextBurst];
              %                      NewDistribution=[NewDistribution ThisBurst NextBurst+NextNextBurst];
              %                      ThisWasAlreadyCount(k)=1;
              %                      ThisWasAlreadyCount(k+1)=1;
              %                      IsThisACompleteCycle(k+1)=2;
              %                      ThisWasAlreadyCount(k+2)=1;
              %                      IsThisACompleteCycle(k+2)=2;
                            
              %              else                       
                    
              %              end;
   %---------------------------------This section seemed not to be good
              %
   %  elseif (ThisBurst+NextBurst+NextNextBurst) >= 18.75 && (ThisBurst+NextBurst+NextNextBurst) <= 21.25 %Are this and the following two steps 2*10 bp bursts together?
   %    if ThisWasAlreadyCount(k)==0;             
   %         if NextBurst <= 8.75 || NextBurst >= 11.25 % Checks the next cycle is not a complete one, otherwise marks
   %             ThreeStep20bpCycle=[ThreeStep20bpCycle ThisBurst NextBurst NextNextBurst];
   %             NewDistribution=[NewDistribution (ThisBurst+NextBurst+NextNextBurst)/2 (ThisBurst+NextBurst+NextNextBurst)/2];
   %             NewDwellDistribution=[NewDwellDistribution (DwellsAfter(k)+DwellsAfter(k+1))/2 (DwellsAfter(k)+DwellsAfter(k+1))/2];
   %             ThreeStep20bpDDB=[ThreeStep20bpDDB DwellsBefore(k) DwellsBefore(k+1) DwellsBefore(k+2)];    % Includes this bursts' dwell & the next two in the vector TwoStep10bpDDB      
   %             ThreeStep20bpDDA=[ThreeStep20bpDDA DwellsAfter(k) DwellsAfter(k+1) DwellsAfter(k+2)];      % Includes this bursts' dwell & the next two in the vector TwoStep10bpDDB 
   %             IsThisACompleteCycle(k)=3; % Marks this as part of a three step (value 3) cycle and it was completed 
   %             ThisWasAlreadyCount(k)=1;  % This burst was already seen
   %             IsThisACompleteCycle(k+1)=3; % Marks this as part of a three step (value 3) cycle and it was completed 
   %             ThisWasAlreadyCount(k+1)=1;  % This burst was already seen
   %             IsThisACompleteCycle(k+2)=3; % Marks this as part of a three step (value 3) cycle and it was completed 
   %             ThisWasAlreadyCount(k+2)=1;  % This burst was already seen
   %         else % seems like the cycle is complete, so checks this cycle as incomplete
   %             IsThisACompleteCycle(k)=0;
   %             IncompleteCycles=[IncompleteCycles ThisBurst];
                %NewDistribution=[NewDistribution ThisBurst];
   %             IncompleteDDB=[IncompleteDDB DwellsBefore(k)];
   %             IncompleteDDA=[IncompleteDDA DwellsAfter(k)];  
   %         end
   %    end              
 %   elseif (ThisBurst+NextBurst+NextNextBurst) >= 28.75 && (ThisBurst+NextBurst+NextNextBurst) <= 31.25 % Are this and the following two steps 3*10 bp burst? 
  %      if ThisWasAlreadyCount(k)==0;
  %                  if NextBurst <= 8.75 || NextBurst >= 11.25
  %                  ThreeStep30bpCycle=[ThreeStep30bpCycle ThisBurst NextBurst NextNextBurst];
  %                  NewDwellDistribution=[NewDwellDistribution (DwellsAfter(k)+DwellsAfter(k+1)+DwellsAfter(k+2))/3 (DwellsAfter(k)+DwellsAfter(k+1)+DwellsAfter(k+2))/3 (DwellsAfter(k)+DwellsAfter(k+1)+DwellsAfter(k+2))/3];
  %                  NewDistribution=[NewDistribution (ThisBurst+NextBurst+NextNextBurst)/3 (ThisBurst+NextBurst+NextNextBurst)/3 (ThisBurst+NextBurst+NextNextBurst)/3];
  %                  ThreeStep30bpDDB=[ThreeStep30bpDDB DwellsBefore(k) DwellsBefore(k+1) DwellsBefore(k+2)];    % Includes this bursts' dwell & the next two in the vector TwoStep10bpDDB      
  %              	ThreeStep30bpDDA=[ThreeStep30bpDDA DwellsAfter(k) DwellsAfter(k+1) DwellsAfter(k+2)];      % Includes this bursts' dwell & the next two in the vector TwoStep10bpDDB 
  %                  IsThisACompleteCycle(k)=3; % Marks this as part of a three step (value 3) cycle and it was completed 
  %                  ThisWasAlreadyCount(k)=1; % This burst was already seen
  %                  IsThisACompleteCycle(k+1)=3; % Marks this as part of a three step (value 3) cycle and it was completed 
  %                  ThisWasAlreadyCount(k+1)=1;  % This burst was already seen
  %                  IsThisACompleteCycle(k+2)=3; % Marks this as part of a three step (value 3) cycle and it was completed 
  %                  ThisWasAlreadyCount(k+2)=1; % This burst was already seen
  %                  else % seems like the cycle is complete, so checks this cycle as incomplete
  %                     IsThisACompleteCycle(k)=0;
  %                     IncompleteCycles=[IncompleteCycles ThisBurst];
                       %NewDistribution=[NewDistribution ThisBurst];
  %                     IncompleteDDB=[IncompleteDDB DwellsBefore(k)];
  %                     IncompleteDDA=[IncompleteDDA DwellsAfter(k)];   
  %                  end
  %      end
    else % if all the other cases filed, this must be an incomplete cycle.... 
        IsThisACompleteCycle(k)=0; % Marks this as an incomplete cycle(value 0)
        ThisWasAlreadyCount(k)=1; % This burst was already seen
        IncompleteCycles=[IncompleteCycles ThisBurst];
        IncompleteDDB=[IncompleteDDB DwellsBefore(k)];
        IncompleteDDA=[IncompleteDDA DwellsAfter(k)];
    end
                  
    end % Whatever was done until here is done only if the burst has not been seen before
        
       counterFC=counterFC+1; % Increases by one the counter within this FC, meaning 
       
       if counterFC==FC(NumberFC) % if the counter has reached the length of the FC size, it gows to the next FC
           counterFC=0; % re-starts the counte within FC
           NumberFC=NumberFC+1; % goes to the next FC
       end    
       
    end % finishes with the identification of what type of cycle is this
    
    %-----------------------------------------------this is all about plotting the results
   % PercentageFinalCompletedCycles=[length(Bursts.BurstSize)-length(NewDistribution)]/length(Bursts.BurstSize);
    
    x=[0:1:20];
    %close all;
    l=hist(Bursts.BurstSize, x); % raw distribution
    new=hist(NewDistribution,x); % Hypothetical 10 bp cycles
     
    a=hist(Single10bpCycle,x); % single step 1*10 bp (e.g. 10bp)
    ap=sum(a)/sum(l); %PercentageComplete
    
    b=hist(TwoStep10bpCycle,x); % two step 1*10 bp (e.g. 5bp + 5bp)
    bp=sum(b)/sum(l); %PercentageTwo10
    
    c=hist(TwoStep20bpCycle,x); %two step 2*20 bp (e.g. 5bp + 15bp)
    cp=sum(c)/sum(l); %PercentageTwo20
    
 %    d=hist(ThreeStep20bpCycle,x); % three step 2*20 (e.g. 2.5bp + 12.5bp + 5bp)
 %   dp=sum(d)/sum(l); %PercentageThree20
    
 %   e=hist(ThreeStep30bpCycle,x); % three step 3*30 (e.g. 15 bp + 7.5bp + 7.5bp)
 %   ep=sum(e)/sum(l); %PercentageThree30
    
    f=hist(IncompleteCycles,x); % all incomplete cycle (e.g. 2.5bp, 5bp, 7.5bp)
    fp=sum(f)/sum(l); %PercentageIncomplete
    
    Percentages= [ap bp cp fp];
   
    %close all;
    
    %ND=NewDwellDistribution;
    I=IncompleteCycles;
    
    %plotting histograms with the different burst composition distributions
    figure1 = figure;
    set(figure1, 'Position',[10,400,500,350]);
    plot(x,new,'LineWidth',4,'Color',[0.5 0.5 0.5])
    hold on;
    plot(x,l,'LineWidth',4,'Color','b')
    hold on;
    plot(x,a,'LineWidth',4,'Color',[0 0.749019622802734 0.749019622802734])
    hold on;
    plot(x,b,'LineWidth',4,'Color',[0 1 0])
    hold on;
    plot(x,c,'LineWidth',4,'Color',[1 0 1])
%    hold on;
%    plot(x,d,'LineWidth',4,'Color',[0.5 1 1])
%    hold on;
%    plot(x,e,'LineWidth',4,'Color',[1 1 0])
    hold on;
    plot(x,f,'LineWidth',4,'Color',[1 0 0])
    legend('NewDistribution','Burst Size Distribution','Single Step 10 bp',' Two Steps 10 bp','Two Steps 20 bp',' Three Steps 20 bp','Three Steps 30 bp','Steps did not complete cycle')
    
    %Ploting percentages of cycles 
    figure2 = figure;
    set(figure2, 'Position',[530,400,500,350]);
    axes1 = axes('Parent', figure2,...
    'XTickLabel',{'1*10','2*10','2*20','I'},...
    'XTick',[1 2 3 4]);
    box(axes1,'on');
    hold(axes1,'on');
    bar([1:1:4], Percentages)
    
    %Plotting 
    figure3 = figure;
    set(figure3, 'Position',[1050,300,500,500]);
    subplot(2,2,1), plot(Single10bpCycle,Single10bpDDB);
    r=corrcoef(Single10bpCycle,Single10bpDDB);
    correlation=num2str(r(2));
    lll=['1*10bp = ' correlation];
    legend(lll);
    
    subplot(2,2,2), plot(TwoStep10bpCycle,TwoStep10bpDDB);
    r=corrcoef(TwoStep10bpCycle,TwoStep10bpDDB);
    correlation=num2str(r(2));
    lll=['2*10bp = ' correlation];
    legend(lll);
    
    subplot(2,2,3), plot(TwoStep20bpCycle,TwoStep20bpDDB);
    r=corrcoef(TwoStep20bpCycle,TwoStep20bpDDB);
    correlation=num2str(r(2));
    lll=['2*20bp = ' correlation];
    legend(lll);
    
%    subplot(3,2,4), plot(ThreeStep20bpCycle,ThreeStep20bpDDB);
%    r=corrcoef(ThreeStep20bpCycle,ThreeStep20bpDDB);
%    correlation=num2str(r(2));
%    lll=['3*20bp = ' correlation];
%    legend(lll);
    
%    subplot(3,2,5), plot(ThreeStep30bpCycle,ThreeStep30bpDDB);
%    r=corrcoef(ThreeStep30bpCycle,ThreeStep30bpDDB);
%    correlation=num2str(r(2));
%    lll=['3*30bp = ' correlation];
%    legend(lll);
    
    subplot(2,2,4), plot(IncompleteCycles,IncompleteDDB);
    r=corrcoef(IncompleteCycles,IncompleteDDB);
    correlation=num2str(r(2));
    lll=['I = ' correlation];
    legend(lll);
    
    %---------------------------------------------------------------------------
  
    ImageFolderName=[analysisPath filesep 'BurstDurationCompositionAnalysis']; %Save the current figure as an image in a folder for later 

    if ~isdir(ImageFolderName);
        mkdir(ImageFolderName);%create the directory
    end
    
    %NM=num2str(answer);
    
    %ImageFileName = [ImageFolderName filesep 'HistogramBurstComposition_Molecule_' num2str(NM)];
    %saveas(figure1,ImageFileName,'png'); 
    %saveas(figure1,ImageFileName,'fig'); 
    
    %ImageFileName = [ImageFolderName filesep 'CompositionPercentages_Molecule_' num2str(NM)];
    %saveas(figure2,ImageFileName,'png'); 
    %saveas(figure2,ImageFileName,'fig'); 
    
    %ImageFileName = [ImageFolderName filesep 'CorrelationsDDBAndComposition_Molecule_' num2str(NM)];
    %saveas(figure3,ImageFileName,'png'); 
    %saveas(figure3,ImageFileName,'fig'); 
    
end