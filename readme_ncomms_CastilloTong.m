%{
Readme for Code and Software Submission Checklist for 'A DNA packaging motor inchworms along one strand allowing it to adapt to alternative double-helical structures'

System requirements:
 Matlab : Code was written and run on ver. R2016a. Compatability with other versions of Matlab is presumed but not guaranteed.
  Required toolboxes: Curve Fitting Toolbox (for some)

Installation guide:
 Unzip the code. Most code requires some dependencies, running ./startup.m should add the required paths.

Instructions for Analysis:
 The code used for each analysis is listed here, more detailed instructions can be found in the files themselves.
 Velocities:
  Velocities were calculated using ./DataGUIs/Velocity/vdist_batch.m
   This was used to find the velocity distribution for the four substrates.
 Pairwise Distribution:
  PWDs were calculated using ./DataGUIs/PairwiseDist/sumPWDV1bMoff.m
   This was used to find the pairwise distance distributions for the four substrates.
 Stepfinding:
  Low-force stepfinding was done using the Kalafut-Visscher stepfinding algorithm, implemented in ./DataGUIs/StepFind_KV/AFindStepsV5.m
   This was used to find dwelltimes and to analyze burst-sized slipping.
 HMM Stepfinding:
  High-force stepfinding was done using ./DataGUIs/StepFind_HMM/findStepHMMV2.m
   This was used to find the step size on dsDNA and DTS Hybrid.

Demo:
 To simulate an example trace, use ./DataGUIs/Helpers/simtrace.m
  This trace can be passed as the first argument to any of the above functions to test their operation. The codes will plot the result automatically.
   Most operations should take up to a few seconds, but the HMM stepfinder may take longer (minutes)
%}
