function [] = Adaptive__AnalyzeSizeOfFollowingStep()
%This algorith first analyzes the previous and following bursts for those
%that do not lie in the 10 bp bin (8.75-11.25).

    global analysisPath; % reads where are the files
    
    % To run this program you should run before Adaptive_Main to do the
    % step finding analysis. It would recover all the validated dwells.
    [OrderedDwells Dwell Index] = Adaptive_RecoverDwellCandidateAndIndex(); % loads dwell and index of validated dwells
    % Initializes all the arrays
    PreviousStep=[];
    NextStep=[];
    ThisStep=[];
    OneStep=[];
    CompletedCycle=[];
    
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

    num=length(OrderedDwells.Dwells);
    ThisStep=zeros(num);
    NextStep=zeros(num);
    PreviousStep=zeros(num);
    PreviousBurstUsed=zeros(num);
    NextBurstUsed=zeros(num);
    CompletedCycle=zeros(num);

    %Analyzes burst by burst what is the following and after burst size
    count=0;
    for i=2:(num-2) % starts counting in 2, so that there is always a previous burst
        if (OrderedDwells.Index(i-1)==1 && OrderedDwells.Index(i)==1 && OrderedDwells.Index(i+1)==1) % Checks there are at least three consecutive validated dwells, corresponding to at least two consecutive bursts.
           ThisStep(i)=abs(OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i));
           PreviousStep(i)=abs(OrderedDwells.Dwells(i)-OrderedDwells.Dwells(i-1));
           count=count+1; %Counts how many dwells were there with a consecutive dwell
           
           %now, it calculates whether the sum of the current and the
           %previous burst lies within the 10 bp bin, the burst is then
           %recorded only if it has not been taken into account previously
           if ((ThisStep(i)+ PreviousStep(i)>8.75 && ThisStep(i)+PreviousStep(i)<11.25)||(ThisStep(i)+ PreviousStep(i)>18.75 && ThisStep(i)+PreviousStep(i)<21.25))% the previous step either completes one complete cycle of 10 bp or two complete cycles of 10 bp (20 bp)
               if (NextBurstCompletedCycle(i-1)==0) % When this number is different than zero, it says that the current burst was already associated with another burst
                CompletedCycle(i)=ThisStep(i)+PreviousStep(i);
                PreviousBurstCompletedCycle(i)=1;
               end
                
            end;
           
            %now it checks whether there is a following valid burst and if it completes the current burst to a full cycle of 10 bp             
            if (OrderedDwells.Index(i+2)==1)% Computes the size of the following burst only if the dwells were validated.
                NextStep(i)=abs(OrderedDwells.Dwells(i+2)-OrderedDwells.Dwells(i+1));
                if ((ThisStep(i)+ NextStep(i)>8.75 && ThisStep(i)+NextStep(i)<11.25)||(ThisStep(i)+ NextStep(i)>18.75 && ThisStep(i)+NextStep(i)<21.25)%the next step either completes one complete cycle of 10 bp or two complete cycles of 10 bp (20 bp)
                 if (NextBurstCompletedCycle(i-1)==0) % When this number is different than zero, it says that the current burst was already associated with another burst
                    %CompletedNextCycle(i)=ThisStep(i)+ NextStep(i);
                    CompletedCycle(i)=ThisStep(i)+ NextStep(i);%When this number is different than zero, it means that both, the current and following bursts were already group together as a complete cycle
                    NextBurstCompletedCycle(i)=1;
                 end;
                end
            end   
        end
    end
    %Statistics
   display('Number of Bursts analyzed with a consecutive burst = ' count);
   
   [RawBurstsMatrix CompletedBurstsMatrix]=SortingStepSizes(ThisStep)
   
   for i=1:6
       
   end    
    close all;    
    figure('units','normalized','outerposition',[0 0 1 1]);
    Xaxis=[1:1:num];
   B=sum(A);
    %display(B);
    Percentage2_5=B/(length(A));
    display(Percentage2_5);
    TotalPercentage2_5=(Percentage2_5)*length(A)/length(ThisStep);
    display(TotalPercentage2_5);
    OneStep=ThisStep(ind);
    AfterOneStep=NextStep(ind);
    BeforeOneStep=PreviousStep(ind);
    OneCompletedPreviousCycle=CompletedPreviousCycle(ind);
    OneCompletedNextCycle=CompletedNextCycle(ind);
    OneXaxis=Xaxis(ind);
    
    ind=(ThisStep>3.75 & ThisStep<6.25);
    TwoStep=ThisStep(ind);
    A=flag(ind);
    B=sum(A);
    %display(B);
    Percentage5=B/(length(A));
    display(Percentage5);
    TotalPercentage5=(Percentage5)*length(A)/length(ThisStep);
    display(TotalPercentage5);
    AfterTwoStep=NextStep(ind);
    BeforeTwoStep=PreviousStep(ind);
    TwoCompletedPreviousCycle=CompletedPreviousCycle(ind);
    TwoCompletedNextCycle=CompletedNextCycle(ind);
    TwoXaxis=Xaxis(ind);
    
    ind=(ThisStep>6.25 & ThisStep<8.75);
    ThreeStep=ThisStep(ind);
    A=flag(ind);
    B=sum(A);
    %display(B);
    Percentage7_5=B/(length(A));
    display(Percentage7_5);
    TotalPercentage7_5=(Percentage7_5)*length(A)/length(ThisStep);
    display(TotalPercentage7_5);
    AfterThreeStep=NextStep(ind);
    BeforeThreeStep=PreviousStep(ind);
    ThreeCompletedPreviousCycle=CompletedPreviousCycle(ind);
    ThreeCompletedNextCycle=CompletedNextCycle(ind);
    ThreeXaxis=Xaxis(ind);    
    
    ind=(ThisStep>8.75 & ThisStep<11.25);
    FourStep=ThisStep(ind);
    %A=flag(ind);
    %B=sum(A);
    %display(B);
    Percentage10=length(FourStep)/(length(ThisStep));
    display(Percentage10);
    TotalPercentage10=(Percentage10);
    display(TotalPercentage10);
    
    ind=(ThisStep>11.25 & ThisStep<13.75);
    FiveOrMoreStep=ThisStep(ind);
    A=flag(ind);
    B=sum(A);
    %display(B);
    Percentage12_5=B/(length(A));
    display(Percentage12_5);
    TotalPercentage12_5=(Percentage12_5)*length(A)/length(ThisStep);
    display(TotalPercentage12_5);
    AfterFiveOrMoreStep=NextStep(ind);
    BeforeFiveOrMoreStep=PreviousStep(ind);
    FiveOrMoreCompletedPreviousCycle=CompletedPreviousCycle(ind);
    FiveOrMoreCompletedNextCycle=CompletedNextCycle(ind);
    FiveOrMoreXaxis=Xaxis(ind);  
    
    
    ind=(ThisStep>13.75 );
    SixStep=ThisStep(ind);
    A=flag(ind);
    B=sum(A);
    %display(B);
    Percentage15=B/(length(A));
    display(Percentage15);
    TotalPercentage15=(Percentage15)*length(A)/length(ThisStep);
    display(TotalPercentage15);
    AfterSixStep=NextStep(ind);
    BeforeSixStep=PreviousStep(ind);
    SixCompletedPreviousCycle=CompletedPreviousCycle(ind);
    SixCompletedNextCycle=CompletedNextCycle(ind);
    SixXaxis=Xaxis(ind);  
    
    subplot(5,1,1);
    plot(OneXaxis, OneStep,'.','Color', 'r');
    ylim([0.5 30]);
    xlim([0 num]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    hold on;
    plot(OneXaxis, AfterOneStep,'.','Color', 'g');
    hold on;
    plot(OneXaxis, BeforeOneStep,'.','Color', 'b');
    hold on;
    plot(OneXaxis, OneCompletedPreviousCycle,'.','Color', 'b','Marker','*');
    hold on;
    plot(OneXaxis, OneCompletedNextCycle,'.','Color', 'g','Marker','*');
    title('2.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %Hold Marker;
    
    hold on;
    subplot(5,1,2);
    plot(TwoXaxis, TwoStep,'.','Color', 'r');
    ylim([0.5 30]);
    xlim([0 num]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    hold on;
    plot(TwoXaxis, AfterTwoStep,'.','Color', 'g');
    hold on;
    plot(TwoXaxis, BeforeTwoStep,'.','Color', 'b');
    title('5 bin','fontweight','bold', 'FontSize',12);
    hold on;
    plot(TwoXaxis, TwoCompletedPreviousCycle,'.','Color', 'b','Marker','*');
    hold on;
    plot(TwoXaxis, TwoCompletedNextCycle,'.','Color', 'g','Marker','*');
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %Hold Marker;
    hold on;
    subplot(5,1,3);
    plot(ThreeXaxis, ThreeStep,'.','Color','r');
    ylim([2 30]);
    xlim([0 num]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    hold on;
    plot(ThreeXaxis, AfterThreeStep,'.','Color', 'g');
    hold on;
    plot(ThreeXaxis, BeforeThreeStep,'.','Color', 'b');
    hold on;
    plot(ThreeXaxis, ThreeCompletedPreviousCycle,'.','Color', 'b','Marker','*');
    hold on;
    plot(ThreeXaxis, ThreeCompletedNextCycle,'.','Color', 'g', 'Marker','*');
    title('7.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %Hold Marker
    
  
    hold on;
    subplot(5,1,4);
    plot(FiveOrMoreXaxis, FiveOrMoreStep,'.','Color', 'r');
    ylim([2 30]);
    xlim([0 num]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    hold on;
    plot(FiveOrMoreXaxis, AfterFiveOrMoreStep,'.','Color', 'g');
    hold on;
    plot(FiveOrMoreXaxis, BeforeFiveOrMoreStep,'.','Color', 'b');
    hold on;
    plot(FiveOrMoreXaxis, FiveOrMoreCompletedPreviousCycle,'.','Color', 'b','Marker','*');
    hold on;
    plot(FiveOrMoreXaxis, FiveOrMoreCompletedNextCycle,'.','Color', 'g','Marker','*');
    title('12.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %Hold Marker
    
    hold on;
    subplot(5,1,5);
    plot(SixXaxis, SixStep,'.','Color', 'r');
    ylim([2 30]);
    xlim([0 num]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    hold on;
    plot(SixXaxis, AfterSixStep,'.','Color', 'g');
    hold on;
    plot(SixXaxis, BeforeSixStep,'.','Color', 'b');
    hold on;
    plot(SixXaxis, SixCompletedPreviousCycle,'.','Color', 'b','Marker','*');
    hold on;
    plot(SixXaxis, SixCompletedNextCycle,'.','Color', 'g','Marker','*');
    title('15 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %Hold Marker
    
   
    
    TotalPercentage= length(TwoStep)/length(ThisStep)+ length(OneStep)/length(ThisStep)+ length(ThreeStep)/length(ThisStep)+ length(FourStep)/length(ThisStep)+ length(FiveOrMoreStep)/length(ThisStep)+length(SixStep)/length(ThisStep);
    display(TotalPercentage);
    
    
    end