function T=StepFinding_ATPgS_SingleExponentialHistogramFit(Data,BinSize,XLim,Color)
    %
    % T_25 = StepFinding_ATPgS_SingleExponentialHistogramFit(ClusterDuration,1,[0.5 20])
    %
    % Gheorghe Chistol, 26 July 2011
    
    Data = Data(Data>XLim(1) & Data < XLim(2));
    Bins = XLim(1)+BinSize/2:BinSize:XLim(2);
    [N X] = hist(Data,Bins);
    %N(1) = [];
    %X(1) = [];
    ExponentialFun = @(p,x) p(1).*exp(-x./p(2));

    pFit = fit(X',N','exp1');
    temp = confint(pFit); %95% confidence interval
    ConfInt = temp(:,2); 
    T.Mean  = -1/pFit.b;     %best estimate of Tau
    T.Upper = -1/ConfInt(2); %upper limit
    T.Lower = -1/ConfInt(1); %lower limit
    T.Plus  = T.Upper-T.Mean;
    T.Minus = T.Mean-T.Lower; 
    figure; hold on;
    set(gca,'FontSize',16,'LineWidth',2,'Layer','top');
    bar(X,N,1);
    h = findobj(gca,'Type','Patch');
    set(h,'FaceColor',rgb(Color));

    x = X(1)-BinSize/2:range(X)/100:X(end);
    y = ExponentialFun([pFit.a T.Mean],x);
    plot(x,y,'r','LineWidth',2);
    xlabel('Time (s)');
    ylabel(['Counts (Ntotal = ' num2str(length(Data)) ')']);

    set(gca,'Box','on');
    set(gca,'XLim',XLim);
    title(['Tau = ' sprintf('%2.2f',T.Mean) ' sec (' sprintf('%2.2f',T.Lower) '-' sprintf('%2.2f',T.Upper) ')' ]);
%     pFit = nlinfit(X,N,ExponentialFun,p0);
%     
%     y = ExponentialFun(pFit,x);
%     figure; hold on;
%     hist(Data,Bins);
%     plot(x,y,'y','LineWidth',2);
end