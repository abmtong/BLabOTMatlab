function rulerAlignV2p2_byeye(tra, inOpts)
%Just plot the histogram vs. the consensus, numbered and with guides
%I guess just make N=length(tra) plots, with guide lines, with buttons that shift left/right (and alters title)


opts.binsz = 0.5;
opts.per = 258; %Just need period
opts.nrep = 8;
opts.Fs = 1e3;
opts.histfil = 10;
opts.lims = [-100 700 2]; %[xlim, ylim(2)]

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Generate consensus histogram
histopts.per = opts.per;
histopts.normmeth = 2; %s/bp
histopts.Fs = opts.Fs;
histopts.fil = opts.histfil;
histopts.binsz = opts.binsz;
histopts.roi = [-inf inf];
histopts.verbose = 1;
histopts.shift = 0;

% nwid = opts.per/opts.binsz;
% %Make consensus repeat histogram
% i0 = find(hx >= 0, 1, 'first');
% tmp = reshape(hy( i0+(0:nwid*opts.nrep-1) ), nwid, opts.nrep);
% avgrth = median(tmp, 2)';

len = length(tra);

for i = 1:len
    %Make a figure with the consensus histogram
    sumNucHist(tra, histopts);
    fg = gcf;
    fg.Name = sprintf('RulerAlign byeye %02d', i);
    %Plot individual RTH
    [ty, tx] = sumNucHist(tra{i}, setfield(histopts, 'verbose', 0)); %#ok<SFLD>
    ll = plot(tx, ty);
    %Add button
    uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ 0, 0, .05, .1], 'String', '<', 'Callback',@(x,y) shiftrth(x,y,ll,-opts.per) );
    uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ .05, 0, .05, .1], 'String', '>', 'Callback',@(x,y) shiftrth(x,y,ll,opts.per) );
    %Set lims
    xlim(opts.lims(1:2))
    ylim([0 opts.lims(3)])
end

end

function shiftrth(src, ~, ob, amt)
    set(ob, 'XData', get(ob, 'XData') + amt)
    set(src.Parent, 'Name', sprintf('%s %d',src.Parent.Name , amt) );
end

% out = cellfun(@(x,y) x - y, tra, num2cell(outdiff), 'Un', 0);
%
% %At least plot each separately?
% figure, hold on
% plot(hx, hy, 'Color', 'k', 'LineWidth', 2)
% cellfun(@(x) plot(hx, x), hyraw)
% 
% %Find best least-squares fit?