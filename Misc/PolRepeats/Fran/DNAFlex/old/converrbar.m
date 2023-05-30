function converrbar(in, tfsem)

if nargin < 2
    tfsem = 1;
end

%Converts input data (columns) to errorbar (mean, sd)

mn = mean(in, 2, 'omitnan');
sd = std(in, [], 2, 'omitnan');

if tfsem
    sd = sd / sqrt( size(in,2) );
end

errorbar(mn, sd);



