function [] = PlotMultipleDwellAndBurstMeans(Dwells, Bursts)
% Calls a function to compute the mean and confidence intervals based on a
% bootstrap method. Uses the output of the file:
% VelSummary=CalculateVelocity_SummariseResults.m;
% This algorithm calls a similar function to CalculateMeanDwellConfInter to compute mean
% and confidence intervals

ConfInter=0.95;
Iter=100;
%IterB=300;
x=[0:0.005:0.5];
z=[0:0.1:20];
%MeanDwell;
%DwellMat = [0 0 0];
CumulativeMean=0;
counter=0;

%TempDwells={};

prompt = {'If this is the WT motor type W. If this is the mutant motor type M'};
    TypeOfMotor = 'Input';
    num_lines = 1;
    def = {'W'}; 
    answer = inputdlg(prompt,TypeOfMotor,num_lines,def);
    if strcmp(answer,'W')==1
        SinVelColor=[0 0.75 0.75];
        CumVelColor=[0 0 1];
    elseif strcmp(answer,'M')==1
        SinVelColor=[1 0.6 0.79];
        CumVelColor=[1 0 0];
    end
figure;    
hold on;
for i=1:length(Dwells)
    clear y;
    TempDwells=Dwells(i).Duration;
    DwellMat = CalculateMeanVelocityConfInt(TempDwells,Iter,ConfInter);
    if isnan(DwellMat(2))~=1
    %VelocitiesMeanCF(i)=MeanCF;
        Error=(DwellMat(3)-DwellMat(1))/2;
        y=normpdf(x,DwellMat(2),Error);
        CumulativeMean=CumulativeMean+y;
        plot(x,y,'Color', SinVelColor);
        hold on;
        counter=counter+1;
    end
end

CumulativeMean=CumulativeMean/counter;
hold on; plot(x,CumulativeMean,'Color',CumVelColor,'LineWidth',2);

figure;
hold on;
CumulativeMean=0;
counter=0;

for i=1:length(Bursts)  
    clear b;
    TempBursts=Bursts(i).Size;
    ind=~isnan(TempBursts);
    TempBursts=TempBursts(ind);
    BurstsMat = CalculateMeanVelocityConfInt(TempBursts,Iter,ConfInter);
   % disp(i); disp(' paso');
    if isnan(BurstsMat(2))~=1
    %VelocitiesMeanCF(i)=MeanCF;
        ErrorB=(BurstsMat(3)-BurstsMat(1))/2;
        b=normpdf(z,BurstsMat(2),ErrorB);
        CumulativeMean=CumulativeMean+b;
        plot(z,b,'Color', SinVelColor);
        hold on;
        counter=counter+1;
    end
end

CumulativeMean=CumulativeMean/counter;

hold on; plot(z,CumulativeMean,'Color',CumVelColor,'LineWidth',2);

end

