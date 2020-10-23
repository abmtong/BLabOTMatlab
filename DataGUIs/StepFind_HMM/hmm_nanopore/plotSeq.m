function plotSeq(tr, mu, st, kept)
%Plots the output of HMM Nanopore sequencing analysis

figure Name Plot_Nanopore_Sequencing
plot(tr, 'Color', [.7 .7 .7]);
hold on
plot(mu(st), 'LineWidth', 1, 'Color', 'b')
axis tight

%Translate state change to sequences
[in, me] = tra2ind(st);
seqtmp = arrayfun(@num2cdn, me, 'Un', 0);
seqtmp = [seqtmp{:}];
seqi = seqtmp([1 2 3 4:4:end]);
cdns = 'ATGC';
seq = cdns(seqi);

%Add 10% to extent of each axis to label sequence, states
xl = xlim;
xlim(xl + [0 0.1*range(xl)])
yl = ylim;
ylim(yl + [-0.1*range(yl) 0]);

%Plot text at midpoints of steps, at bottom edge
xs = (in(1:end-1) + in(2:end)) /2;
y = yl(1) + -0.05*range(yl);

if nargin < 4
    kept = true(1, length(xs));
end

%First text is full codon, next steps are single nucleotides
text(xs(1), y, seq(1:4), 'HorizontalAlignment', 'center')
text(xs(1), mu(me(1)), seq(1:4), 'HorizontalAlignment', 'center')
for i = 2:length(xs)
    if kept(i)
        clr = [0 0 0];
    else
        clr = [.5 0 0];
    end
    text(xs(i), y, seq(i+3), 'HorizontalAlignment', 'center', 'Color', clr)
    text(xs(i), mu(me(i)), seq(i+3), 'HorizontalAlignment', 'center', 'Color', clr)
end

%List states' mu's on edge
iskip = false(1,length(mu));
for i = 1:length(mu)
    if iskip(i)
        continue
    end
    %If any codons have the same mu, plot them together
    ii = mu(i) == mu;
    iskip = iskip | ii;
    %Construct string of codons
    istrs = arrayfun(@(x)horzcat(cdns(num2cdn(x, 4)), ' ') , find(ii), 'Un', 0); 
    text( xl(2), mu(i), ['—' [istrs{:}]], 'VerticalAlignment', 'middle' )
end
