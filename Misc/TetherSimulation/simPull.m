function simPull(texts, inOpts)
%plot a trap ext - bead ext curve
%moving traps by X yields a ~62% movement in beads

if nargin < 1
    texts = 1300:1:1400;
end

exts = zeros(size(texts));
opts.verbose = 0;
if nargin > 1
    opts = handleOpts(opts, inOpts);
end

for i = 1:length(texts)
    opts.trapsep = texts(i);
    exts(i) = TetherSim(opts);
end

figure, plot(texts, exts)