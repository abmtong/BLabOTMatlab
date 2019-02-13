function TestingFilteringTechniques(PhageData,CurrentFeedbackCycle)
DeltaT=0.1;
Bandwidth = 20:10:200;

for i=1:length(Bandwidth)
    Window=round(DeltaT*Bandwidth(i));

    PhageData = BareTTest(PhageData, round(2500/Bandwidth(i)), Window, CurrentFeedbackCycle);
    %figure;
    %semilogy(PhageData.timeFiltered{CurrentFeedbackCycle},PhageData.sgn{CurrentFeedbackCycle});
    [N X] = hist(PhageData.sgn{CurrentFeedbackCycle},10000);
    
    clear RI;
    RI=find(N==0); %find zero entries, RI=RemoveIndex
    X(RI)=[]; %remove zero entries, this is done to get rid of those empty bins
    N(RI)=[]; %remove zero entries
    X=double(X); %change the class from single to double, this avoids errors later

    %a0 = [1 1 2 ];
    %[b error] = lsqcurvefit(@Exponent,a0,X,N);
    %Nfit=Exponent(b,X); %the curve as predicted by the fit
    %figure;
    %plot(X,N,'.b',X,Nfit,'-k');
    %title(['Filtering to ' num2str(Bandwidth(i)) 'Hz; a(3)=' num2str(b(3)) ]);
    %calculate the cumulative distribution function
    clear CumulativeDistribution;
    for j=1:length(X)
        CumulativeDistribution(j)=sum(N(1:j));
    end
    CumulativeDistribution=CumulativeDistribution./CumulativeDistribution(end);
    %figure;
    %stairs(X,CumulativeDistribution);
    %title(['Filtering to ' num2str(Bandwidth(i)) 'Hz']);
    
    CDFY(i)=CumulativeDistribution(1);
    CDFX(i)=X(1);
end
figure;
%semilogx(CDFX,CDFY,'+');
semilogy(Bandwidth,CDFX,'.');
%`title(['Filtering to ' num2str(Bandwidth(i)) 'Hz']);