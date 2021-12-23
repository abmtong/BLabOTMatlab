function out = rulerAlignV2p2(tra, inOpts)

%Now aligns against the consensus histogram instead of itself

%Generate consensus histogram
[hy, hx, hyraw] = sumNucHist(tra, inOpts);

%At least plot each separately?
figure, hold on
plot(hx, hy, 'Color', 'k', 'LineWidth', 2)
cellfun(@(x) plot(hx, x), hyraw)

%Find best least-squares fit?