%IterateStepHist Notes
%{
Normalizing P
-Independent of total steps (divide by it)
-Proper "probability" (divide by len)

Skewing P for large steps
-P = P * x (step height)
--x^2, x^3 work similarly; both seemingly better than without

Smoothing P
-Doesn't seem to make much of a difference resultwise, converges faster with no smoothing (since you get 0s early, which go P = exp(-50)
-Probably better to smooth, as there just might be "unlucky" step heights which get 0'd out early on

Filtering Trace
-Hist doesn't like outliers, but they seem to go away anyway after iter.s

From one trace:
-Unfiltered RNA 7-12: Whole burst 8.2bp step 
-50kHz DNA MnW1D1: Sub-steps 2.3bp step

NEXT STEP: BATCH DATA



Expect: RNA = 0.9*DNA


%}