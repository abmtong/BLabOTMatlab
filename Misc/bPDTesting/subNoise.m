function out = subNoise()

%Pick data
[f1, p1] = uigetfile('*.dat');
%Pick baseline
[f2, p2] = uigetfile('*.dat');


lfopts.Instrument = 'HiRes';
lfopts.Fs = 3.5e6;
lfopts.lortype = 1;
lfopts.Fmax = 2e4;

dat1 = loadfile_wrapper([p1 f1]);
dat2 = loadfile_wrapper([p2 f2]);

datsub = dat1.BX - dat2.BX;

figure, Calibrate(datsub, lfopts);