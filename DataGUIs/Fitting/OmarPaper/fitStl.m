function out = fitStl(indata)
%Fit Stl restart time data

indata = indata(:)';

%Create CCDF
ccx = sort(indata, 'ascend');
ccy = (length(indata):-1:1)/length(indata);

%Create fit CCDFs
expccdf = @(x0,x) exp(-x0*x);
difccdf = @(x0,x) 1 - ( 1 - (x/x0+1).^-.5 ) ;
hybccdf = @(x0,x) x0(1) * expccdf( x0(2), x) + (1-x0(1)) * difccdf( x0(3), x) ;

% %Create fit CCDFs
% expccdf = @(x0,x) exp(-x0*x);
% difccdf = @(x0,x) 1 - ( 1 - (x/x0+1).^-.5 ) ;
% hybccdf = @(x0,x) x0(1) * expccdf( x0(2), x) + (1-x0(1)) * difccdf( x0(3), x) ;


cdfs = {expccdf difccdf hybccdf};
cdfnam = {'exp^{-kx}, k=%0.2f' 'At^{-3/2},A=%0.2f' 'Mix, \\theta=%0.2f, k=%0.2f, A=%0.2f'};


%Do fits
xg = {1 2 [.5 1 1]};
lb = {0 0 [0 0 0]};
ub = {inf inf [1 inf inf]};
fts = cellfun(@(x,y,z,a) lsqcurvefit(x,y,ccx,ccy,z,a), cdfs, xg, lb, ub, 'Un', 0);
        
%Plot fit and stats
figure, plot(ccx,ccy), hold on
% set(gca, 'YScale', 'log')
cellfun(@(x,y) plot(ccx, x(y, ccx)), cdfs, fts)

legnam = cellfun(@(x,y) sprintf(x, y), cdfnam, fts, 'Un', 0);

legend([{'Data'} legnam])

out = fts;