function out = avgprotsv2()

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
pfits = cell(1,len);
rsds = zeros(1,len);
rsds2 = cell(1,len);

%v2: fit is 3 gaussians, see @protocolfit
%Shoulda just used cos
fitfcn = @(x0,x) - x0(1) * cos(x/60*pi - x0(2)) + x0(3);
% fitfcn2 = @(x0,x) - x0(1) * cos(x/60*pi) + x0(2);
% fitfcn3 = @(x0,x) x0(1)*normpdf(x, 60, x0(2))+x0(3);
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
    
    dx=.1;
    
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
    di = round(ft(2) / dx);
    y = circshift(y, [di, 0]);
  
    
    
    %Find best 3-fold rotation
    [ft, fitfcn, rsds(i)] = protocolfitv1b(x, y,dx);
    %ft = [[mn sd amp] x 3 offset]
    
    %Center at peak, average together
    xc = -180:dx:179.9;
    yy = circshift(y, -[round(ft(2)/dx),0]) + circshift(y, -[round(ft(5)/dx),0]) + circshift(y, -[round(ft(8)/dx),0]);
    yy = yy / 3;
    yy = circshift(yy, [1800,0]);
    
    %And save
    pshfts{i} = [xc' yy];
    pfits{i} = ft;
    
    figure, subplot(2,1,1), plot(x, y)
    hold on
    plot(x, fitfcn(ft))
    subplot(2,1,2)
    
    plot(xc,yy);
    
end

%Average together pfits
pbar = cellfun(@(x) x(:,2), pshfts, 'un', 0);
pbar = mean(reshape([pbar{:}],triad*3, []), 2);

%And plot
figure name AvgProt
hold on
plotc = @(x) plot(x(:,1), x(:,2));
cellfun(plotc, pshfts)

plot(x, pbar,'Color', 'k', 'LineWidth', 2)

out = [x pbar];


