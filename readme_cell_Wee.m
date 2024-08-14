%{
Readme for submission to Cell for manuscript:
    A trailing ribosome speeds up RNA polymerase at the expense of transcript fidelity via force and allostery

Section: Determining pause free velocity (PFV) and pause density
Fitting the raw data to a monotonic staircase was done by hidden markov model fitting.
    The model states are a grid 1bp wide, and the chain can only move to the next state.
    Dwells that were >0.5s are considered a pause, so contribute to pause density and the corresponding data removed from PFV calculation
    Code in /DataGUIs/StepFind_HMM/fitVitterbiV3.m
Calculating velocity distributions from data was done by a Savitzky-Golay differentiatiating filter
    The data was filtered with a S-G differentiating filter of order 1, width 101 pts (= 75ms at 1333Hz) to transform position data to velocity data.
    The velocities were binned together and fit to a sum of two Gaussians, one with mean 0 and one with positive mean.
    Code in /DataGUIs/Velocity/vdist.m
%}
