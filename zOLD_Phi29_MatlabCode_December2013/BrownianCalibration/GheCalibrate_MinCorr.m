function M = GheCalibrate_MinCorr(parameters,Px,Py,Pxy)
% Used to minimize correlations between X and Y channels during
% decorrelation analysis. Not quite sure about the exact details. Derived
% from 'mincorr' of TweezerCalib2.1
%
% USE: M = GheCalibrate_MinCorr(parameters,Px,Py,Pxy)
%
% Gheorghe Chistol, 3 Feb 2012

    b = parameters(1);
    c = parameters(2);
    M = ((1 + b*c) .* Pxy + c*Px + b*Py) ./ sqrt((Px + 2*b*Pxy + b^2*Py) .* (Py + 2*c*Pxy + c^2*Px));

end