function P_theor = GheCalibrate_TheorP(scal_fit,parameters,x)
% Theoretical Lorenzian that includes aliasing terms and diode/detector
% correction terms (i.e. frequency dependent detector response gain
% function). Derived from 'theor_p' of TweezerCalib2.1.
%
% USE: P_theor = GheCalibrate_TheorP(scal_fit,parameters,x)
%
% Gheorghe Chistol, 3 Feb 2012

    %As much as I hate global variables, I have to use them, just here
    global fNyq nAlias;
    %fNyq   = 31250; %for Birge B129 tweezers
    %nAlias = 20; %good default value

    if isempty(fNyq) || isnan(fNyq) || fNyq<1
        error('...... GheCalibrate_TheorP: fNyq is not defined properly !');
    end

    if isempty(nAlias) || isnan(nAlias) || nAlias<1
        error('...... GheCalibrate_TheorP: nAlias is not defined properly !');
    end

    fc     = parameters(1)*scal_fit(1);
    D      = parameters(2)*scal_fit(2);
    fdiode = parameters(3)*scal_fit(3);
    a0     = parameters(4)*scal_fit(4);
    alpha  = 1 / sqrt(1 + a0^2); 

    ll = length(-nAlias:nAlias);
    xx = zeros(length(x),ll);

    for i= 1: length(x)
        xx(i,:) = x(i) +2*(-nAlias:nAlias)*fNyq;
    end

    P_theor = sum((D/(2*pi^2)) ./ (xx.^2 + fc^2) .* GheCalibrate_DiodeGain(xx, fdiode, alpha),2);                    
    P_theor = P_theor(:); %we need this in a column, not a row
end