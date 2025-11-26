function out = RP_hop_kfold(inst)
%Calculate kfold(F) from RP_hop data that goes to different forces

Fs= 25e3;
kT = 4.1;

%For each one...
len = length(inst);
outraw = nan(len, 3); %Ffold, Tfold, censor
for i = 1:len
    tmp = inst(i);
    
    %Calculate refolding time: 3 timepoints, retract (start), refold (if exists), and end
    t0 = tmp.retind;
    t1 = tmp.refind;
    t2 = length(tmp.frc) - t0;
    if isempty(t1)
        %Didn't refold in alloted time: Get lower bound (right-censored) folding time
        outraw(i,:) = [ median( tmp.frc(t0:t2) ), (t2-t0)/Fs, 1 ];
    else
        %Refolded in alloted time: Get folding time
        outraw(i,:) = [ median( tmp.frc(t0:t1) ), (t1-t0)/Fs, 0 ];
    end
end

%MLE fit to tau_fold -> k exp(-kt), k = k0 exp(-Fd/kT) : fit params [k0 d]
% for @mle, fh is @(data, a, b, c, ...) -- here data is [t(:) f(:)];
% Easy to 
mlelpdf = @(x, k0, d) log(k0) + -imag(x).*d/kT + - k0 * exp( -imag(x).*d/kT) .* real(x);
mlelccdf = @(x, k0, d) - k0 * exp( -imag(x).*d/kT) .* real(x);
% mlepdf = @(x, k0, d) k0 * exp( -imag(x).*d/kT) .* exp(- k0 * exp( -imag(x).*d/kT) .* real(x));
% mlecdf = @(x, k0, d) 1 - exp(- k0 * exp( -imag(x).*d/kT) .* real(x));
mleccdf = @(x, k0, d) exp(- k0 * exp( -imag(x).*d/kT) .* real(x));
kf = @(F,k0,d) k0 * exp( - F * d / kT);
mlex = outraw(:,2) + i * outraw(:,1); %tau_refold + i*force

datcross = outraw( outraw(:,3) == 0, : );

dg = 5; %dx guess, say 5nm?
kg = exp( median( datcross(:,1) ) * dg / kT ) / median(datcross(:,2)); %k0 guess, since k = 1/median(tau) = k0 exp(-Fd/kT ) , k0 = exp(Fd/kT)/median(tau)
xg = [kg dg];
lb = [0 0];
ub = [inf inf];
ft = mle( mlex, 'logpdf', mlelpdf, 'logsf', mlelccdf, 'Start', xg, 'LowerBound', lb, 'UpperBound', ub, 'Censoring', outraw(:,3) );
% ft
%IT WORKS??? values are whack though. 

%Double-check: plot data as CCDF with fits ... separated by force? Separated by filename.

%Separate by filename
ff = {inst.file};
[~, ~, ic] = unique( ff );
figure Name RPhopkfold_check
hold on
ax = gca;
len = max(ic);
lgn = cell(2,len);
rawdat2 = nan(len,2);
for i = 1:len;
    %Get this data
    ki = ic == i;
    tmp = outraw(ki,:);
    
    %Separate real and censored data? Or just sort the censored data to the end? Just don't plot them?
%     xx = sort(tmp(:,2));
    yy = fliplr( 1:size(tmp,1) ) / size(tmp,1);
    xx = sort( tmp( tmp(:,3) == 0 , 2 ) ) ;
    xx = [xx(:)' nan(1, length(yy)-length(xx) )]';
    
    co = ax.ColorOrderIndex;
    plot(xx,yy);
    ax.ColorOrderIndex = co;
    %Plot fit at this force
    mf = median( tmp(:,1) );
%     plot(xx, mleccdf( xx + sqrt(-1)*mf, ft(1), ft(2)) , '--')
    
    %Individual mle fits. Matlab exp is exp(-t/tau), not exp(-kx), so invert result
    kfit = mle( tmp(:,2), 'Distribution', 'exp', 'Censoring', tmp(:,3) );
    kfit = 1/kfit;
    plot(xx, exp(-kfit*xx), '--')

%     %fitnexp_hybrid?
%     kfit = fitnexp_hybridV2(tmp( tmp(:,3) == 0 , 2 )' , struct('verbose', 0));
%     kfit = kfit(1,2); %Just take first k
%     plot(xx, exp(-kfit*xx), '--')
    
    lgn{1,i} = sprintf('%0.1f pN, k=%0.2f/s', mf, kfit);
    lgn{2,i} = 'Fit';
    
    rawdat2(i,:) = [kfit mf]; %k, f
end
legend(lgn(:))

figure
xx = rawdat2(:,2);
[xx, si] = sort(xx);
yy = log( rawdat2(:,1) );
yy = yy(si);
plot( xx, yy );
pf = polyfit(xx,yy,1);
%Slope of polyfit is dx/kT, so multiply by kT to get dx
dx = -pf(1)*kT;
k0 = exp(pf(2));
title(sprintf('Folding, dx = %0.2fnm, k0 = %0.2f/s', dx, k0))
hold on
plot(xx, polyval(pf, xx), '--')





