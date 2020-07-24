function diff = WiggleCal_Lorentzian_lsqnonlin(Param,F,PSD)
% This particular function is used with LSQNONLIN, which is different from
% other fitting functions in matlab. See the following link:
% http://www.mathworks.com/support/tech-notes/1500/1504.html
% This function calculates the Lorentzian. It will be used to fit the Power
% Spectrum Density of experimentally measured power spectra for calibration
% purposes
% takes into account parasitic filtering
% PSD - measured Power Spectrum Density
% F - frequency
% Fc - corner Frequency
% D - diffusion constant
%
% Gheorghe Chistol, 19 April 2011
D    = Param(1);
Fc   = Param(2);
F3db = Param(3); %diode filtering frequency
a    = Param(4); %alpha for the diode
diff = (D*(1+(F/Fc).^2).^(-1)).*(a+(1-a)./(1+(F/F3db).^2)) - PSD;