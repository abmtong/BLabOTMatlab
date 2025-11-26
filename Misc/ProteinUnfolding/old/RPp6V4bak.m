function [out, outraw] = RPp6V4bak(inst, dir)
%Can we extract k0 and dx from refolding?
% Basically: We can calculate a 'probability that this folded now' given the force data
%I think a Constrained Optimization fminbnd, fmincon, or fseminf to minimize -logprob would work?
% So we pass it a f(x) where f(x) = @(x) fcn(xdata, x). So we need to write fcn here
%Basically, each point is a chance to unfold, given by kexp(-kx) , k = k0 exp(Fd/kT)
% We can numerically integrate this and get a probability... ? CDF is our probability?
%V3: Can we combine folding and refolding with an option? Just do both? yes
%V4: force-dependent delta, based on XWLC params. Fit delta is now in contour length

%dir = 1 for unfolding, -1 for folding. Affects sign of Fd/kT. Does both by default/isempty
if nargin < 2 || isempty(dir)
    %Just do both
    [o1, or1] = RPp6V3(inst,  1);
    [o2, or2] = RPp6V3(inst, -1);
    out = [o1 o2]; %Unfolding, folding
    outraw = [or1 or2]; 
    return
end

fil = 20;
Fs = 2500;
pPL = 0.6; %Protein persistence length, nm. delta will be scaled by XWLC(frc, pPL, inf, kT)

% fil = 1e2;
% Fs = 25e3;

kT = 4.14;
nboot = 1e1; %Boostrapping, it isn't that fast so let's do lowish
endtrim = 10; %Trim up to a few of the last points, if it started folding early

verbose = 1;
%Plotting options
fbinsz = []; %Rip force bin size, empty = FD rule of thumb

