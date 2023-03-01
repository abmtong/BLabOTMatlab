function plotNucSeqsFlip(seqs, seqsflip, inOpts)
%Plots visualization for a group of sequences

opts.name = '';
opts.filwid = 3; %Filter width, should be odd
             %601 sequence, fetched from doi.org/10.1038/s41598-020-66259-4 [not the original source]
opts.six01 = 'CTGGAGAATCCCGGTGCCGAGGCCGCTCAATTGGTCGTAGACAGCTCTAGCACCGCTTAAACGCACGTACGCGCTGTCCCCCGCGTTTTAACCGCCAAGGGGATTACTCCCTAGTCTCCAGGCACGTGTCAGATATATACATCCTGT';
if nargin > 1
    opts = handleOpts(opts, inOpts);
end

figure('Name', opts.name , 'Color', [1 1 1])

% %Plot 'average' nucleosome with @seqlogo
% figure('Name', [opts.name ' SeqLogo'] ), seqlogo(seqs)
% Sequence is not specific enough for @seqlogo, so let's do just a bar instead
subplot2([3 1], 1);
len = length(seqs{1});
mtx = reshape( upper([seqs{:}]), len, [] );
nA = sum( mtx == 'A', 2);
nT = sum( mtx == 'T', 2);
nG = sum( mtx == 'G', 2);
nC = sum( mtx == 'C', 2);
bar([nA nT nG nC] / length(seqs), 'stacked')
axis tight
legend({'A' 'T' 'G' 'C'})
title('NucFreq NoFlip')
hold on
line(xlim(), 7519412/12157086 * [1 1]); %Plot a line at the genome-wide average AT content, this value is hard-coded for Yeast right now

%Plot flexibility with calcflex
ax = subplot2([3 1], 3);
len = length(seqs);
avgflex = zeros(1, length(seqs{1})-1 ); %-1 since flexibility is per dinucleotide
for i = 1:len
    avgflex = avgflex + windowFilter(@mean, calcflex(seqs{i}), (opts.filwid-1) /2, 1);
end
avgflex = avgflex / len;
title(ax, 'AverageFlex')
plot(avgflex)
ylabel('DNA flexibility (avg., arb.)')
xlabel('Position (bp)')
%Draw a line at the center
axis tight
% yl = ylim();
% xl = xlim();
hold on
% plot( mean(xl) * [1 1], yl, 'k')
% plot( mean(xl) * [1 1]+146/2, yl, 'k')
% plot( mean(xl) * [1 1]-146/2, yl, 'k')

% %Plot 'average' nucleosome with @seqlogo
% figure('Name', [opts.name ' SeqLogo'] ), seqlogo(seqs)
% Sequence is not specific enough for @seqlogo, so let's do just a bar instead
subplot2([3 1], 2);
len = length(seqsflip{1});
mtx = reshape( upper([seqsflip{:}]), len, [] );
nA = sum( mtx == 'A', 2);
nT = sum( mtx == 'T', 2);
nG = sum( mtx == 'G', 2);
nC = sum( mtx == 'C', 2);
bar([nA nT nG nC] / length(seqsflip), 'stacked')
axis tight
legend({'A' 'T' 'G' 'C'})
title('NucFreq Flip')
hold on
line(xlim(), 7519412/12157086 * [1 1]); %Plot a line at the genome-wide average AT content, this value is hard-coded for Yeast right now

%Plot flexibility with calcflex
len = length(seqsflip);
avgflex = zeros(1, length(seqsflip{1})-1 ); %-1 since flexibility is per dinucleotide
for i = 1:len
    avgflex = avgflex + windowFilter(@mean, calcflex(seqsflip{i}), (opts.filwid-1) /2, 1);
end
avgflex = avgflex / len;
plot(ax, avgflex)
legend(ax, {'NoFlip', 'Flip'})
%Draw a line at the center
axis tight
yl = ylim(ax);
xl = xlim(ax);
hold on
plot(ax, mean(xl) * [1 1], yl, 'k')
plot(ax, mean(xl) * [1 1]+146/2, yl, 'k')
plot(ax, mean(xl) * [1 1]-146/2, yl, 'k')

