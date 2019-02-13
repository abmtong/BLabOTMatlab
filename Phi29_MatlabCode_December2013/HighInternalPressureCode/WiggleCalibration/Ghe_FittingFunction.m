function hh = Ghe_FittingFunction(scal_fit,parameters,xfin,yfin,sfin)
% The function minus the data divided by the error sfin
% This function is used for fitting, I still don't quite understand it
% Refer to the Tolic-Norrelykke et al. Computer Phys Communications 159 (2004)
% yfin - actual data, y axis, i.e. power spectrum density
% xfin - actual data, x axis, i.e. frequency
% sfin - some sort of weight for each data point
% hh   - weighted difference between the actual data and the expected
% power spectrum, which includes parasitic filtering from the detector and
% aliasing effects.
%
% USE: hh = Ghe_FittingFunction(scal_fit,parameters,xfin,yfin,sfin)
%
% Gheorghe Chistol, 27 April 2011

hh = (1./Ghe_PowerSpectrum_Aliased_DiodeFiltered(scal_fit,parameters,xfin) - 1./yfin) ./ sfin;
