function [X Y Ystd]=uConsolidateAlpha(varargin)
    x = [];
    y = [];
    for i = 1:nargin
        curr = varargin{i};
        x = [x curr.ScaledV];
        y = [y curr.ScaledAX];
    end
    
    X = unique(x);
    for i = 1:length(X)
        Ind = x==X(i);
        Y(i) = mean(y(Ind));
        Ystd(i) = std(y(Ind));
    end
    
    figure; hold on;
    plot(x,y,'.','Color',0.9*[1 1 1]);
    errorbar(X,Y,Ystd,'.b');
    ylabel('Normalized Detector Sensitivity Alpha Xaxis')
end