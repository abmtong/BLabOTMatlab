%Gheorghe Chistol, June 03, for group meeting

%%
close all; clear all;
N=[10 70 40 150 100];

TitleString{1}='15kb to 16kb';
TitleString{2}='16kb to 17kb';
TitleString{3}='17kb to 18kb';
TitleString{4}='18kb to 19kb';
TitleString{5}='19kb to 20kb';
AxisLimits{1}=[0 10 0 600];
AxisLimits{2}=[0 10 0 700];
AxisLimits{3}=[0 10 0 1200];
AxisLimits{4}=[0 10 0 700];
AxisLimits{5}=[0 10 0 60];

FigureFileName{1}='DwellTime_15-16kb';
FigureFileName{2}='DwellTime_16-17kb';
FigureFileName{3}='DwellTime_17-18kb';
FigureFileName{4}='DwellTime_18-19kb';
FigureFileName{5}='DwellTime_19-20kb';
FigureFileName{6}='DwellTime_EmptyCapsid';



load('StepsAndDwells_21kb.mat'); %21kb data

f=1; %figure #
for i=1:5
    figure;
    hist(Bin(i).DwellTime,N(i));
    title(['Capsid Contains ' TitleString{i} ' DNA; N=' num2str(length(Bin(i).DwellTime))]);
    axis(AxisLimits{i});
    xlabel('Phi29 Dwell Time (sec)');
    ylabel('Occurences (#)')
    saveas(gcf,FigureFileName{f},'png'); f=f+1;
end

%% now plot the data for an empty capsid
load('StepsAndDwells_EmptyCapsid.mat'); %21kb data
N(6)=10;
TitleString{6}='less than 10kb';
AxisLimits{6}=[0 1 0 100];

figure;
hist(Dwell.Time,N(6));
title(['Capsid Contains ' TitleString{6} ' DNA; N=' num2str(length(Dwell.Time))]);
axis(AxisLimits{6});
xlabel('Phi29 Dwell Time (sec)');
ylabel('Occurences (#)')
saveas(gcf,FigureFileName{f},'png'); f=f+1;
