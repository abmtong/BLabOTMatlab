function out = fitoritest2(infp)

if nargin < 1
    [f, p] = uigetfile();
    if ~p
        return
    end
    infp = fullfile(p,f);
end

cd = load(infp);

cd = cd.ContourData;

xx = cd.extension;
yy = cd.forceBX - cd.forceAX;
yy = yy/2;


dsamp = 3e3;

xxf = double( windowFilter(@mean, xx, [], dsamp) );
yyf = double( windowFilter(@mean, yy, [], dsamp));
xxsd =double( windowFilter(@std, xx, [], dsamp));

%Crop to max F
[~, maxi] = max(yyf);
maxi = maxi - 1;
xxf = xxf(1:maxi);
yyf = yyf(1:maxi);
% xxsd = xxsd(1:maxi);


%Divide into three regions based on force

f1 = 1;
f2 = 2;

ind1 = find(yyf > f1, 1, 'first');
ind2 = find(yyf > f2, 1, 'first');

%Ignore second region, crop

xxf1 = xxf(1:ind1);
yyf1 = yyf(1:ind1);
xxf2 = xxf(ind2:end);
yyf2 = yyf(ind2:end);

%Create region bool
tfrip = [zeros(1, length(xxf1)) ones(1, length(xxf2))];

%Assemble fit vars
xxfit = [xxf1 xxf2];
yyfit = [yyf1 yyf2];

%Guess. PL, SM, CL, dCL
xg = [50 2000 280 5];
lb = [0 0 0 0];
ub = [1e5 1e5 1e5 100];
fitfcn = @(x0,x) XWLC(x, x0(1), x0(2)) .* (x0(3) + tfrip*x0(4));


ft = lsqcurvefit(fitfcn, xg, yyfit, xxfit, lb, ub);
% 
% 
% 
% 
% % %Min f
% % minf = 0;
% % ind = find(yyf > minf, 1, 'first');
% % xxf = xxf(ind:maxi);
% % yyf = yyf(ind:maxi);
% % xxsd = xxsd(ind:maxi);
% 
% 
% 
% 
% 
% ft = lsqnonlin(@fitfcn, xg, lb, ub);
% 
fg = figure; hold on
plot(xxf, yyf, 'Color', [.7 .7 .7]);
plot( XWLC( yyfit, ft(1), ft(2))*ft(3), yyfit, 'b')
plot( XWLC( yyfit, ft(1), ft(2))*(ft(3)+ft(4)), yyfit, 'r')
% 
fg.Name = sprintf('%0.2f %0.2f %0.2f %0.2f', ft);
% 
% function [fcn, rsd] = fitfcn(x0)
%     xnew = XWLC( yyf, x0(1), x0(2) ) * x0(3);
%     
%     dx = xnew(:) - xxf(:);
%     dxwgt = dx(:) ./ xxsd(:);
%     
%     fcn = dxwgt .^2;
%     fcn = fcn(:);
%     rsd = dxwgt;
% end

out = ft;

end

