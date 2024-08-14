function out = fitoritest(infp)

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
% xxf = xxf(1:maxi);
% yyf = yyf(1:maxi);
% xxsd = xxsd(1:maxi);

%Min f
minf = 0;
ind = find(yyf > minf, 1, 'first');
xxf = xxf(ind:maxi);
yyf = yyf(ind:maxi);
xxsd = xxsd(ind:maxi);



xg = [50 2000 300];
lb = [0 0 0 ];
ub = [1e5 1e5 1e5];

ft = lsqnonlin(@fitfcn, xg, lb, ub);

fg = figure; hold on
plot(xxf, yyf, 'Color', [.7 .7 .7]);
plot( XWLC( yyf, ft(1), ft(2))*ft(3), yyf, 'b')

fg.Name = sprintf('%0.2f %0.2f %0.2f', ft);

function [fcn, rsd] = fitfcn(x0)
    xnew = XWLC( yyf, x0(1), x0(2) ) * x0(3);
    
    dx = xnew(:) - xxf(:);
    dxwgt = dx(:) ./ xxsd(:);
    
    fcn = dxwgt .^2;
    fcn = fcn(:);
    rsd = dxwgt;
end



end

