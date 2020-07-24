function [Previous After] = Adaptive__AnalyzeSizeOfFollowingStep()
%This algorith first checks that the previous step is a complete cycle,
%i.e. > 6.25

    global analysisPath; % reads where are the files
    
    % To run this program you should run before Adaptive_Main to do the
    % step finding analysis. It would recover all the validated dwells.
    [OrderedDwells Dwell Index] = Adaptive_RecoverDwellCandidateAndIndex(); % loads dwell and index of validated dwells
    % Initializes all the arrays
    Previous=[];             
    After=[];
    OneStepBefore=[];
    TwoStepBefore=[];
    ThreeStepBefore=[];
    OneStepAfter=[];
    TwoStepAfter=[];
    ThreeStepAfter=[];
    
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
    for i=1:(num-3);
        if OrderedDwells.Index(i)==1 && OrderedDwells.Index(i+1)==1 && OrderedDwells.Index(i+2)==1 && OrderedDwells.Index(i+3)==1 
        %checks that there are 4 consecutive dwells that have been validated.
            if abs(OrderedDwells.Dwells(i)-OrderedDwells.Dwells(i+1))>8.75  % checks wheather the first one is a complete cycle. Cycles belonging to 10 bp bin are completed.
                if abs(OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2))<8.75 %Now checks that the second cycle is not completed, meaning that it belongs to the 7.5 bp are not complete
                    Previous=[Previous OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)]; %Saves first incomplete cycle burst size
                    After=[After OrderedDwells.Dwells(i+2)-OrderedDwells.Dwells(i+3)]; % Saves following burst size
                    
                    if (OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)) < 3.75; %Identifies step sizes in the 2.5 bp bin and saves the size of the next burst
                        OneStepBefore=[OneStepBefore OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)];  
                        OneStepAfter=[OneStepAfter OrderedDwells.Dwells(i+2)-OrderedDwells.Dwells(i+3)];
                        
                    elseif (OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)) < 6.25 && (OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)) > 3.75  %Identifies step sizes in the 5 bp bin and saves the size of the next burst
                        TwoStepBefore=[TwoStepBefore OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)];
                        TwoStepAfter=[TwoStepAfter OrderedDwells.Dwells(i+2)-OrderedDwells.Dwells(i+3)];
                        
                    elseif (OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)) < 8.75 && (OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)) > 6.25 %Identifies step sizes in the 7.5 bp bin and saves the size of the next burst
                        ThreeStepBefore = [ThreeStepBefore OrderedDwells.Dwells(i+1)-OrderedDwells.Dwells(i+2)];
                        ThreeStepAfter = [ThreeStepAfter OrderedDwells.Dwells(i+2)-OrderedDwells.Dwells(i+3)];
                    end
                end
            end
        end
    end
    
    Close all;    
    figure('units','normalized','outerposition',[0 0 1 1]);
    ind=(OneStepAfter>0 & OneStepAfter<20);
    OneStepAfter=OneStepAfter(ind);
    OneStepBefore=OneStepBefore(ind);
    subplot(3,3,1);
    plot([1:1:length(OneStepBefore)], OneStepBefore,'.','Color', lColor);
    ylim([0 15]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Previous step - 2.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %Hold Marker;
    subplot(3,3,2);
    plot([1:1:length(OneStepAfter)], OneStepAfter,'.','Color', lColor);
    ylim([0 15]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Following step - 2.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    subplot(3,3,3);
    plot([1:1:length(OneStepAfter)], OneStepAfter+OneStepBefore,'.','Color', lColor);
    ylim([0 20]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Steps sum - 2.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %display(length(OneStepAfter));
    ind=(TwoStepAfter>0 & TwoStepAfter<20);
    TwoStepAfter=TwoStepAfter(ind);
    TwoStepBefore=TwoStepBefore(ind);
    subplot(3,3,4);
    plot([1:1:length(TwoStepBefore)], TwoStepBefore,'.','Color', lColor);
    ylim([0 15]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Previous step - 5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    subplot(3,3,5);
    plot([1:1:length(TwoStepAfter)], TwoStepAfter,'.','Color', lColor);
    ylim([0 15]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Following step - 5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    subplot(3,3,6);
    plot([1:1:length(TwoStepAfter)], TwoStepAfter+TwoStepBefore,'.','Color', lColor);
    ylim([0 20]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Steps sum - 5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %display(length(TwoStepAfter));
    ind=(ThreeStepAfter>0 & ThreeStepAfter<20);
    ThreeStepAfter=ThreeStepAfter(ind);
    ThreeStepBefore=ThreeStepBefore(ind);
    display(length(ThreeStepAfter));
    display(length(ThreeStepBefore));
    subplot(3,3,7);
    plot([1:1:length(ThreeStepBefore)], ThreeStepBefore,'.','Color', lColor);
    ylim([0 15]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Previous step - 7.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    subplot(3,3,8);
    plot([1:1:length(ThreeStepAfter)], ThreeStepAfter,'.','Color', lColor);
    ylim([0 15]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Following step - 7.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    subplot(3,3,9);
    plot([1:1:length(ThreeStepAfter)], ThreeStepAfter+ThreeStepBefore,'.','Color', lColor);
    ylim([0 20]);
    set(gca,'ygrid','on');
    set(gco,'title','on');
    title('Steps sum - 7.5 bin','fontweight','bold', 'FontSize',12);
    xlabel('number of event (a.u.)');
    ylabel('Step size (bp)');
    %display(length(ThreeStepAfter));
    %display(length(ThreeStepBefore));
    
end