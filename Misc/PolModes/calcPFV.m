function out = calcPFV(dat, inOpts)


opts.sgp = {1 401};
opts.Fs = 800;
opts.vbinsz = .5;
opts.verbose = 0;


%Run vdist
len = length(dat);
% vx = cell(1,len);
% vy = cell(1,len);
% ft = cell(1,len); %Fit, as normpdf mean, sd, amp x2

[vy, vx, ~, ~, ~, ft] = cellfun(@(x) vdist(x, opts), dat, 'Un', 0);

%Get pfv, ft{i}(4)

pfvs = cellfun(@(x) x(4), ft);

figure, plot(sort(pfvs))

figure, hold on, cellfun(@(x) plot(windowFilter(@mean, x, [], 20)), dat(pfvs < prctile(pfvs, 25)))