function out = plotDataBands(dat, inOpts)

opts.Fs = 1e3;
opts.prc = [25 75]; %Which percentiles to take
opts.hue = [1 .1]; %Hue to plot around
opts.ax = [];

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Extend dats with final values

maxlen = max(cellfun(@length, dat));
for i = 1:length(dat)
    dat{i} = [dat{i} nan(1, maxlen - length(dat{i}))];
end

tmp = reshape( [dat{:}] , maxlen, [] )';

yup = prctile(tmp, opts.prc(2), 1);
ymd = median(tmp, 1, 'omitnan');
ylo = prctile(tmp, opts.prc(1), 1);

%Get axis
if isempty(opts.ax)
    opts.ax = gca;
end
hold(opts.ax, 'on')

%Plot data
cellfun(@(x,y) plot(opts.ax, (1:length(x))/opts.Fs , x , 'Color', hsv2rgb(y, 1, .7)), dat, num2cell( mod(rand(1,length(dat)) * opts.hue(2) *2 + opts.hue(1) - opts.hue(2) ,1) ) )

%Plot bands
xx = (1:length(ylo))/opts.Fs;
xx = [xx fliplr(xx)];
facealpha = 0.15;
patch( opts.ax, xx, [ylo fliplr(yup)], zeros(1, 2* length(ylo)), zeros(1, 2* length(ylo)), 'FaceColor', zeros(1,3), 'FaceAlpha', facealpha )

%Plot median
plot( opts.ax, (1:length(ylo))/opts.Fs, ymd, 'LineWidth', 1, 'Color', 'k')

out = ymd;

