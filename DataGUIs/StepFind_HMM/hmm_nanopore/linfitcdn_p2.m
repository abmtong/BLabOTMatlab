function out = linfitcdn_p2(dat, seq, mu0, newft)

%Mu_debru gives linear correlation values of [11.131 3.1268 6.6386 7.6362 9.9282] for [A T G C offset]
% Weird how A >> T 
%newft = [dT, dOffset]

binsz = 0.1;
xs = 0:binsz:100;
%From dat, generate histogram
hy = histcounts(dat, xs);

%Get number of Ts in every codon
nT = arrayfun(@(x) sum(num2cdn(x) == 2), 1:256);

hei = size(newft, 1);

figure('Name', sprintf('dU: %0.2f, do: %0.2f', newft(1,:)))
hold on
%Plot kdf
plot(xs(1:end-1)+binsz/2,hy/max(hy))
out = cell(1,hei);
lbl = cell(1,hei);
for i = 1:hei
    %Make new mu
    munew = mu0 + nT * newft(i,1) + newft(i,2);
    
    %Get points with seq2st
    s = seq2st(seq, munew);
    
    %Make kdf
    [ky, kx] = kdf(s, binsz, 1);
    
    %Plot
    plot(kx,ky/max(ky))
    
    out{i} = munew;
    lbl{i} = sprintf('[%0.2f, %0.2f]', newft(i,:));
end
legend([{'Data'} lbl])