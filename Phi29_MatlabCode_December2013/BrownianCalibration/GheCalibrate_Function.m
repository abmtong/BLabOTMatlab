function hh = GheCalibrate_Function(scal_fit,parameters,xfin,yfin,sfin)
% The function minus the data divided by the error sfin.
% This function is used for minimization when fitting power spectra with
% all the appropriate corrections. It is derived from 'funn' in
% TweezerCalib2.1.
%
% USE: hh = GheCalibrate_Function(scal_fit,parameters,xfin,yfin,sfin)
%
% Gheorghe Chistol, 3 Feb 2012

    hh = (1./GheCalibrate_TheorP(scal_fit,parameters,xfin) - 1./yfin) ./ sfin;
    
end
