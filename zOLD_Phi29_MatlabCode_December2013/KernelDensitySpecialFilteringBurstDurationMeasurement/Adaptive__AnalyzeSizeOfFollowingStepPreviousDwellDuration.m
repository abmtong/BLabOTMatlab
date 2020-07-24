function [BurstSize IncompleteDwells Index IncompleteCycles] = Adaptive__AnalyzeSizeOfFollowingStepPreviousDwellDuration(FC,Dwells,Bursts)
%This algorith first analyzes the previous and following bursts for those
%that do not lie in the 10 bp bin (8.75-11.25).

%    global analysisPath; % reads where are the files
   
    % To run this program you should run before BurstSize_SummarizeResults to do the
    % step finding analysis. It would recover all the validated dwells
    % Initializes all the arrays
    %Bursts.Size=Bursts;
    IsThisACompleteCycle=[];
    ThisWasAlreadyCount=zeros(length(Bursts.Size));
    
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
    TempDwells=Dwells.Duration;
    Single10bpCycle=[];
    TwoStep10bpCycle=[];
    TwoStep20bpCycle=[];
    ThreeStep20bpCycle=[];
    ThreeStep30bpCycle=[];
    IncompleteCycles=[];
    NewDistribution=[];
    BurstSize=[];
    IncompleteDwells=[];
    Index=[];
    
    counterFC=0;
    NumberFC=1;
    s=0; 
    
    
    
    for k=2:length(TempBursts)-1
        s=FC(NumberFC)-counterFC;
        ThisBurst=TempBursts(k);
        PreviousDwell=TempDwells(k-1);
        
        if ThisWasAlreadyCount(k)==0;  
            if s>2;
           % ThisBurst=TempBursts(k);
                NextBurst=TempBursts(k+1);
                if ~(k+2>length(TempBursts))
                NextNextBurst=TempBursts(k+2);
                end
            elseif s>1; 
                NextBurst=TempBursts(k+1);
                NextNextBurst=0;
            else
                NextBurst=0;
                NextNextBurst=0;
            end;
                
               if ThisBurst >= 8.75 && ThisBurst <= 11.25
                    IsThisACompleteCycle(k)=1;
                    ThisWasAlreadyCount(k)=1;
                    Single10bpCycle=[Single10bpCycle ThisBurst];
                    NewDistribution=[NewDistribution ThisBurst];
                    
                elseif (ThisBurst+NextBurst) >= 8.24 && (ThisBurst+NextBurst) <= 11.76 
                    TwoStep10bpCycle=[TwoStep10bpCycle ThisBurst NextBurst];
                    NewDistribution=[NewDistribution ThisBurst+NextBurst];
                    IsThisACompleteCycle(k)=2;
                    ThisWasAlreadyCount(k)=1;
                    IsThisACompleteCycle(k+1)=2;
                    ThisWasAlreadyCount(k+1)=1;
                    
                elseif (ThisBurst+NextBurst) >= 18.24 && (ThisBurst+NextBurst) <= 21.76
                    if NextBurst<8.75 && NextNextBurst<8.75 && [(NextBurst+NextNextBurst >= 8.75) && (NextBurst+NextNextBurst >= 11.25)]
                            IsThisACompleteCycle(k)=0;
                            IncompleteCycles=[IncompleteCycles ThisBurst];
                            IncompleteDwells=[IncompleteDwells PreviousDwell];
                            Index=[Index k];
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
                        Index=[Index k];
                        IncompleteDwells=[IncompleteDwells PreviousDwell];
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
                        Index=[Index k];
                        IncompleteDwells=[IncompleteDwells PreviousDwell];
                        IncompleteCycles=[IncompleteCycles ThisBurst];
                        %NewDistribution=[NewDistribution ThisBurst];
                        
                    end
                else
                    IsThisACompleteCycle(k)=0;
                    ThisWasAlreadyCount(k)=1;
                    Index=[Index k];
                    IncompleteDwells=[IncompleteDwells PreviousDwell];
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
    
    PercentageCompletedCycles=[length(NewDistribution)-length(IncompleteCycles)]/length(NewDistribution)
    
    x=[0:1:20];
    %close all;
    l=hist(Bursts.Size, x);
    %l=l./sum(l);
    new=hist(NewDistribution,x);
   % new=new./sum(new);
    a=hist(Single10bpCycle,x);
    %a=a./sum(a);
    b=hist(TwoStep10bpCycle,x);
    %b=b./sum(b);
    c=hist(TwoStep20bpCycle,x);
    %c=c./sum(c);
    d=hist(ThreeStep20bpCycle,x);
    %d=d./sum(d);
    e=hist(ThreeStep30bpCycle,x);
    %e=e./sum(e);
    f=hist(IncompleteCycles,x);
    %f=f./sum(f);
    figure;
    %display(new);
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
    
    
    
    
    
end