function plotNucSeqsFlipV2(seqs, strand, inOpts)
%Plots visualization for a group of sequences

opts.name = '';
opts.filwid = 3; %Filter width, should be odd
             %601 sequence, fetched from doi.org/10.1038/s41598-020-66259-4 [not the original source]
% opts.six01 = 'CTGGAGAATCCCGGTGCCGAGGCCGCTCAATTGGTCGTAGACAGCTCTAGCACCGCTTAAACGCACGTACGCGCTGTCCCCCGCGTTTTAACCGCCAAGGGGATTACTCCCTAGTCTCCAGGCACGTGTCAGATATATACATCCTGT';
if nargin > 2
    opts = handleOpts(opts, inOpts);
end

figure('Name', opts.name )

%Make strand col vector
strand = strand(:);

%Plot GC content over time for strand= 0/1/-1
subplot2([2 1], 1);
len = length(seqs{1});
hold on
for i = -1:1
    mtx = reshape( upper([seqs{strand == i}]), len, [] );
%     nA = sum( mtx == 'A', 2);
%     nT = sum( mtx == 'T', 2);
    nGC = sum( mtx == 'G' | mtx == 'C', 2)';
%     nC = sum( mtx == 'C', 2);
    gcpct = windowFilter(@mean, 1-nGC / size(mtx, 2), (opts.filwid-1) /2, 1);
    if i == -1
        gcpct = gcpct(end:-1:1);
    end
    plot(gcpct);
end
axis tight
line(xlim(), 7519412/12157086 * [1 1]); %Plot a line at the genome-wide average GC content, this value is hard-coded for Yeast right now
legend({'-(flipped)' '0' '+' 'Avg AT'})
title('AT Content')
% xlabel('Position (bp)')
ylabel('%AT')

%Plot flexibility with calcflex
subplot2([2 1], 2);
hold on
flexs = cellfun(@(x) windowFilter(@mean, calcflex(x), (opts.filwid-1) /2, 1) , seqs, 'Un', 0);
for i = -1:1
    tmp = flexs(strand == i);
    flx = mean(  cell2mat( tmp(:) ), 1 );
    if i == -1
        flx = flx(end:-1:1);
    end
    plot(flx)
end
axis tight
legend({'-(flipped)' '0' '+'})
title('AverageFlex')
ylabel('DNA flexibility (avg., arb.)')
xlabel('Position (bp)')
%Draw a line at the center

yl = ylim;
xl = xlim;
plot(mean(xl) * [1 1], yl, 'k')
plot(mean(xl) * [1 1]+146/2, yl, 'k')
plot(mean(xl) * [1 1]-146/2, yl, 'k')

