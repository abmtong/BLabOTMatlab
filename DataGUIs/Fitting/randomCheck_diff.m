function out = randomCheck_diff(seq)

%Check differing distributions of diff(seq)
% I guess the idea is if there are state correlations, there will be more near-0 diff's

dseq = ( diff(seq) );
len = length(seq);
if len == 1
    out = 1;
    return
end

%Make kdf options
dy = iqr(dseq) / (len-1)^(1/3) *10; %F-D rule *10
ysd = dy * 5;
yrng = ceil([max(seq) - min(seq)] / dy) * dy * [-1 1];

[dskdf, xx] = kdf(dseq, dy, ysd, yrng);

%Resample
nstrap = 1e4;
rs = cell(1,nstrap);
for i = 1:nstrap
    rs{i} = seq(randi(len, 1, len));
end


kds = cellfun(@(x) kdf((diff(x)), dy, ysd, yrng), rs, 'Un', 0);

%Combine for kdf
drs = cellfun(@diff, rs, 'Un', 0);
bskdf = kdf([drs{:}], dy, ysd, yrng);

figure, plot(xx, dskdf/ sum(dskdf)), hold on, plot(xx, bskdf / sum(bskdf))

figure, plot(xx, dskdf/sum(dskdf), 'LineWidth', 2), hold on, cellfun(@(x) plot(xx, x/sum(x)), kds(1:100:end))

%Some sort of test to see if they're different ?

