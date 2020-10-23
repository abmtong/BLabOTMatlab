function [ft ,out]= linfitcdn(mu)
%Get the correlation between [number of bases of X type] and the current
%With mu_debru, T seems anticorrelated with current, so if perhaps U is positive correlated with current, the large net increase in R can be accounted for
%STD of residual is 5

ns = length(mu);
nA = zeros(1,ns);
nT = zeros(1,ns);
nG = zeros(1,ns);
nC = zeros(1,ns);

for i = 1:ns
    cdn = num2cdn(i);
    nA(i) = sum(cdn == 1);
    nT(i) = sum(cdn == 2);
    nG(i) = sum(cdn == 3);
    nC(i) = sum(cdn == 4);
end

cod = [nA' nT' nG' nC'];

%Fit to linear of offset + linear with A/T/G/C
fitfcn = @(x0) x0(1:4) * cod' + x0(5) - mu;
gu = ones(1,5)*5;
ft = lsqnonlin(fitfcn, gu);

%Check goodness-of-fit by seeing 'linearity' along T

%Groups of two codons
figure, hold on
plotcdn('A', 'r', -.1);
plotcdn('G', 'b', 0);
plotcdn('C', 'g', .1);

%Then just everything vs. everything
figure, subplot(3,1, [1 2]), hold on
out = ft(1:4) * cod' + ft(5);
plot(1:256, out, 'o')
plot(1:256, mu, '*', 'Color', [.7 .7 .7]);
for i = 1:256
    plot([i i], [out(i) mu(i)], 'r')
end

%Plot rsd
subplot(3,1,3), hold on
plot([1 256], [0 0], 'k')
for i = 1:256
    plot([i i], [0 out(i) - mu(i)], 'r')
end

fprintf('Mean deviation %0.2f, Mean Abs Dev %0.2f\n', mean(out-mu), mean(abs(out-mu)));

    function pf = plotcdn(chr, colchr, offx)
    fity = zeros(1,5);
    mny = zeros(1,5);
    for ii = 0:4
        %Generate string
        str = char(['T' * ones(1,ii) chr(1) * ones(1,4-ii)]);
        %Generate permutations
        pms = perms(str);
        %Get only unique strings
        pms = unique(mat2cell(pms, ones(1,24), 4));
        %For each, get the state's value
        pmst = mu(cellfun(@cdn2num, pms));
        
        mny(ii+1) = mean(pmst);
        %Plot the point
        plot((offx+ii) * ones(1,length(pmst)), pmst, 'o', 'Color', .7 * ones(1,3))
        plot((offx+ii), mean(pmst), [colchr 'o']);
        plot((offx+ii)*[1 1], mean(pmst) + [-1 1] * std(pmst), colchr)
        %Calculate fit point
        switch chr
            case 'A'
                n = 1;
            case 'T'
                n = 2;
            case 'G'
                n = 3;
            case 'C'
                n = 4;
        end
        fx = [0 ii 0 0];
        fx(n) = 4-ii;
        fity(ii+1) = ft(1:4) * fx' + ft(5);
    end
    %Plot fit points
    plot((0:4) + offx, fity, colchr, 'LineWidth', 2)
end
end







