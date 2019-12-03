function out = avgprots()

[f, p] = uigetfile('*.mat', 'Mu', 'on');
if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);
praws = cell(1,len);
pshfts = cell(1,len);
pshft1 = cell(1,len);
pfits = cell(1,len);
rsds = zeros(1,len);
rsds2 = cell(1,len);
%Shoulda just used cos
fitfcn = @(x0,x) - x0(1) * cos(x/60*pi - x0(2)) + x0(3);
fitfcn2 = @(x0,x) - x0(1) * cos(x/60*pi) + x0(2);
fitfcn3 = @(x0,x) x0(1)*normpdf(x, x0(2), x0(3))+x0(4);
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
gu = [0.1 0 1];

for i = 1:len
    %Load file
    eld = load([p f{i}]);
    eld = eld.eldata;
    
    %Extract protocol data
    pr = eld.prot;
    prw = lvprot(pr(:,1),pr(:,2));
    praws{i} = prw;
    
    x = prw(:,1);
    y = prw(:,2);
    
    %Find best 3-fold rotation
    [ft, rsds(i)] = lsqcurvefit(fitfcn, gu, x,circsmooth(y,600),[],[],lsqopts);
    
    %Curate pfit
    %If f1 is negative, make positive and then shift offset.
    % Could also constrain ft(1), but eh
    if ft(1) < 0
        ft(1) = -ft(1);
        ft(2) = ft(2) + pi;
    end
    
    %Apply shift
    dx = median(diff(x));
    di = round(ft(2) / dx);
    y = circshift(y, [di, 0]);
    
    %Now on offset: Offset so 'best' section is moved to [0,120]
    rsd = zeros(1,3);
    triad = length(x)/3;
    
    x1 = x(1:triad);
    x2 = x(triad+1:2*triad);
    x3 = x(2*triad+1:end);
    y1 = y(1:triad);
    y2 = y(triad+1:2*triad);
    y3 = y(2*triad+1:end);
    
    yf = circsmooth(y, 600);
    [f1, rsd(1)] = lsqcurvefit(fitfcn2, [.5 1], x(1:triad),yf(1:triad), [0 0], [inf inf], lsqopts);
    [f2, rsd(2)] = lsqcurvefit(fitfcn2, [.5 1], x(1:triad),yf(triad + (1:triad)), [0 0], [inf inf], lsqopts);
    [f3, rsd(3)] = lsqcurvefit(fitfcn2, [.5 1], x(1:triad),yf(triad * 2 + (1:triad)), [0 0], [inf inf], lsqopts);
    [~, mnrsd] = min(rsd);
    y = circshift(y, [-triad * (mnrsd-1),0]);
    
    %try gauss fit
    lb = [0 0 0];
    ub = [inf 120 inf prctile(y,25)];
    [f1, rsd(1)] = lsqcurvefit(fitfcn3, [range(y1) mean(x1) std(y1) min(y1)], x1,(y1), [lb min(y1)], ub, lsqopts);
    [f2, rsd(1)] = lsqcurvefit(fitfcn3, [range(y2) mean(x1) std(y2) min(y2)], x1,(y2), [lb min(y2)], ub, lsqopts);
    [f3, rsd(1)] = lsqcurvefit(fitfcn3, [range(y3) mean(x1) std(y3) min(y3)], x1,(y3), [lb min(y3)], ub, lsqopts);
    
    %Add peak centers
    xc = -180:dx:179.9;
    yy = circshift(y, -[round(f1(2)/dx),0]) + circshift(y, -[round(f2(2)/dx)+triad,0]) + circshift(y, -[round(f3(2)/dx)+2*triad,0]);
    yy = yy / 3;
    yy = circshift(yy, [1800,0]);
    
    %add peak centers of best peak only
    [~, mnrsd] = min(rsd);
    yy2 = circshift(y, -[round(f1(mnrsd)/dx),0]);
    yy2 = circshift(yy2, [1800,0]);
    
    %And save
    rsds2{i} = rsd;
    pfits{i} = ft;
    
    figure, subplot(2,1,1),
    plot(x, y)
    hold on
    plot(x, yf)
    plot(x1, fitfcn3(f1,x1))
    plot(x2, fitfcn3(f2,x1))
    plot(x3, fitfcn3(f3,x1))
    
    subplot(2,1,2)
    plot(xc,yy)
    pshfts{i} = [xc' yy];
    pshft1{i} = [xc' yy2];
end

%Average together pfits
pbar = cellfun(@(x) x(:,2), pshfts, 'un', 0);
pbar = median(reshape([pbar{:}],triad*3, []), 2);

%And plot
figure name AvgProt
hold on
plotc = @(x) plot(x(:,1), x(:,2));
cellfun(plotc, pshfts)
plot(xc, pbar,'Color', 'k', 'LineWidth', 2)

%same for _1
pbar = cellfun(@(x) x(:,2), pshft1, 'un', 0);
pbar = median(reshape([pbar{:}],triad*3, []), 2);

figure name AvgProt1
hold on
plotc = @(x) plot(x(:,1), x(:,2));
cellfun(plotc, pshft1)
plot(xc, pbar,'Color', 'k', 'LineWidth', 2)

out = [x pbar];


