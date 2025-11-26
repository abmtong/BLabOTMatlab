function out = RPp6(inst, inOpts)
%Can we extract k0 and dx from pulling? Yes?
% Basically: We can calculate a 'probability that this unfolded now' given the force data
%I think a Constrained Optimization fminbnd, fmincon, or fseminf to minimize -logprob would work?
% So we pass it a f(x) where f(x) = @(x) fcn(xdata, x). So we need to write fcn here
%Basically, each point is a chance to unfold, given by kexp(-kx) , k = k0 exp(Fd/kT)
% We can numerically integrate this and get a probability... ? CDF is our probability?

fil = 100;
Fs = 25000;
kT = 4.14;

verbose = 1;

%Plotting options
fmin = 7; %Get force loading rate from fmin:frip linear fit
fbinsz = 1; %Rip force bin size

%Constants
dir = 1; %1 for unfolding, -1 for folding. Affects sign of Fd/kT. Won't be changed in this file.

len = length(inst);
fdat = cell(1,len);
frip = nan(1,len);
rpull = nan(1,len);
for i = 1:len
   %Get data, filter, save in fdat
   frc = double(inst(i).frc(1:inst(i).ripind) );
   
   %Reverse frc when filtering so it cuts off the low force end when filtering
   frcf = fliplr( windowFilter(@mean, fliplr( frc(:)' ), [], fil) );
   
   %Remove last
   frcf = frcf(1:end-1);
   fdat{i} = frcf;
   frip(i) = frcf(end);
   
   %Get force loading rate-- only good for high enough f rip
   fcr = frcf( find(frcf > fmin, 1, 'first'):end );
   if length(fcr) < 9
       continue
   end
   tcr = (1:length(fcr))*fil/Fs;
   pf = polyfit(tcr, fcr, 1);
   rpull(i) = pf(1);
   
end


    function lprob = fitfcn(xdata, x0)
        %x0 = [k0, dx]
        %Can't constrain x0 so do so here?
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

ft = fminsearch(ff, xg); %Maybe none of these handle lower bounds? Maybe then just do like a 2D search?

out = ft;

if verbose %Plot actual force rip distribution and calculated one
    [pp, xx] = nhistc( frip, fbinsz );
    frate = median( rpull );
    niter = 1e5;
    fripsim = nan(1,1e4);
    df = frate * fil/Fs;
    fmax = 50;
    ff = df:df:fmax;
    %Calculate chance of not unfolding at each force, = exp(-kt)
    ks = out(1) * exp(dir * ff * out(2) / kT); %k = k0 exp(Fd/kT)
    unfchc = exp( - ks * fil/Fs ); %CCDF = exp(-kt)
    for i = 1:niter
        %Roll dice and get unfolding force
        rnum = rand(size(unfchc));
        funf = ff( find(unfchc < rnum, 1, 'first') );
        if ~isempty(funf)
            fripsim(i) = funf;
        end
    end
    
    [p2, x2] = nhistc( fripsim, floor( fbinsz/df) * df ); %Bin should be in multiples of df
    figure, hold on
    plot(xx,pp)
    plot(x2,p2)
    legend({'Rip force' 'Simulated from fit'})
end



end




