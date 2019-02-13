function PSD = WiggleCal_Lorentzian_DiodeFiltering(Param,F)
% This function calculates the Lorentzian. It will be used to fit the Power
% Spectrum Density of experimentally measured power spectra for calibration
% purposes
% This one takes into account the parasitic filtering from the detector
% diode and also takes care of aliasing with 10-20 terms
%
% PSD means Power Spectrum Density
% Fc - corner Frequency
% F - frequency
% D - diffusion constant
%
% Gheorghe Chistol, 19 April 2011
D = Param(1);
Fc = Param(2);
F3db = Param(3); %diode filtering frequency
a = Param(4); %alpha for the diode
PSD = (D*(1+(F/Fc).^2).^(-1)).*(a+(1-a)./(1+(F/F3db).^2));
Fs = 62500;

%Take into account aliasing
N=10;
for n=-N:N
    Correction = (D*(1+((F+n*Fs)/Fc).^2).^(-1)).*(a+(1-a)./(1+((F+n*Fs)/F3db).^2));
    if n~=0
        PSD=PSD+Correction;
    end
end
%PSD = (D*(1+(F/Fc).^2).^(-1))./(1+(F/F3db).^2);