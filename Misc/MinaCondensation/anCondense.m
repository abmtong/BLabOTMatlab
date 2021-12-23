function out = anCondense(trs, inOpts)

%Define vdist options
opts.sgp = {1 2001}; %"Savitzky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 1e3; %Frequency of Sampling
opts.velmult = -1;%Set decreasing to positive
opts.verbose = 0;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

[vy, vx] = cellfun(@(x) vdist(x, opts), trs, 'Un', 0);

figure('Name', 'anCondense', 'Color', [1 1 1])
hold on
cellfun(@(x,y,z) plot(x,y,'Color', z), vx, vy, arrayfun(@(x) hsv2rgb(x, 1, .7), (0:length(vx)-1)/length(vx), 'Un', 0)  )

vdist_batch(trs, opts);
