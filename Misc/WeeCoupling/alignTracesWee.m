function out = alignTracesWee(inst)


%Align traces: get the average RTH, then shift each individually by some amount
% to maximize self-similarity (dot product with avg RTH), then iterate

% I write some code in the past to do this for ElRo I think? but that was for cyc perm.

%Hmm, for the Sat NTPs case the shifts are very small (within 1bp), so maybe we don't need to do this?
% Just use a bp range to account. Shifts for other cases are wider, but could be due to traces not finishing.
%  Let's try traces that finish only...

searchwid = 20; %Search width, bp shift plus-minus
binsz = 0.1; %RTH binsz, also is the search step size. Note that number of search points = range(searchwid)/ssz
xrng = [0 141] + [-10 20]; %Search range, the transcript range plus a bit wider (+ searchwid?)
ysd = 4; %STD, ~ noise of traces, which is ~4bp in this case

prcco = 70; %Cut off at 70th percentile of peak heights (?)

%Calculate RTH with sumNucHist? kdf? sNH but then gaussian filter?
%Repeat info
snhopts.pauloc = 59;
snhopts.per = 64;
snhopts.n = 0;
%Nuc info
snhopts.disp = [63 96 155 204]-63; %Start P1, HP, Ter, per Wee
snhopts.disp2 = [62 67 79 100 115 124 131 141 167 187 211]-63+1; %Guess 


snhopts.shift = 0;
snhopts.verbose = 0;
snhopts.roi = xrng;

acmaxlag = round(searchwid/binsz); %'maxlag' for @acorr for calculating shifts
searchxs = (-acmaxlag:acmaxlag)*binsz;
len = length(inst);
for i = 1:len
    %Get these data
    tmp = inst(i).con;
    
    %Crop to crossers only (say, > xrng(2))
%     ki = true(size(tmp));
    ki = cellfun(@max, tmp) > 140;
    tmp = tmp(ki);
    
    %Calc RTHs for each of these
    [yy, xx] = cellfun(@(x) kdf(x, binsz, ysd, xrng), tmp, 'Un', 0);
    
    %Hmm, maybe handle broken tethers = nans afterwards? so averaging skips them?
    
    
    %All xx's should be the same, so lets just use one
    xx = xx{1};
    
    %Let's set an upper bound by findpeaks
    pkhts = cellfun(@findpeaks, yy, 'Un', 0);
    pkhts = [pkhts{:}];
    maxt = prctile(pkhts, prcco);
    
    %Apply max
    yymx = cellfun(@(x) min(x, maxt), yy, 'Un', 0);
    
    %And let's optimize
    
    
    hei = length(tmp);
    xshfts = zeros(1,hei);
%     iter = 0;
    
    %Make a mean RTH (median?)
    yavg = mean( reshape([yy{:}], length(yy{1}), []), 2, 'omitnan' );
    yavgmx = min(yavg, maxt);
    %For every trace
    for j = 1:hei
        %Find best shift to match the 0
        [~, maxi] = max( xcorr( yavgmx, yymx{j}, acmaxlag ) ); %Acorr = 'shift the second term'
        xshfts(j) = xshfts(j) + searchxs(maxi);
        
    end
    
    %Add to struct
    xshftsnan = nan(1, length(ki));
    xshftsnan(ki) = xshfts;
    inst(i).shift = xshftsnan;
    
    %Remake RTH with this new guy and compare?
    
    figure('Name', sprintf('aTW Compare %s', inst(i).name))
    hold on
    plot(xx, yavg)
    hold on
    [oldy, oldx] = sumNucHist( tmp, snhopts);
    [newy, newx] = sumNucHist( cellfun(@(x,y) x + y, tmp, num2cell(xshfts), 'Un' , 0), snhopts);
    plot(oldx, oldy / mean(oldy, 'omitnan') * mean(yavg, 'omitnan'))
    plot(newx,newy  / mean(newy, 'omitnan') * mean(yavg, 'omitnan'))
    legend({'Original KDF' 'Original' 'Aligned'})
    %Plot lines at disp locs:
    %Green lines at disp locs
    yl=ylim;
    for j = 1:length(snhopts.disp)
        plot([1 1]*snhopts.disp(j), yl, 'g')
    end
    %Red lines at disp2 locs
    for j = 1:length(snhopts.disp2)
        plot([1 1]*snhopts.disp2(j), yl, 'r')
    end
    
end
%Check if shift values are 'gaussian-like' (should look logistic-y)
figure('Name', sprintf('aTW Compare Shift Dists'))
hold on
for i = 1:len
    y = inst(i).shift;
    x = (1:length(y))/length(y);
    plot(x,sort(y))
end
legend({inst.name})
out = inst;
