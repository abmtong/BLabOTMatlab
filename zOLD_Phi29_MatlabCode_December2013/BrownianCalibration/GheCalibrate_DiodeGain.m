function g = GheCalibrate_DiodeGain(f,fdiode,alpha)
% Derived from 'g_diode' of TweezerCalib2.1 package.
% This function gives the gain of the detector (diode) as a function of
% frequency, using parasitic filtering parameters fdiode and alpha.
%
% USE: g = GheCalibrate_DiodeGain(f,fdiode,alpha)
%
% Gheorghe Chistol, 3 Feb 2012

    if nargin == 1 || isempty(fdiode),
            g   =   1;
    elseif nargin == 2 || isempty(alpha),
        g   =   1 ./ (1 + (f/fdiode).^2);
    else
        g   =   alpha^2 + (1-alpha^2) ./ (1 + (f/fdiode).^2);
    end
end