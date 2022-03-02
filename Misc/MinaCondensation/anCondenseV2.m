function out = anCondenseV2(trs, inOpts)


opts.ycut = 1500; %bp, cut traces once they cross here. To remove end pausing?
opts.tcut = 10; %s, cut traces after this length of time

%Define vdist options
opts.sgp = {1 1001}; %"Savitzky Golay Params"
opts.vbinsz = 10; %Velocity BIN SiZe
opts.Fs = 1e3; %Frequency of Sampling
opts.velmult = -1;%Set decreasing to positive
opts.vfitlim = [-inf inf]; %Velocity to fit over
opts.verbose = 0;
opts.debug = 0;

%kdfsfind opts
opts.fpre = {10,1}; %pre filter
opts.binsz = 5; %bin size, for kdf and hist
opts.kdfsd = 5; %kdf gaussian sd
opts.histdec = 2; %Step histogram decimation factor
opts.histfil = 5; %Filter width for step histogram
opts.kdfmpp = .5; %Multiplier to kdf MinPeakProminence
opts.histfitx = [0 15]; %X range to fit histfit to
opts.rmburst = 0; %Remove bursts in kdfdwellfind
opts.verbose = 0; %Plot
opts.histdec = 10;


if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(trs);
outneg = cell(1,len);
outzero = cell(1,len);
outpos = cell(1,len);
for i = 1:len
    segneg = [];
    segzero = [];
    segpos = [];
    %Filter/differentiate
    [tv, tf, tc] = cellfun(@(x) sgolaydiff(x, opts.sgp), trs{i}, 'Un', 0);
    
    %Take median negative and positive value
    if i == 1
        kineg = cellfun(@(x) x < 0, tv, 'un', 0);
        kipos = cellfun(@(x) x > 0, tv, 'un', 0);
        medneg = cellfun(@(x,y) median(x(y)), tv,kineg);
        medpos = cellfun(@(x,y) median(x(y)), tv, kipos);
        medneg = median(medneg);
        medpos = median(medpos);
        medneg = -.5;
        medpos = +.5;
    end
    %Maybe combine medneg/medpos to just one value?
    
    %Fit to HMM
%     mdl = cellfun(@(t,x,y) stateHMMV2(t, struct('mu', [x 0 y], 'sig', 0.1, 'verbose', opts.debug)), tv, num2cell(medneg), num2cell(medpos), 'Un', 0);
mdl = cellfun(@(t,x,y) stateHMMV2(t, struct('mu', [medneg 0 medpos], 'sig', 0.1, 'verbose', opts.debug)), tv, 'Un', 0);
    mdl = [mdl{:}];
    sthmm = {mdl.fitnoopt}; %=1/2/3 if vel is neg/0/pos
    
    %Debug plot
    if opts.debug
        plnum = randi(length(trs{i}));
        figure, surface([1:length(tv{plnum}); 1:length(tv{plnum})]/opts.Fs, [tf{plnum}; tf{plnum}], zeros(2, length(tv{plnum})), [sthmm{plnum}; sthmm{plnum}], 'EdgeColor', 'interp')
        hold on
        colormap([0 1 0; 1 0 0; 0 0 1]) %Grn = neg vel, red = 0 vel, blue = pos vel
    end

    %Gather sections
    [ins, mes] = cellfun(@tra2ind, sthmm, 'Un', 0);
    for j = 1:length(ins)
        in = ins{j};
        me = mes{j};
        for k = 1:length(me)
            tmp = tc{j}(in(k):in(k+1)-1);
            switch me(k)
                case 1 %Neg
                    segneg = [segneg {tmp}]; %#ok<AGROW>
                case 2 %Zero
                    segzero = [segzero {tmp}];  %#ok<AGROW>
                case 3 %Pos
                    segpos = [segpos {tmp}]; %#ok<AGROW>
                otherwise
            end
        end
    end
    outneg{i} = segneg;
    outzero{i} = segzero;
    outpos{i} = segpos;
end

figure Name Vel, hold on
cols = arrayfun(@(x) hsv2rgb(x, 1, .7), (0:len-1)/len, 'Un', 0);
for i = 1:len
    [hpneg, hxneg] = nhistc([outneg{i}{:}]*opts.Fs, opts.vbinsz);
    [hppos, hxpos] = nhistc([outpos{i}{:}]*opts.Fs, opts.vbinsz);
    
    plot(-hxneg, hpneg, 'Color', cols{i})
    plot(-hxpos, hppos, 'Color', cols{i}, 'LineStyle', ':')
    
end

out.neg = outneg;
out.zero = outzero;
out.pos = outpos;

% %kdfstepfind
% figure Name Steps
% hold on
% for i = 1:len
%     %Do kdfstepfind
%     [~, sszneg] = cellfun(@(x) kdfsfindV2(x, opts), outneg{i}, 'Un', 0);
%     [~, sszpos] = cellfun(@(x) kdfsfindV2(x, opts), outpos{i}, 'Un', 0);
%     
%     [hpneg, hxneg] = nhistc([sszneg{:}], opts.histdec);
%     [hppos, hxpos] = nhistc([sszpos{:}], opts.histdec);
%     
%     xtot = [-fliplr(hxpos) 0 hxneg];
%     ytot = [ fliplr(hppos) 0 hpneg];
%     plot(xtot, ytot);
% end




