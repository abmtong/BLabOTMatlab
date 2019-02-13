function BurstAlignment_PlotStepping(StepSize, DwellTime, DwellStErr)
% This function works in tandem with other functions from the
% BurstAlignment family. It plots the stepping patters fiven the StepSize
% and DwellTimes. It also plots an uncertainty box given by the Standard
% Error of the Dwell Location.
%
% USE: BurstAlignment_PlotStepping(StepSize, DwellTime, DwellStErr)
%
% Gheorghe Chistol, 28 Dec 2010

figure; hold on;
for i=1:length(StepSize)
    %plot step
    if i==1
        t=[0 0];
        y=[0 StepSize(i)]-StepSize(1);
    else
        t=sum(DwellTime(1:i-1))*[1 1];
        y=[sum(StepSize(1:i-1)) sum(StepSize(1:i))]-StepSize(1);
    end
    plot(t,y,'b');
    %plot dwell
    if i==1
        t=[0 DwellTime(1)];
        y=StepSize(1)*[1 1]-StepSize(1);
        UncertaintyRect = [0 -DwellStErr(i) DwellTime(i) 2*DwellStErr(i)];
    else
        UncertaintyRect = [sum(DwellTime(1:i-1)) sum(StepSize(2:i))-DwellStErr(i) DwellTime(i) 2*DwellStErr(i)];
        t=[sum(DwellTime(1:i-1)) sum(DwellTime(1:i))];
        y=sum(StepSize(1:i))*[1 1]-StepSize(1);
    end
    if DwellStErr(i)>0 %sometimes the StErr is too small
        rectangle('Position',UncertaintyRect,'FaceColor',0.8*[1 1 1],'EdgeColor','none');
    end
    plot(t,y,'k');
end