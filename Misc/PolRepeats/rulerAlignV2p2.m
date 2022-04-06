function [out, outdiff] = rulerAlignV2p2(tra, inOpts)
%After rulerAlignV2, check for repeat shifting up/down
%So, align against the consensus histogram instead of itself

%Maybe also align with outside regions? Those ~should~ also be seq-dep.

opts.alignmeth = 1; %1 = just repeats, 2 = whole RTH
opts.normmeth = 0; %0 = none, 1 = per-bp norm'zation

opts.binsz = 0.5;
opts.per = 258; %Just need period
opts.persch = [-1 0 1]; %Try + these period multiples
opts.nrep = 8;
opts.Fs = 1e3;
opts.histfil = 10;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Generate consensus histogram
histopts.per = opts.per;
histopts.normmeth = 2; %s/bp
histopts.Fs = opts.Fs;
histopts.fil = opts.histfil;
switch opts.alignmeth
    case 1
        histopts.roi = [0 opts.nrep * opts.per];
    case 2
        histopts.roi = [-inf inf];
end
[hy, hx, hyraw] = sumNucHist(tra, histopts);

len = length(tra);
outdiff = zeros(1,len);
hei = length(opts.persch);

for i = 1:len
    scrs = zeros(1,hei);
    for j = 1:hei
        %Generate this trace's RTH, with shift
        [ty, tx] = sumNucHist(tra{i} + opts.persch(j) * opts.per, histopts);
        %Crop to same x's
        xmin = max( min(tx), min(hx) );
        xmax = min( max(tx), max(hx) );
        tki = tx >= xmin & tx <= xmax;
        hki = hx >= xmin & hx <= xmax;
        
        ydiff = ty(tki) - hy(hki);
        switch opts.normmeth
            case 1 %per-bp: div by hy
                ydiff = ydiff ./ hy;
            otherwise
        end
        scrs(j) = mean(ydiff.^2); %Then just take mean score=least squares?
        
        
    end

end

%At least plot each separately?
figure, hold on
plot(hx, hy, 'Color', 'k', 'LineWidth', 2)
cellfun(@(x) plot(hx, x), hyraw)

%Find best least-squares fit?