function [out, munew] = linfitV2(mu)

%Now fit to 16+1 params (nucleotide + position) instead of 4+1
% Without bounds, goes wild, with bounds, looks maybe something?
% Most values per nt are the same/similar, overall fit not much better
% STD of residual = 3.5 [not much better than  4+1fit, 5]
%x0 is in order [A1 A2 A3 A4 T1 T2 T3 T4 ... G4, offset]

cod = arrayfun(@num2cdn, 1:256, 'Un', 0);
cod = reshape([cod{:}],4,[])';

fitfcn = @(x0) evalmu(x0,cod) - mu;

ub = 20 * ones(1,17);
lb = -20 * ones(1,17);
gu = ones(1,17)*5;

ft = lsqnonlin(fitfcn, gu, lb, ub);
out = ft;

%Check goodness-of-fit
munew = evalmu(ft, cod);

%Then just everything vs. everything
figure, subplot(3,1, [1 2]), hold on

plot(1:256, munew, 'o')
plot(1:256, mu, '*', 'Color', [.7 .7 .7]);
for i = 1:256
    plot([i i], [munew(i) mu(i)], 'r')
end

%Plot rsd
subplot(3,1,3), hold on
plot([1 256], [0 0], 'k')
for i = 1:256
    plot([i i], [0 munew(i) - mu(i)], 'r')
end

    function pa = evalmu(x0, x)
        %x is codon array
        sqr = reshape(x0(1:16),4,4);
        pa = zeros(1,size(x,1));
        for j = 1:size(x,1)
            pa(j) = x0(17) + sqr(x(j,1),1) + sqr(x(j,2),2) +sqr(x(j,3),3) +sqr(x(j,4),4);
%             pa(j) = x0(17) + sum(arrayfun(@(ii, jj) x0( sub2ind([4 4], ii,jj) ), x(j,:), 1:4));
        end
    end
end