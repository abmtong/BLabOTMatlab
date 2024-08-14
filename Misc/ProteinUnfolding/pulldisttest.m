function out = pulldisttest()

%Over each range, look for how each fit value is affected by input params

%Seems like t, s only affect mean force (log)
% dx affects all (mean and sd are power law? not log ; linear with skewness)

t0 = 3;
trng = 1:10;

s0 = 10;
srng = logspace(-1,2,20);

d0 = 3;
drng = 1:10;

len=length(trng);
tc = cell(1, len );
for i = 1:len
    tc{i} = pulldist(trng(i), s0, d0, 0);
end
plotresults(tc, trng)

len=length(srng);
sc = cell(1, len );
for i = 1:len
    sc{i} = pulldist(t0, srng(i), d0, 0);
end
plotresults(sc, srng)

len=length(trng);
dc = cell(1, len );
for i = 1:len
    dc{i} = pulldist(t0,s0, drng(i), 0);
end
plotresults(dc, drng)


end


function plotresults(cc, xx)
figure
mtx = reshape([cc{:}], 4, [])';
plot(xx, mtx)
legend({'Favg' 'SD' 'Skew' 'Height'})
end

