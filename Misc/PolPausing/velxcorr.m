function out = velxcorr(dwfas, dwslo, xrng)

if nargin < 3
    xrng = [0 inf];
end

%For each trace in fas + slo, get the speed and check their xcorr

%Speed of fast

len = length(dwfas);
pfvs = zeros(len,2);
pden = zeros(len,2);

for i = 1:len*2
    if i <= len
        df = dwfas{i};
    else
        df = dwslo{i-len};
    end
    if max(df) > 0.5
        ft = fitbiexp(df, xrng, 1, 0);
        f = ft.ft;
        [pfvs(i), in] = max( f([2 4]) );
        pden(i) = 1- f(in*2-1) / sum(f([1 3]));
    else %Fit only one exp
        ft = fitbiexp(df, xrng, 3, 0);
        f = ft.ft;
        pfvs(i) = f(2);
        pden(i) = 0;
    end
end

%Scatters:
figure Name Fvel_vs_Svel
scatter(pfvs(:,1),pfvs(:,2))

out.fspd = pfvs(:,1);
out.sspd = pfvs(:,2);

out.fden = pden(:,1);
out.sden = pden(:,2);

