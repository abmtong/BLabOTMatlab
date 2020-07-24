function CumProb = CumulativeProbability (X)
%Give an array and will compute a second array with the cummulative
%probability up to a certain value 
    L = length(X);
    MaxValue = max(X);
    Counts=histc(X,[0:(MaxValue/L):MaxValue]);
    NumBins = length(Counts);
    CumProb = nan(1,NumBins);
    CumProb(1)=0;

    for j=2:NumBins; 
        CumProb(j) = CumProb(j-1) + Counts(j)/L;
    end
    
    hfig=9;
    figure(hfig);clf;
    plot([0:(MaxValue/L):MaxValue],CumProb,'-');
    fontSize = 10;
    set(gca,'fontsize',fontSize);
    set(gca,'linewidth',1);
    set(gca,'layer','top');
    set(gca,'ylim',[0,1]);
    set(gca,'xlim',[0,MaxValue]);
    box off;
    set(hfig, 'PaperSize', [3 2.5]);
    set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
    ylabel('Cumulative probability, {\it AU}')
    xlabel('Something Here, {\it s}');
