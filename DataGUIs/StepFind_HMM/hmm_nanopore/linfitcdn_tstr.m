function [out, outraw] = linfitcdn_tstr(data, seq, mu0, dU, dO)

%Test every combo of things in dU, dO

%Get number of Ts in every codon
nT = arrayfun(@(x) sum(num2cdn(x) == 2), 1:256);

len = length(dU);
wid = length(dO);

for i = len:-1:1
    for j = wid:-1:1
        %Update mu0
        mu = mu0 + nT * dU(i) + dO(j);
        %Do testHMMNP on this mu
        [~, res] = optHMMNP(data, mu, seq);
        %Use number of points fit as test of goodness
        np = sum(cellfun(@length, res));
        out(i,j) = np;
        outraw{i,j} = res;
    end
end