len = length(inst);
fdat = cell(1,len);
frip = nan(1,len);
rpull = nan(1,len);
ktrap = nan(1,len);
for i = 1:len
    %Get data, filter, save in fdat
    switch dir
        case 1 %Unfolding
            kicrop = 1:inst(i).ripind;
        case -1 %Folding
            kicrop = inst(i).retind:inst(i).refind;
        otherwise
            error('afewfadsf')
    end
    frc = double(inst(i).frc( kicrop ) );
    
    if isempty(frc)
        continue
    end
    %Reverse frc when filtering so it cuts off the high force end when filtering
    frcf = fliplr( windowFilter(@mean, fliplr( frc(:)' ), [], fil) );
    
    %Deal with TPs by taking the maxima in the range
    switch dir
        case 1 %Unfolding, find highest force point
            [~, maxi] = max(frcf);
            %Check if in range (within endtrim pts of end), trim if so
            if (length(frcf) - maxi) <= endtrim
                frcf = frcf(1:maxi);
            end
        case 2 %Folding, find lowest force point. Might be funny with noise, be careful
            [~, maxi] = min(frcf);
            %Check if in range (within endtrim pts of end), trim if so
            if (length(frcf) - maxi) <= endtrim
                frcf = frcf(1:maxi);
            end
    end
    %Raw just-trim-it
%     frcf = frcf(1:end-endtrim);
    
    %Get trap loading rate of the retract. Filter and trim the same way
    tpos = fliplr( windowFilter(@mean, fliplr( inst(i).tpos(kicrop) ), [], fil) );
    tpos = tpos(1:length(frcf));
    tcr = (1:length(tpos))*fil/Fs;
    %Get pulling rate
    pf = polyfit(tcr, tpos, 1);
    
    %Estimate avg trapk = frc / (pos - ext)/2
    ext = fliplr( windowFilter(@mean, fliplr( inst(i).ext(kicrop) ), [], fil) );
    ext = ext(1:length(frcf));
    tk = 2*median( frcf ./ (tpos - ext) );
    
    %Save
    ktrap(i) = tk;
    frip(i) = frcf(end);
    rpull(i) = abs(pf(1)); %Make trap pulling rate positive. Use dir to assign sign
    fdat{i} = frcf;
end
%Save raw rpull for later, in case we need it
rpullraw = rpull;
%Remove empty
ki = ~cellfun(@isempty, fdat);
fdat = fdat( ki );
frip = frip(ki);
rpull = rpull(ki);
ktrap = ktrap(ki);
inst = inst(ki);

    function lprob = fitfcn2(pulldata, ripdata, pullxw, ripxw, x0)
        %x0 = [k0, dx]
        %Can't constrain x0 so do so here? Just take abs()
        x0 = abs(x0);
        
        %Calculate k
        kk = x0(1) * exp(dir * pulldata * x0(2) .*pullxw  / kT); %k = k0 exp(Fd/kT)
        kr = x0(1) * exp(dir * ripdata * x0(2).*ripxw / kT); %k = k0 exp(Fd/kT)
        
        %Calculate -log (CCDF) = -log( exp( -kt ) ) == kt
        %             cc = exp(-kk*fil/Fs);
        lp = kk*fil/Fs;
        
        %Calculate -log(CDF) = -log( 1 - exp(-kt) );
        
        %Calculate just the unfolding pt. prob, which is just the normal cdf then
        punf = -log( 1- exp(- kr*fil/Fs) );
        
        %lprob is sum of these
        lprob = sum(lp) + sum(punf);
    end

%Calculate x-guess and k-guess
%d-guess: hard-coded at like 5nm? maybe can estimate better from like the spread of the distribution but eh
dg = 5;
%k-guess: let's say is k0 s.t. k(Funf)*dt = 0.5 = k0 exp(Fd/kT) * fil/Fs
fbar = mean( cellfun(@(x) x(end) , fdat ) );
kg = 0.5 * exp( - dir * fbar * dg / kT ) * Fs/fil;
xg = [kg dg];

%Separate and concatenate pull (no rip) and rip data points, for speed
pd = cellfun(@(x) x(1:end-1), fdat, 'Un', 0);
pd = [pd{:}];
rd = cellfun(@(x) x(end), fdat);

%Precalc XWLC
pxw = XWLC(pd, pPL, inf, kT);
rxw = XWLC(rd, pPL, inf, kT);

%And fit
ff2 = @(x) fitfcn2(pd,rd, pxw, rxw,x);
ft = fminsearch(ff2, xg); %Maybe none of these handle lower bounds? Maybe then just do like a 2D search?
ft = abs(ft); %Abs in case it went negative

%Calculate error by bootstrapping?
ffboot = cell(1,nboot);
for i = 1:nboot
    %Pick N random f's from fdat, with repetition
    ri = randi( length(fdat), 1, length(fdat) );
    fboot = fdat(ri);
    %Split to non-unfolding and unfolding parts
    pd = cellfun(@(x) x(1:end-1), fboot, 'Un', 0);
    pd = [pd{:}];
    rd = cellfun(@(x) x(end), fboot);
    %Precalc XWLC
    pxw = XWLC(pd, pPL, inf, kT);
    rxw = XWLC(rd, pPL, inf, kT);
    
    ff2boot = @(x) fitfcn2(pd,rd, pxw, rxw, x);
    ffboot{i} = abs(fminsearch(ff2boot, xg));
end
ffboot = reshape([ffboot{:}],2,[])';
ft = [ft; mean(ffboot,1); std(ffboot,1)];

%Create function to create unfolding distribution from x0,x
    function [out, outraw] = ffcf(x0,x,xw,ydat) %[k0, delta], pull ff's
        %Calculate k
        ks = x0(1) * exp(dir * x * x0(2) .* xw / kT); %k = k0 exp(Fd/kT)
        
        %Calculate chance of not unfolding at each force, = exp(-kt)
        unfchc = exp( - ks * fil/Fs ); %CCDF = exp(-kt)
        
        %Unfolding prob dist should be prod(cdf(1:i-1)) * cdf(i)
        outraw = [1 cumprod(unfchc(1:end-1))].*(1-unfchc);
        
        %Normalize, subtract data
        outraw = outraw / abs(sum( (outraw(1:end-1) + outraw(2:end))/2 .* diff(x) ) );
        out = outraw - ydat;
    end

%Calculate force histogram
if isempty(fbinsz)
    %F-D rule of thumb
    fbinsz = 2*iqr(frip)*length(frip)^-(1/3);
end
[pp, xx] = nhistc( frip, fbinsz );

%Simulate 'average' for-ext pull with no refolding
% Start from maximum tpos, Move down at dt*fpull, End at some value
% Calculate force at each using median k and median xwlc values

%First calculate trap position for the pull
tmax = double(max( arrayfun(@(x) max(x.tpos), inst), [], 'omitnan' ));
dtp = fil/Fs * median(rpull);
switch dir
    case 1 %Unfolding
        tt = tmax/2:dtp:tmax; %How far to go, trap pos wise? Say half? We want until F=3 or so, the limit ish of our detection
    case -1 %Folding
        tt = tmax:-dtp:tmax/2; %How far to go, trap pos wise? Say half? We want until F=3 or so, the limit ish of our detection
end

%Calculate median XWLCs and trapk
medxwlc = median( reshape( [inst.xwlcft], length(inst(1).xwlcft), []) , 2 )';
mtrapk = median(ktrap);

%Calculate force for these trap seps and these XWLC params
% trap sep - 2*F/k = XWLC(F, x0{1}, x0{2} ) * x0{3} + XWLC(F, x0{4}, inf) * x0{5}, solve for F
optop = optimoptions('lsqnonlin', 'Display', 'off');
ff = arrayfun(@(y) lsqnonlin( @(x) y - 2*x/mtrapk - XWLC(x, medxwlc(1), medxwlc(2))*medxwlc(3) - XWLC(x, medxwlc(6), inf)*medxwlc(7), 5, 0, inf, optop), tt);
%Precompute XWLC
ffxw = XWLC(ff, pPL, inf, kT);

%Calculate fit from curvefitting. Need to interpolate the histogram to ff
ppcf = interp1( xx, pp, ff, 'linear', 0);
xg = ft(2,:);
lb = [0 0];
ub = [inf inf];
optop2 = optimoptions('lsqnonlin', 'Display', 'off');
[ftcf, ~, rsd, ~, ~, ~, jac] = lsqnonlin(@(x0)ffcf(x0, ff, ffxw, ppcf), xg, lb, ub, optop2 );
ftcfci = nlparci(ftcf, rsd, 'jacobian', jac);
ftcfci = ftcfci(:,2)-ftcf(:);
[~,p4] = ffcf(ftcf, ff, ffxw, ppcf);

%Calculate fit data from MLE
[~,p3] = ffcf(ft(2,:), ff, ffxw, ppcf);

%Assign output
out = [ft; ftcf; ftcfci'; mean(frip), median(frip)]; %Initial MLE fit ; bootstrap MLE fit ; ci ; curvefit ; ci ; frip-bar

%Assign outraw
outraw = struct('fit', out, 'fdat', {fdat}, 'frip', frip, 'rpull', rpull, ...
                'ktrap', ktrap, 'rpullraw', rpullraw, 'fhist', [xx(:) pp(:)], ...
                'ffit', [ff(:) p3(:) p4(:)]);

%Plot. Use outraw to save on calculation time of RPp6
if verbose
    RPp6_plot(outraw);
end

end
