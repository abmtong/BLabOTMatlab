ATP=[10 15 25 50 100 250 500 1000];
close all;
for b=1:length(Bin.Start)
    x{b}=[];
    y{b}=[];
    Temp_Vel{b}=[];
    Temp_StDev{b}=[];
    Temp_StErr{b}=[];
    Temp_ATP{b}=[];
    %%figure;
    %%hold on;
%     for a=1:length(ATP) %atp
%         n=length(Data{a}.Velocity{b});
%         plot(ones(n,1)*ATP(a), -Data{a}.Velocity{b},'.','Color',[0.5 0.5 0.5]);
%         %errorbar(ATP(a),mean(-Data{a}.Velocity{b}),std(-Data{a}.Velocity{b}),'Color',[1 1 1]*0.5);
%         errorbar(ATP(a),mean(-Data{a}.Velocity{b}),std(-Data{a}.Velocity{b})/sqrt(length(Data{a}.Velocity{b})),'Color',[1 1 1]*0);
%         plot(ATP(a),mean(-Data{a}.Velocity{b}),'ob');
%     end

    for a=1:length(ATP) %atp
        n=length(Data{a}.Velocity{b});
        if ~isempty(Data{a}.Velocity{b})
            Temp_Vel{b}   = [Temp_Vel{b}   mean(-Data{a}.Velocity{b})];
            Temp_StDev{b} = [Temp_StDev{b} std(-Data{a}.Velocity{b})];
            Temp_StErr{b} = [Temp_StErr{b} std(-Data{a}.Velocity{b})/sqrt(length(Data{a}.Velocity{b}))];
            Temp_ATP{b}   = [Temp_ATP{b} ATP(a)];
        end
        x{b} = [x{b} 1/ATP(a)];
        y{b} = [y{b} 1/mean(-Data{a}.Velocity{b})];
        %%plot((ones(n,1)*ATP(a)).^-1, (-Data{a}.Velocity{b}).^-1,'.','Color',[0.5 0.5 0.5]);
        %errorbar(ATP(a),mean(-Data{a}.Velocity{b}),std(-Data{a}.Velocity{b}),'Color',[1 1 1]*0.5);
        %errorbar(ATP(a),mean(-Data{a}.Velocity{b}),std(-Data{a}.Velocity{b})/sqrt(length(Data{a}.Velocity{b})),'Color',[1 1 1]*0);
        %%plot(ATP(a).^-1, (mean(-Data{a}.Velocity{b}))^-1,'o','Color',[1 1 1]*0);
    end
    %%plot(x{b},y{b},'+b');
    Remove=isnan(y{b});
    x{b}(Remove)=[];
    y{b}(Remove)=[];
    Fit{b}=polyfit(x{b},y{b},1);
    %%plot(x{b},polyval(Fit{b},x{b}),'b-');
    Vmax(b)=1/Fit{b}(2);
    Km(b)  = Fit{b}(1)/Fit{b}(2);
    
    %%title([num2str(Bin.Start(b)) ' to ' num2str(Bin.End(b)) ' bp']);
    %set(gca,'XScale','log');
    %%xlabel('1/[ATP] 1/(uM)');
    %%ylabel('1/Vel 1/(bp/sec)');
end
% % figure;
% % plot((Bin.Start+Bin.End)/2,Vmax,'ob');
% % xlabel('DNA Packaged (bp)');
% % ylabel('Calculated Vmax')
% % 
% % figure;
% % plot((Bin.Start+Bin.End)/2,Km,'ob');
% % xlabel('DNA Packaged (bp)');
% % ylabel('Calculated Km')


% 
% figure;
% plot((Bin.Start+Bin.End)/2,Vmax./Km,'ob');
% xlabel('DNA Packaged (bp)');
% ylabel('Calculated Km')
%% Fitting to a generalized Michaelis-Menten Curve 
    Km=[];
    Km_Interval=[];
    Vmax = [];
    Vmax_Interval = [];
    N=[];
    N_Interval=[];
    Filling = [];

for b=1:length(Bin.Start)
    %figure; hold on;
    %plot(Temp_ATP{b},Temp_Vel{b},'+b');
    
    xdata=Temp_ATP{b};
    ydata=Temp_Vel{b};
    Label=[num2str(Bin.Start(b)) ' to ' num2str(Bin.End(b)) ' bp'];
    %FitHillCurve(xdata,ydata,Label);
    StDev = Temp_StDev{b};
    StErr = Temp_StErr{b};
%    figure;
%    errorbar(xdata,ydata,StErr,'ok');
    if Bin.Start(b)~=16500 && Bin.Start(b)<19500
%        Ind=find(xdata==250);
%        xdata(Ind)=[];
%        ydata(Ind)=[];
%        StDev(Ind)=[];
%        StErr(Ind)=[];
        figure;
        FitResults{b} = FitGeneralizedHillCurve(xdata,ydata,StDev, StErr);
        xlabel('[ATP] (uM)');
        ylabel('Velocity (bp/sec)');
        title([num2str(Bin.Start(b)) ' to ' num2str(Bin.End(b))]);
        
        Filling(end+1) = mean(Bin.Start(b),Bin.End(b)); %#ok<*SAGROW>
        Value = coeffvalues(FitResults{b});
        Km(end+1)=Value(1);
        Vmax(end+1)=Value(2);
        N(end+1)=Value(3);
        
        Interval = confint(FitResults{b},0.95);
        Km_Interval{end+1}=Interval(:,1);
        Vmax_Interval{end+1}=Interval(:,2);
        N_Interval{end+1}=Interval(:,3);
    end
    %P0     = [100 50 1];
    %FitP = lsqcurvefit(@HillEquation,[100 50 2],xdata,ydata);
    %FitY = HillEquation(FitP,xdata);
    %plot(xdata,FitY,'r-');
end
%% Plot N
figure; hold on;
for i=1:length(N)
plot([1 1]*Filling(i),N_Interval{i},'Color',[.7 .7 .7]);
end
plot(Filling,N,'.k');
axis([9500 19500 -0.5 1.6]);
xlabel('Capsid Filling (bp)');
ylabel('Hill Coefficient n');
title('Hill Coefficient vs Capsid Filling, 95% Confidence Intervals')

%% Plot Vmax
figure; hold on;
for i=1:length(Vmax)
plot([1 1]*Filling(i),Vmax_Interval{i},'Color',[.7 .7 .7]);
end
plot(Filling,Vmax,'.k');
axis([9500 19500 0 110]);
xlabel('Capsid Filling (bp)');
ylabel('Vmax (bp/sec)');
title('Vmax vs Capsid Filling, 95% Confidence Intervals')

%% Plot Km
figure; hold on;
for i=1:length(Km)
plot([1 1]*Filling(i),Km_Interval{i},'Color',[.7 .7 .7]);
end
plot(Filling,Km,'.k');
axis([9500 19500 0 100]);
xlabel('Capsid Filling (bp)');
ylabel('Km (uM)');
title('Km vs Capsid Filling, 95% Confidence Intervals')
