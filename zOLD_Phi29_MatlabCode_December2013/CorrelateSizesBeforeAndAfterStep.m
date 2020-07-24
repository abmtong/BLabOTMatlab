function [n SumSteps PrevStep AfterStep IsAfterStepA10 IsBeforeStepA10] = SumBeforeAndAfterStep(Dwells)

% This function helps you visualize the dependence of the size of the
% following step as a function of the size of the first step
% It also correlates the previous dwell with the size of the step 
% You give as the entry the Dwells structure that you obtaine by running
% Adaptive Kalafut Visscher step finding algorith
% 
    n=0;
    for i = 1:length(Dwells.Duration);
        if Dwells.SizeStepBefore(i)<3.75;
            if Dwells.SizeStepAfter(i)>8.75;
                IsAfterStepA10(i)=10;
                n=n+1;
            else    
                SumSteps(1,i)=Dwells.SizeStepBefore(i)+Dwells.SizeStepAfter(i);
                PrevStep(1,i)= Dwells.SizeStepBefore(i);
                AfterStep(1,i)= Dwells.SizeStepAfter(i);
            end;
        elseif Dwells.SizeStepBefore(i)>3.75 && Dwells.SizeStepBefore(i)<6.25;
            if Dwells.SizeStepAfter(i)>8.75;
                IsAfterStepA10(i)=10;
                n=n+1
            else   
                SumSteps(2,i)=Dwells.SizeStepBefore(i)+Dwells.SizeStepAfter(i); 
                PrevStep(2,i)= Dwells.SizeStepBefore(i);
                AfterStep(2,i)= Dwells.SizeStepAfter(i);
            end;
        elseif Dwells.SizeStepBefore(i)>6.25 && Dwells.SizeStepBefore(i)<8.75;
            if Dwells.SizeStepAfter(i)>8.75;
                IsAfterStepA10(i)=10;
                n=n+1;
            else
                SumSteps(3,i)=Dwells.SizeStepBefore(i)+Dwells.SizeStepAfter(i);  
                PrevStep(3,i)= Dwells.SizeStepBefore(i);
                AfterStep(3,i)= Dwells.SizeStepAfter(i);
            end;
        elseif Dwells.SizeStepBefore(i)>8.75;
             if Dwells.SizeStepAfter(i)>8.75;
                IsAfterStepA10(i)=10;
                IsBeforeStepA10(i)=9;
                n=n+1;
             else
                IsBeforeStepA10(i)=9; 
                n=n+1;
             end    
        end      
    end
    close all;
    figure;
    plot(1:1:length(Dwells.Duration), AfterStep(1,i))
    set(gca,'YLim',[0 15]);
    xlabel('Number of event (a.u.)');
    ylabel('Sizw of following step (bp)');
    title('Step size of the following step');
    
    
end