function PSD = WiggleCal_Lorentzian(Param,F)
% This function calculates the Lorentzian. It will be used to fit the Power
% Spectrum Density of experimentally measured power spectra for calibration
% purposes
%
% PSD means Power Spectrum Density
% Fc - corner Frequency
% F - frequency
% D - diffusion constant
%
% Gheorghe Chistol, 19 April 2011
D = Param(1);
Fc = Param(2);
PSD = D*(1+(F/Fc).^2).^(-1);