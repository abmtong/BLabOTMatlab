function out = avgPullsV2(inst, xwlcg)
%Input: output of getFirstPull

%Averages together some pulls by V2: ext
% Basically: Align to some force, interp, average together

%Options
fil = 500; %Need to filter through the mirror oscillations. That's 60Hz , so filter at least 42pts at 2.5kHz
if nargin < 2
    % xwlcg = [50 1300]; %OK for HiRes 4kb
    xwlcg = [55 397]; %For HiRes 2kb
    % xwlcg = [30 397]; %Messing around a bit
end

%bin for interpolation
binsz = 1;
bin = -75:binsz:50;

% fcr = 13; %13 for ext ~ con
fcr = 7; %Choice for a point past LF but before +F HF

%Data cropping options
xlf = 20 + 4 * [-1 1]; %LF size
xhf = 24 + 4 * [-1 1]; %HF size

figure Name avgPulls
hold on
ax1 = gca;
xlabel( 'Extension (nm, rel)')
ylabel( 'Force (pN)')

figure name plotCon
hold on
ax2 = gca;
xlabel( 'Extension (nm, rel)')
ylabel( 'Contour (nm, rel)')
len=length(inst);
cs = cell(1, len);
fs = cell(1, len);
for i = 1:len
    tt = inst(i).ext;
    ff = inst(i).frc;
%     tt = inst(i).tsep;
    
    if isempty(ff)
        continue
    end
    
    %Apply crop
    if isfield(inst, 'xwlc')
        lfsz = inst(i).xwlc(4);
        hfsz = inst(i).xwlc(5) - inst(i).xwlc(4);
        if lfsz < xlf(1) || lfsz > xlf(2)
            continue
        end
        if hfsz < xhf(1) || hfsz > xhf(2)
            continue
        end
        
        
    end
    
    %Filter
    tt = windowFilter(@median, tt, [], fil);
    ff = windowFilter(@median, ff, [], fil);
%     tt = windowFilter(@median, tt, [], fil);
    
%     cc = tt ./ XWLC(ff, xwlcg(1), xwlcg(2));
    cc = windowFilter(@median, inst(i).con, [], fil);
    
    %Zero by some reference force, say just past LF (7pN)
    ind = find(ff > fcr, 1, 'first');
    if isempty(ind)
        continue
    end
    x0 = tt(ind);
    f0 = ff(ind);
    c0 = cc(ind);
%     t0 = tt(ind);
    
    %Apply zero
    tt = tt-x0;
%     ff = ff-f0; Don't zero F, don't have to
    cc = cc-c0;
%     tt = tt-t0;
    
    plot(ax1, tt, ff)
    plot(ax2, tt, cc)
    
    %Interp to our grid. Use NaN for outsiders
    fq = interp1(tt, ff, bin, 'linear', nan);
    cq = interp1(tt, cc, bin, 'linear', nan);
    
    %And save
    fs{i} = fq;
    cs{i} = cq;
end


%Average together, plot average line thick
fs = reshape([fs{:}], length(bin), [])';
cs = reshape([cs{:}], length(bin), [])';

%Calculate stats
xm = mean(fs, 1, 'omitnan');
cm = mean(cs, 1, 'omitnan');

xsd = std(fs, 1, 'omitnan');
csd = std(cs, 1, 'omitnan');

xn = sum( ~isnan(fs), 1 );
cn = sum( ~isnan(cs), 1 );

%And plot
plot(ax1, bin, xm, 'k', 'LineWidth', 1)
plot(ax2, bin, cm, 'k', 'LineWidth', 1)

%rows: t, xmean, xsd, xn, fmean, fsd, fn
out = [bin; xm; xsd; xn; cm; csd; cn];



