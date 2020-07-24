function [] = PlotMultipleVelocities(VelSummary)
% Calls a function to compute the mean and confidence intervals based on a
% bootstrap method. Uses the output of the file:
% VelSummary=CalculateVelocity_SummariseResults.m;
% This algorithm calls a similar function to CalculateMeanDwellConfInter to compute mean
% and confidence intervals

ConfInter=0.95;
Iter=100;
x=[0:0.01:200];
VelocitiesMeanCF = [];
CumulativeVel=0;
counter=0;

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

for i=1:length(VelSummary.Velocities)
    clear y;
    MeanCF=CalculateMeanVelocityConfInt(VelSummary.Velocities{i},Iter,ConfInter);
    %VelocitiesMeanCF(i)=MeanCF;
    if isnan(MeanCF(2))~=1
        Error=(MeanCF(3)-MeanCF(1))/2;
        y=normpdf(x,MeanCF(2),Error);
        CumulativeVel=CumulativeVel+y;
        plot(x,y,'Color', SinVelColor);
        hold on;
        counter=counter+1;
    end
end

CumulativeVel=CumulativeVel/counter;

hold on; plot(x,CumulativeVel,'Color',CumVelColor,'LineWidth',2);

end

