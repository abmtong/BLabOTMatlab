function [out, outraw] = fitVitterbi_batch(dat, inOpts)
%Do fitVitterbi, then plot Dwtd

%Plotting options
opts.verbose = 1;
opts.binsz = 0.02; %Bin size
opts.tscal = 1; %Scale time for... reasons?
opts.Fs = 1000; %Trace sampling frequency

%Alignment options: Should we try to align the step size ?
opts.alignkdf = 0;

%Opts also needs the options for fitVitterbi, most notably:
opts.ssz = 1; %Spacing of states
opts.off = 0; %Offset of states
opts.dir = 1; %1 for POSITIVE only, -1 for NEG only, 0 for BOTH
opts.trnsprb = 1e-3; %Transition probability.

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if nargin < 1 || isempty(dat)
    dat = getFCs;
end

if ~iscell(dat)
    dat = {dat};
end
len = length(dat);

outraw = cell(1,len);
ins = cell(1,len);
pipe = '|';
fprintf(['[' pipe(ones(1,len)) ']\n[\n'])

for i = 1:len
    if opts.alignkdf
        [y, x] = kdf(dat{i}, 0.1);
        [~,mx] = max(y);
        opts.off = x(mx);
    end
    
    outraw{i} = fitVitterbiV3(dat{i}, opts);
    ins{i} = tra2ind(outraw{i});
    fprintf('\b-\n')
end
fprintf('\b]\n')

din = cellfun(@diff, ins, 'Un', 0);
out = cellfun(@(x) x/opts.Fs, din,'Un',0);

dws = [out{:}];
%Plot
if opts.verbose
    figure('Name', 'Batch fitVitterbi')
    subplot(3,1,[1 2])
    %Plot data and fit
    hold on
    cellfun(@(x) plot((1:length(x))/opts.Fs, x, 'Color', [.7 .7 .7]), dat);
    cellfun(@(x) plot((1:length(x))/opts.Fs, x), outraw);
    subplot(3,1,3)
    hold on
    %Plot histogram
%     [hy, hx] = nhistc(out, opts.binsz);
%     plot(hx,hy)
    
    %Plog ccdf on semilog
    plot( sort(dws), 1- (1:length(dws))/length(dws) )
    set(gca, 'YScale', 'log')
    %For 1exp, this will be a
end





