%"New" moved to Phi29_Alex

%{
Need to bin for speed, clarity purposes (at least a little for @lsqnonlin - using 625k points - amt doesnt seem to matter)

Start bin location doesn't really matter (~0.3%)

Does the form of our optimizing fcn matter?
Inv    : (1/L - 1/P) * 1/S, 1/S = P, = P/L -1
Weight : (L-P)*S = L/P -1 (same as ^)
Fit log: log(L) - log(P) = log(L/P)
All same (~0.1%) - all optimize in some extent L/P
optimizing fcn doesnt really matter (as long as it weights the power values equally (since log distributed)
Inv (the one the paper uses) might converge faster? (slightly faster runtime - all still only 30-40ms)
I personally like log better, so I will use log (weight distances on log-log equally). Inv weights lower power stronger

al&f3 vs f3 only: ~1% difference (al has a bound ([0, 1]) which might be a hassle to enforce - solver seems to keep it in)

Guesses are very important, one from FitLorentzian is pretty good (Alias guess for f3 just returns Fs every time)
 Constant guess is also ok, but may be wrong if bead size changes dramatically
 Tweezercalib guesses FitLorentzian, 0.3, and Fs
 Empirically, ends up near FitLorentzian guess, .4, and 26e3
 > Use FitLorentzian, 0.3, fNyq

Using logspace (evenly spaced log points) gives a visibly worse fit, ~2% different k*a
 Still, low frequency fitting is poor (or maybe just data is poor / too little info) - maybe try a longer cal file?

%}