function out = weescatter(dws, xrng)
%varargin is args of fitbiexp

if nargin < 2
    xrng = [0 inf];
end

len = length(dws);
pfvs = zeros(1,len);
pden = zeros(1,len);

for i = 1:length(dws)
    d = dws{i};
    if max(d) > 0.5
        ft = fitbiexp(d, xrng, 1);
        f = ft.ft;
        [pfvs(i), in] = max( f([2 4]) );
        pden(i) = 1- f(in*2-1) / sum(f([1 3]));
    else %Fit only one exp
        ft = fitbiexp(d, xrng, 3);
        f = ft.ft;
        pfvs(i) = f(2);
        pden(i) = 0;
        
    end
end
figure, scatter(pfvs, pden*100)
xlabel('k_N')
ylabel('Pause Eff.%')

out.pfvs = pfvs;
out.pden = pden;