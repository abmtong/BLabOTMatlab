function [out, muraw] = seqHMMp3(inmus, verbose)
%Gather together the mu's from multiple seqHMMp2 outputs and consolidate result to new mu

if iscell(inmus)
    tmp = [];
    for i = 1:length(inmus)
        tmp = [tmp; inmus{i}]; %#ok<AGROW>
    end
    inmus = tmp;
end

mux = inmus(:,1);
muy = inmus(:,2);

mumax = max(256, max(mux)); %Should be 256

muout = zeros(1,mumax);%Mean
musd = zeros(1,mumax); %SD
munn = zeros(1,mumax); %N
muraw = cell(1,256);   %Raw data
for i = 1:mumax
    %Find inmu that matches i
    dat = muy(mux == i);
    muout(i) = mean(dat);
    musd(i) = std(dat);
    munn(i) = length(dat);
    muraw{i} = dat;
end

out = [muout' musd' munn'];

%Plot x, y, std. Missing values are NaNs, make them -1 to make them more visible
x = 1:mumax;
y = muout;
y(isnan(y)) = -1;
e = musd;
e(isnan(e)) = 0;

if verbose
    figure, plot(y,x,'o'), hold on
    %Don't like @errorbar for errorbars, so plot as lines. Also label with codon
    xmax = max(y) + max(musd);
    nt = 'ATGC';
    for i = 1:mumax
        line([y(i) - e(i), y(i) + e(i)], i * [1 1]);
        text(xmax, i, ['—' nt(num2cdn(i))]);
    end
    xlim([-3 + min(y), xmax+3])
    ylim([0 mumax+1])
end