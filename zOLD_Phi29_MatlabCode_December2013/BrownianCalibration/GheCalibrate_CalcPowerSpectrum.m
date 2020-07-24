function [freq, P, T] = GheCalibrate_CalcPowerSpectrum(X, sampling_f)
% This is a simple function that calculates a power-spectrum given a
% time-series of data (i.e. vector X) and the data acquisition frequency f.
% It's a modification of calc_powerspec.m from the TweezerCalib2.1 suite,
% but without global variables and such.
%
% USE: [f, P, T] = GheCalibrate_CalcPowerSpectrum(X, sampling_f)
%
% Gheorghe Chistol, 2 Feb 2012

    fNyq    =   sampling_f / 2;
    delta_t =   1 / sampling_f;

    time    =   delta_t*(0 :length(X)-1)';
    T       =   time(end); %the duration of the time-series
    freq       =   ( (1:length(X)) /T )';

    % Calculate the Power using FFT
    FT      =   delta_t*fft(X);
    P       =   FT .* conj(FT) / T;
    
    % Consider only data up to the Nyquist frequency 
    ind     =   (freq <= fNyq); 
    freq    =   freq(ind);
    P       =   P(ind);
end
