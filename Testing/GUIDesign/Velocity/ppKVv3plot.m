function ppKVv3plot(inst, inOpts)
%Input is output from ppKVv3

opts.fbin = [5 15 25 35]; %Bin force by this amts

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

nfbin = length(opts.fbin)-1;

%Plot in a nfbin x 2 [for tl vs bt] array
fg = figure('Name', sprintf('PhagePauseKVv3 Plot %s', inputname(1)));
axbt = arrayfun(@(x)subplot2(fg, [nfbin, 2], x), 1:nfbin,'Un',0);
axbt = [axbt{:}];
axtl = arrayfun(@(x)subplot2(fg, [nfbin, 2], x), nfbin+(1:nfbin),'Un',0);
axtl = [axtl{:}];
arrayfun(@(x)hold(x,'on'), [axbt axtl])
arrayfun(@(x)axis(x,'tight'), [axbt axtl])

plotbtstr(axtl, inst.tl, opts.fbin);
plotbtstr(axbt, inst.bt, opts.fbin);
end


function plotbtstr(axs, inbt, fbin)
hts = ones(1,length(fbin)-1)*9e3;
dht = 20;
smoothfact = 10;
for i = 1:length(inbt)
    fin = find(inbt(i).frc > fbin(1:end-1) & inbt(i).frc < fbin(2:end),1);
    if isempty(fin)
        continue
    end
    tr = inbt(i).tra;
    kv = ind2tra(inbt(i).ind, inbt(i).mea);
    x = (1:length(tr))/2500; %Hard-coded Fs
    %Normalize contour by mean(1)
    plot(axs(fin), x, smooth(tr-inbt(i).mea(1)+hts(fin),smoothfact)')
    plot(axs(fin), x, kv-inbt(i).mea(1)+hts(fin),'k', 'LineWidth', 1)
    hts(fin) = hts(fin) - dht;
end
end

