function out = RPp6b(inst, inOpts)
%Can we extract k0 and dx from refolding?
% Basically: We can calculate a 'probability that this folded now' given the force data
%I think a Constrained Optimization fminbnd, fmincon, or fseminf to minimize -logprob would work?
% So we pass it a f(x) where f(x) = @(x) fcn(xdata, x). So we need to write fcn here
%Basically, each point is a chance to unfold, given by kexp(-kx) , k = k0 exp(Fd/kT)
% We can numerically integrate this and get a probability... ? CDF is our probability?


%Hmm for relaxing we probably need a better F-curve
% We can get this from XWLC: tether length = trapsep-beaddiam-2*x = XWLC(kx, XWLCparams{:}) * contour length
%  And match the .... unfolding pull speed... to the F-X slope. ? Or heuristic calc the trap pos? need k?
% If we get trap sep curve, is that enough? Do we need trapk too? I think no? (trappos - ext)*k = frc ; can get k
%  Then we can get XWLC from opts.xwlcft , then we can just draw the F-X curve (no refolding) -> F=0
%   And then we can adapt this to 


fil = 1e2;
Fs = 25e3;
kT = 4.14;
nboot = 1e2; %Boostrapping, it isn't that fast so let's do lowish
endtrim = 1;

verbose = 1;

%Plotting options
fbinsz = 0.2; %Rip force bin size

%Constants
dir = -1; %1 for unfolding, -1 for folding. Affects sign of Fd/kT. Won't be changed in this file.

