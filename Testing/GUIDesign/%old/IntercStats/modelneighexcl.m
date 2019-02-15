function [sites, ninterc] = modelneighexcl(intrat)


Pg = @(n, r, g) ((1-n*r)/(1-(n-1)*r)).^g * r / (1 - (n - 1)*r);

s = @(n, r) (1-n*r)/r * ((1-n*r)/(1-(n-1)*r))^(n-1);

nEtBr = 2.35; %DOI: 10.1063/1.2768945


len=4000;

pdf = Pg(2, intrat, 1:500);
pdf = pdf / sum(pdf); %normalize, will be close to 1 but non-1 due to chopping of distribution

cdf = cumsum(pdf);

sites = zeros(1, len);

i = 1;
while i < len
    %roll for size of gap
    [~, curgap] = find( rand < cdf, 1);
    %apply gap
    intpos = i + curgap + 1; %+1 since n=2
    if intpos < len
        sites(intpos) = 1;
    end
    %update i
    i = intpos;
end

fprintf('Average interc amt of %0.3f\n', sum(sites)/len);

ninterc = zeros(1,6); %count of number of intercalants per 10bp, {0 1 2 3 4 5} are possible answers
for i = 1:10 %loop over every "reading frame"
    for j = 1:len/10-1
        %extract segment
        indsta = 10*(j-1)+i;
        inden = 10*j+i-1;
        %count num interc
        ni = sum(sites(indsta:inden));
        %update var
        ninterc(ni+1) = ninterc(ni+1)+1;
    end
end

plot(0:5, ninterc/sum(ninterc))




