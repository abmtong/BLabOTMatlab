%{
Stepfinding Notes

K-V
-Params: Penalty (has default = log(length(trace)), is tunable)
-Quick to perform
-Heavily dependent on filtering, as penalty is independent of SNR
--Hack: Noise-based penalty seems to work

Hst
-Params: Penalty (has default = 9*noise, is tunable)
-Can take into account bead dynamics
-Computationally intensive

ChSq
-Params: None!
-Stopping criteria is finicky sometimes
--Too many steps: could be that stepping signal is too weak (for that filter, at least)
--Too few steps: Strange spike in xfit early on, maybe cheat a bit here (ignore first few pts)

DWT
-Params: Xform iteration, Peak finding
-Nearly instantaneous
-Peaks are smooth (looks like waveform), so easy to select, all peaks are steps

MSF
-Params: Window size, Peak finding, numSteps
-Peaks are jagged, sometimes bunched (finicky to select)
-Prefers large steps (proportional to step height, might be unreasonable)
-Hack: No stopping point: Counterfit like ChiSq, then (height = priority)

LEIA
-Params: Peak finding
-Find peaks in (x + x'').^2, smoothed by 'LEIA'
--Smoothing needs severe rewrite, unusable as-is
--Could try different smoothing fcn, if desperate
%}