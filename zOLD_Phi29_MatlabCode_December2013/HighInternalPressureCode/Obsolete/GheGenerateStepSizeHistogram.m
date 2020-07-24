%Gheorghe Chistol, June 03, for group meeting

%%
clear all;
close all;
load('StepsAndDwells_21kb.mat'); %21kb data

%%
N=[29 30 120 60 35];
BackStepFract{1}='4%';
BackStepFract{2}='6%';
BackStepFract{3}='8%';
BackStepFract{4}='11%';
BackStepFract{5}='17%';

TitleString{1}='15kb to 16kb';
TitleString{2}='16kb to 17kb';
TitleString{3}='17kb to 18kb';
TitleString{4}='18kb to 19kb';
TitleString{5}='19kb to 20kb';
AxisLimits{1}=[-15 20 0 100];
AxisLimits{2}=[-15 20 0 200];
AxisLimits{3}=[-15 20 0 400];
AxisLimits{4}=[-15 20 0 400];
AxisLimits{5}=[-15 20 0 50];

FigureFileName{1}='StepSize_15-16kb';
FigureFileName{2}='StepSize_16-17kb';
FigureFileName{3}='StepSize_17-18kb';
FigureFileName{4}='StepSize_18-19kb';
FigureFileName{5}='StepSize_19-20kb';
FigureFileName{6}='StepSize_EmptyCapsid';
FigureFileName{7}='StepConsSum_15-16kb';
FigureFileName{8}='StepConsSum_16-17kb';
FigureFileName{9}='StepConsSum_17-18kb';
FigureFileName{10}='StepConsSum_18-19kb';
FigureFileName{11}='StepConsSum_19-20kb';



close all;
f=1; %figure #
for i=1:5
    NegFraction(i) = length(find(Bin(i).StepSize<0))/length(Bin(i).StepSize)*100;
    figure;
    hist(Bin(i).StepSize,N(i));
    title(['Capsid Contains ' TitleString{i} ' DNA; Backward Step Fraction: ' BackStepFract{i} '; N=' num2str(length(Bin(i).StepSize))]);
    axis(AxisLimits{i});
    xlabel('Phi29 Step Size (bp)');
    ylabel('Occurences (#)')
    saveas(gcf,FigureFileName{f},'png'); f=f+1;
end

%% now plot the data for an empty capsid
load('StepsAndDwells_EmptyCapsid.mat'); %21kb data
N(6)=32;
BackStepFract{6}='<3%';
TitleString{6}='less than 10kb';
AxisLimits{6}=[-15 20 0 80];

NegFraction(6) = length(find(Step.Size<0))/length(Step.Size)*100;
figure;
hist(Step.Size,N(6));
title(['Capsid Contains ' TitleString{6} ' DNA; Backward Step Fraction: ' BackStepFract{6} '; N=' num2str(length(Step.Size))]);
axis(AxisLimits{6});
xlabel('Phi29 Step Size (bp)');
ylabel('Occurences (#)')
saveas(gcf,FigureFileName{f},'png'); f=f+1;

%% Now Plot Consecutive Short Step Sums
load('StepsAndDwells_21kb.mat'); %21kb data

N=[29 35 50 40 35];
%BackStepFract{1}='4%';
%BackStepFract{2}='6%';
%BackStepFract{3}='8%';
%BackStepFract{4}='11%';
%BackStepFract{5}='17%';

TitleString{1}='15kb to 16kb';
TitleString{2}='16kb to 17kb';
TitleString{3}='17kb to 18kb';
TitleString{4}='18kb to 19kb';
TitleString{5}='19kb to 20kb';
AxisLimits{1}=[-15 20 0 80];
AxisLimits{2}=[-15 20 0 120];
AxisLimits{3}=[-15 20 0 250];
AxisLimits{4}=[-15 20 0 200];
AxisLimits{5}=[-15 20 0 30];


for i=1:5
    figure;
    hist(Bin(i).ConsStepSum,N(i));
    title(['Capsid Contains ' TitleString{i} ' DNA; N=' num2str(length(Bin(i).ConsStepSum))]);
    axis(AxisLimits{i});
    xlabel('Sum of Two Consecutive Short (<8bp) Steps (bp)');
    ylabel('Occurences (#)')
    saveas(gcf,FigureFileName{f},'png'); f=f+1;
end
