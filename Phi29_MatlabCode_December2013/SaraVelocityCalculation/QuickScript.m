VelMean     = [];
VelSigma    = [];
MeanForce   = [];
StartForce  = [];
FinishForce = [];
TimeSpan    = [];

for fc = 1:length(Data);
    for v = 1:length(Data(fc).Velocity.VelocityValue)
        VelMean(end+1)     = Data(fc).Velocity.VelocityValue(v);
        VelSigma(end+1)    = diff(Data(fc).Velocity.VelFitConfInt{v}(:,1))/2;
        MeanForce(end+1)   = Data(fc).Velocity.MeanForce(v);
        StartForce(end+1)  = Data(fc).Velocity.StartForce(v);
        FinishForce(end+1) = Data(fc).Velocity.FinishForce(v);
        TimeSpan(end+1)    = Data(fc).Velocity.FinishTime(v) - Data(fc).Velocity.StartTime(v);
    end
end

%% Plot Force Range Coverage
figure; set(gca,'FontName','AvantGarde','NextPlot','add');
for v = 1:length(VelMean)
    x = [StartForce(v) FinishForce(v)];
    y = VelMean(v)*[1 1];
    plot(x,y,'r');
end
ExtraX = 0.1; %amount of extra room on the sides
XLim = [min(StartForce) max(FinishForce)];
XLim = [XLim(1)-ExtraX*range(XLim) XLim(2)+ExtraX*range(XLim)];
ExtraY = 0.1;
YLim = [min(VelMean)-range(VelMean)*ExtraY  max(VelMean)+ExtraY*range(VelMean)];
set(gca,'XLim',XLim,'YLim',YLim,'Box','on');
xlabel('Force (pN)','FontWeight','bold');
ylabel('Velocity (bp/s)','FontWeight','bold');

%% Plot Velocity and Err Bars versus TimeSpan
figure; set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
errorbar(TimeSpan,VelMean,VelSigma,'.b');
xlabel('Time Span (s)','FontWeight','bold');
ylabel('Velocity (bp/s)','FontWeight','bold');

%% Plot Velocity vs Sigma
%close all;
figure; set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
plot(VelMean,VelSigma,'.k');
ylabel('2{\sigma} Confidence Interval (bp/sec)','FontWeight','bold');
xlabel('Velocity (bp/s)','FontWeight','bold');

%% Plot Vel and ErrorBars in the order of increasing ErrorBars
figure; set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
x = 1:1:length(VelSigma);
[~, Ind] = sort(VelSigma);
for i = 1:length(Ind)
    %plot(x(i), VelMean(Ind(i)),'.m');
    plot(x(i)*[1 1], [VelMean(Ind(i))-VelSigma(Ind(i))  VelMean(Ind(i))+VelSigma(Ind(i))],'-m');
end

ylabel('Velocity (bp/s)','FontWeight','bold');
xlabel('Velocity Segment ID # (increasing {\sigma})','FontWeight','bold');
set(gca,'XLim',[-length(VelSigma)*0.05 length(VelSigma)*1.05]);

%% Plot all the gaussians
GaussFunct = @(p,x) p(1)*exp(-((x-p(2)).^2)./(2*p(3)^2));
% p(1) is the amplitude
% p(2) is the mean
% p(3) is the sigma
figure; hold on
X = 0:0.1:100;
Y = 0*X;
for v = 1:length(VelMean)
    Sigma = VelSigma(v); %we have 95% conf int, which is 2*sigma
    Amp = TimeSpan(v)*1/(Sigma*sqrt(2*pi));
    Mean = VelMean(v);
    Xmin = Mean-4*Sigma;
    Xmax = Mean+4*Sigma;
    x=  Xmin:(Xmax-Xmin)/100:Xmax;
    y=GaussFunct([Amp Mean Sigma],x);
    plot(x,y);
    Y = Y+interp1(x,y,X,'linear',0);
end
figure
plot(X,Y,'r')

%%
Ind = find(MeanForce<10 & MeanForce>7);
MeanVel = sum(TimeSpan(Ind).*Vel(Ind))/sum(TimeSpan(Ind));
DeltaT = 1/20; %smallest time increment
temp = [];

for i = 1:length(Ind)
    temp = [temp Vel(Ind(i))*ones(1,round(TimeSpan(Ind(i))/DeltaT))];
end
hist(temp,50);