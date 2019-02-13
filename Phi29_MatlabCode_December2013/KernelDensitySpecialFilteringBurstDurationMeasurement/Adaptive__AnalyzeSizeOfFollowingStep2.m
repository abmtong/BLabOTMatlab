function [Single10bpCycle TwoStep10bpCycle TwoStep20bpCycle ThreeStep20bpCycle ThreeStep30bpCycle IncompleteCycles NewDistribution] = Adaptive__AnalyzeSizeOfFollowingStep2(FC,Bursts)
%This algorith first analyzes the previous and following bursts for those
%that do not lie in the 10 bp bin (8.75-11.25).

%    global analysisPath; % reads where are the files
   
    % To run this program you should run before BurstSize_SummarizeResults to do the
    % step finding analysis. It would recover all the validated dwells
    % Initializes all the arrays
    %Bursts.Size=Bursts;
    IsThisACompleteCycle=[];
    ThisWasAlreadyCount=zeros(length(Bursts));
    
    % this section asks what type of motor this is. If it is a WT motor
    % would plot everything in blue color, if it is a mutant, then it would plot
    % everything in red color. 
    prompt = {'If this is the WT motor type W. If this is the mutant motor type M'};
    TypeOfMotor = 'Input';
    num_lines = 1;
    def = {'W'}; 
    answer = inputdlg(prompt,TypeOfMotor,num_lines,def);
    if strcmp(answer,'W')==1
        lColor=[0 0 1];
    elseif strcmp(answer,'M')==1
        lColor=[1 0 0];
    end
    TempBursts=Bursts.Size;
    %DwellsBefore=Bursts.DurationDwellBefore;
    %DwellsAfter=Bursts.DurationDwellAfter;
    
    
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
    ThreeStep20bpCycle=[];
    ThreeStep20bpDDB=[];
    ThreeStep20bpDDA=[];
    ThreeStep30bpCycle=[];
    ThreeStep30bpDDB=[];
    ThreeStep30bpDDA=[];
    IncompleteCycles=[];
    IncompleteDDB=[];
    IncompleteDDA=[];
    NewDistribution=[];
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
        %ThisBurstDDB=DwellsBefore(k);
        %ThisBurstDDA=DwellsAfter(k);
        
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
            
            
            if ThisBurst >= 8.75 && ThisBurst <= 11.25 % Is this a single step 10 bp burst?
                    IsThisACompleteCycle(k)=1; % Marks a single event (value 1) cycle and it was completed
                    ThisWasAlreadyCount(k)=1;  % Marks this step was seen already
                    Single10bpCycle=[Single10bpCycle ThisBurst]; % Includes this step in the vector single10bp
                    %Single10bpDDB=[Single10bpDDB DwellsBefore(k)]; % Includes the dwell in the vector Single10bpDDB
                    %Single10bpDDA=[Single10bpDDA DwellsAfter(k)]; % Includes the dwell in the vector Single10bpDDA
                    NewDistribution=[NewDistribution ThisBurst]; % Includes the dwell in the vector NewDistribution as completed cycle
                    
            elseif (ThisBurst+NextBurst) >= 8.75 && (ThisBurst+NextBurst) <= 11.25 % Is this part of a two step 10 bp burst? 
                    TwoStep10bpCycle=[TwoStep10bpCycle ThisBurst NextBurst];  % Includes this step in the vector TwoStep10bp
                    %TwoStep10bpDDB=[TwoStep10bpDDB DwellsBefore(k)];     % Includes the dwell in the vector TwoStep10bpDDB      
                    %TwoStep10bpDDA=[TwoStep10bpDDA DwellsAfter(k)];      % Includes the dwell in the vector TwoStep10bpDDB 
                    NewDistribution=[NewDistribution ThisBurst+NextBurst]; %Includes the sum as the new entry in the NewDistribution Vector
                    IsThisACompleteCycle(k)=2;   % Marks this as part of a multiple event (value 1) cycle and it was completed 
                    ThisWasAlreadyCount(k)=1;  % This burst was already seen
                    IsThisACompleteCycle(k+1)=2; % Marks this as part of a multiple event (value 1) cycle and it was completed 
                    ThisWasAlreadyCount(k+1)=1;  % This burst was already seen
                    
             elseif (ThisBurst+NextBurst) >= 18.24 && (ThisBurst+NextBurst) <= 21.76
                    
                 if NextBurst<8.75 && NextNextBurst<8.75 && [(NextBurst+NextNextBurst >= 8.75) && (NextBurst+NextNextBurst <= 11.25)]
                            IsThisACompleteCycle(k)=0;
                            IncompleteCycles=[IncompleteCycles ThisBurst];
                            TwoStep10bpCycle=[TwoStep10bpCycle NextBurst NextNextBurst];
                            NewDistribution=[NewDistribution ThisBurst NextBurst+NextNextBurst];
                            ThisWasAlreadyCount(k)=1;
                            ThisWasAlreadyCount(k+1)=1;
                            IsThisACompleteCycle(k+1)=2;
                            ThisWasAlreadyCount(k+2)=1;
                            IsThisACompleteCycle(k+2)=2;
                            
                    else                       
                    TwoStep20bpCycle=[TwoStep20bpCycle ThisBurst NextBurst];
                    NewDistribution=[NewDistribution (ThisBurst+NextBurst)/2 (ThisBurst+NextBurst)/2];
                    IsThisACompleteCycle(k)=2;
                    ThisWasAlreadyCount(k)=1;
                    IsThisACompleteCycle(k+1)=2;
                    ThisWasAlreadyCount(k+1)=1;
                    end;
                elseif (ThisBurst+NextBurst+NextNextBurst) >= 17.85 && (ThisBurst+NextBurst+NextNextBurst) <= 22.15
                    if NextBurst <= 8.75 && NextBurst >= 11.25
                    ThreeStep20bpCycle=[ThreeStep20bpCycle ThisBurst NextBurst NextNextBurst];
                    NewDistribution=[NewDistribution (ThisBurst+NextBurst+NextNextBurst)/2 (ThisBurst+NextBurst+NextNextBurst)/2];
                    IsThisACompleteCycle(k)=3;
                    ThisWasAlreadyCount(k)=1;
                    IsThisACompleteCycle(k+1)=3;
                    ThisWasAlreadyCount(k+1)=1;
                    IsThisACompleteCycle(k+2)=3;
                    ThisWasAlreadyCount(k+2)=1;
                    else
                        IsThisACompleteCycle(k)=0;
                        IncompleteCycles=[IncompleteCycles ThisBurst];
                        %NewDistribution=[NewDistribution ThisBurst];
                    end
                    
                    elseif (ThisBurst+NextBurst) >= 27.85 && (ThisBurst+NextBurst) <= 32.15
                    if NextBurst <= 8.75 && NextBurst >= 11.25
                    ThreeStep30bpCycle=[ThreeStep30bpCycle ThisBurst NextBurst NextNextBurst];
                    NewDistribution=[NewDistribution (ThisBurst+NextBurst+NextNextBurst)/3 (ThisBurst+NextBurst+NextNextBurst)/3 (ThisBurst+NextBurst+NextNextBurst)/3];
                    IsThisACompleteCycle(k)=3;
                    ThisWasAlreadyCount(k)=1;
                    IsThisACompleteCycle(k+1)=3;
                    ThisWasAlreadyCount(k+1)=1;
                    IsThisACompleteCycle(k+2)=3;
                    ThisWasAlreadyCount(k+2)=1;
                    else
                        IsThisACompleteCycle(k)=0;
                        IncompleteCycles=[IncompleteCycles ThisBurst];
                        %NewDistribution=[NewDistribution ThisBurst];
                        
                    end
                else
                    IsThisACompleteCycle(k)=0;
                    ThisWasAlreadyCount(k)=1;
                    IncompleteCycles=[IncompleteCycles ThisBurst];
                    %NewDistribution=[NewDistribution ThisBurst];
           end
                  
        end
        
       counterFC=counterFC+1;
       if counterFC==FC(NumberFC)
           counterFC=0;
           NumberFC=NumberFC+1;
       end    
    end
    
    PercentageFinalCompletedCycles=[length(NewDistribution)-length(IncompleteCycles)]/length(NewDistribution)
    
    x=[0:1:20];
    %close all;
    l=hist(Bursts, x);
    %l=l./sum(l);
    new=hist(NewDistribution,x);
   % new=new./sum(new);
    a=hist(Single10bpCycle,x);
    PercentageComplete=sum(a)/sum(l)
    ePercentage=PercentageComplete*sqrt((1/(sum(a)*sqrt(length(a))))^2+(1/(sum(l)*sqrt(length(l))))^2)
    b=hist(TwoStep10bpCycle,x);
    %b=b./sum(b);
    PercentageTwo10=sum(b)/sum(l)
    c=hist(TwoStep20bpCycle,x);
    PercentageTwo20=sum(c)/sum(l)
    %c=c./sum(c);
    d=hist(ThreeStep20bpCycle,x);
    PercentageThree20=sum(d)/sum(l)
    %d=d./sum(d);
    e=hist(ThreeStep30bpCycle,x);
    PercentageThree30=sum(e)/sum(l)
    %e=e./sum(e);
    f=hist(IncompleteCycles,x);
    PercentageIncomplete=sum(f)/sum(l)
    %f=f./sum(f);
    figure;
    %display(new);
    Percentages= [PercentageComplete PercentageTwo10 PercentageTwo20 PercentageThree20 PercentageThree30 PercentageIncomplete];
    
    plot(x,new,'LineWidth',4,'Color',[0.5 0.5 0.5])
    hold on;
    plot(x,l,'LineWidth',4,'Color','b')
    hold on;
    plot(x,a,'LineWidth',4,'Color',[0 0.749019622802734 0.749019622802734])
    hold on;
    plot(x,b,'LineWidth',4,'Color',[0 1 0])
    hold on;
    plot(x,c,'LineWidth',4,'Color',[1 0 1])
    hold on;
    plot(x,d,'LineWidth',4,'Color',[0.5 1 1])
    hold on;
    plot(x,e,'LineWidth',4,'Color',[1 1 0])
    hold on;
    plot(x,f,'LineWidth',4,'Color',[1 0 0])
    legend('NewDistribution','Burst Size Distribution','Single Step 10 bp',' Two Steps 10 bp','Two Steps 20 bp',' Three Steps 20 bp','Three Steps 30 bp','Steps did not complete cycle')
    
    figure1 = figure;
    
    axes1 = axes('Parent', figure1,...
    'XTickLabel',{'C','2*10','2*20','3*20','3*30','I'},...
    'XTick',[1 2 3 4 5 6]);
    box(axes1,'on');
    hold(axes1,'on');
    bar([1:1:6], Percentages)
    
  
end