len = length(inst);
fdat = cell(1,len);
frip = nan(1,len);
rpull = nan(1,len);
ktrap = nan(1,len);
for i = 1:len
   %Get data, filter, save in fdat
   frc = double(inst(i).frc(inst(i).retind:inst(i).refind) );
   
   if isempty(frc)
        continue
   end
   %Reverse frc when filtering so it cuts off the high force end when filtering
   frcf = fliplr( windowFilter(@mean, fliplr( frc(:)' ), [], fil) );
   
   %Hack: Remove one pt

   frcf = frcf(1:end-endtrim);
   
%    %Get force loading rate
%    tcr = (1:length(frcf))*fil/Fs;
%    pf = polyfit(tcr, frcf, 1);
   
   %Get trap loading rate of the retract
   tpos = windowFilter(@mean, double(inst(i).tpos(inst(i).retind:inst(i).refind)), [], fil);
   tpos = tpos(1:end-endtrim);
   tcr = (1:length(tpos))*fil/Fs;
   pf = polyfit(tcr, tpos, 1);   
   %Calculate trapk too, then can calculate force loading rate of retraction
   ext = windowFilter(@mean, double(inst(i).ext(inst(i).retind:inst(i).refind)), [], fil);
   ext = ext(1:end-endtrim);
   tk = 2*median( frcf ./ (tpos - ext) );
   
   %Save
   ktrap(i) = tk;
   frip(i) = frcf(end);
   rpull(i) = -pf(1); %Make loading rate positive, I guess?
   fdat{i} = frcf;
end
%Remove empty
ki = ~cellfun(@isempty, fdat);
fdat = fdat( ki );
frip = frip(ki);
rpull = rpull(ki);
ktrap = ktrap(ki);
inst = inst(ki);

    function lprob = fitfcn(xdata, x0)
        %x0 = [k0, dx]
        %Can't constrain x0 so do so here? Just take abs()
        x0 = abs(x0);
        
        nn = length(xdata);
        outraw = nan(1,nn);
        for ii = 1:nn
            tmp = xdata{ii};
            
            %Calculate k
            kk = x0(1) * exp(dir * tmp * x0(2) / kT); %k = k0 exp(Fd/kT)
            
            %Calculate -log (CCDF) = -log( exp( -kt ) ) == kt
%             cc = exp(-kk*fil/Fs);
            lp = kk*fil/Fs;
            
            %Split off last point, as it is special (where it unfolded vs. prev = not unfolded)
            unf = lp(end);
            lp = lp(1:end-1);
            
            %Calculate just the unfolding pt. prob, which is just the normal cdf then
            punf = -log( 1- exp(- unf) ); 
            
            %Then -logprob is just sum of this
            outraw(ii) = sum(lp) + punf; 
        end
        
        %And total lprob is sum of outraw
        lprob = sum(outraw);
    end

function lprob = fitfcn2(pulldata, ripdata, x0)
        %x0 = [k0, dx]
        %Can't constrain x0 so do so here? Just take abs()
        x0 = abs(x0);
        
        %Calculate k
        kk = x0(1) * exp(dir * pulldata * x0(2) / kT); %k = k0 exp(Fd/kT)
        kr = x0(1) * exp(dir * ripdata * x0(2) / kT); %k = k0 exp(Fd/kT)
        
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
%d-guess let's say is hard-coded at like 5nm? maybe can estimate better from like the spread of the distribution but eh
dg = 5;
%k-guess let's say is k0 s.t. k(Funf)*dt = 0.5 = k0 exp(Fd/kT) * fil/Fs
fbar = mean( cellfun(@(x) x(end) , fdat ) );
kg = 0.5 * exp( - dir * fbar * dg / kT ) * Fs/fil;

xg = [kg dg];
lb = [0 0];
ub = [inf inf];

ff = @(x) fitfcn(fdat, x);
tic
ft = fminsearch(ff, xg); %Maybe none of these handle lower bounds? Maybe then just do like a 2D search?
toc
pd = cellfun(@(x) x(1:end-1), fdat, 'Un', 0);
pd = [pd{:}];
rd = cellfun(@(x) x(end), fdat);
ff2 = @(x) fitfcn2(pd,rd,x);
tic
ft2 = fminsearch(ff2, xg); %Maybe none of these handle lower bounds? Maybe then just do like a 2D search?
toc

ffboot = cell(1,nboot);
for i = 1:nboot
    %Pick N random f's from fdat, with repetition
    ri = randi( length(fdat), 1, length(fdat) );
    ff = @(x) fitfcn(fdat( ri ), x);
    ffboot{i} = fminsearch(ff, xg); %Maybe none of these handle lower bounds? Maybe then just do like a 2D search?
end
ffboot = reshape([ffboot{:}],2,[])';
ft = [ft; mean(ffboot,1); std(ffboot,1)];

%Calculate error by some metric? Bootstrapping?

out = ft;

if verbose %Plot actual force rip distribution and calculated one
    [pp, xx] = nhistc( frip, fbinsz );
    frate = median( rpull );
    niter = 1e5;
    fripsim = nan(1,1e4);
    
    %Create a model F ramp, for 10+ pN, linear is probably ok, but not for others...
    % Yeah this doesn't work well for refolding
    df = frate * fil/Fs;
%     fmax = 50;
%     ff = fliplr(df:df:fmax);

%     %So maybe try just the slowest refolder?
%     [~, mini] = min(frip);
%     ff = [fdat{mini} 0 0 0 0 0]; %Add a zeroes at the end to force folding

    %Simulate 'average' for-ext pull with no refolding
    % Start from maximum tpos
    % Move down at dt*fpull
    % End at 0
    % Calculate force at each using median k and median xwlc values
    %First calculate trap position pull
    tmax = double(max( arrayfun(@(x) max(x.tpos), inst), [], 'omitnan' ));
    dtp = fil/Fs * median(rpull);
    tt = tmax:-dtp:tmax/2; %How far to go, trap pos wise? Say half? We want until F=3 or so, the limit ish of our detection
    %Calculate force median XWLCs
    medxwlc = median( reshape( [inst.xwlcft], length(inst(1).xwlcft), []) , 2 )';
    mtrapk = median(ktrap);
    %Calculate force for these trap seps and these XWLC params
    % trap sep - 2*F/k = XWLC(F, x0{1}, x0{2} ) * x0{3} + XWLC(F, x0{4}, inf) * x0{5}, solve for F (with lsq)
    optop = optimoptions('lsqnonlin', 'Display', 'off');
    len = length(tt);
%     ff = nan(1,len);
%     for i = 1:len
%         ff(i) = lsqnonlin( @(x) tt(i) - 2*x/mtrapk - XWLC(x, medxwlc(1), medxwlc(2))*medxwlc(3) - XWLC(x, medxwlc(6), inf)*medxwlc(7), 5, 0, inf, optop)
%     end
    ff = arrayfun(@(y) lsqnonlin( @(x) y - 2*x/mtrapk - XWLC(x, medxwlc(1), medxwlc(2))*medxwlc(3) - XWLC(x, medxwlc(6), inf)*medxwlc(7), 5, 0, inf, optop), tt);

    %Calculate chance of not unfolding at each force, = exp(-kt)
    ks = out(1,1) * exp(dir * ff * out(1,2) / kT); %k = k0 exp(Fd/kT)
    unfchc = exp( - ks * fil/Fs ); %CCDF = exp(-kt)
%     for i = 1:niter
%         %Roll dice and get unfolding force
%         rnum = rand(size(unfchc));
%         funf = ff( find(unfchc < rnum, 1, 'first') );
%         if ~isempty(funf)
%             fripsim(i) = funf;
%         end
%     end
%     [p2, x2] = nhistc( fripsim, fbinsz);% floor( fbinsz/df) * df ); %Bin should be in multiples of df

%Is this easily solvable ? like a 'cumprob' kind of thing
    % Should be prod(cdf(1:i-1)) * ccdf(i), I guess: yes, easy with cumprob
%     figure, plot(ff, cumprod(unfchc).*(1-unfchc) )
    p3 = [1 cumprod(unfchc(1:end-1))].*(1-unfchc);
    p3 = p3 / abs(sum( (p3(1:end-1) + p3(2:end))/2 .* diff(ff) ) );
    figure, hold on
    plot(xx,pp)
%     plot(x2,p2)
    plot(ff,p3);
    legend({'Rip force' 'Simulated from fit'})
end



end




