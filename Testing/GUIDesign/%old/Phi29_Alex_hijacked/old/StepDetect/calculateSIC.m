function outSIC = calculateSIC(var, len, penalty)
%Calculates the Schwarz Information Criterion (SIC) for a Heaviside-like stepping function of input data
%The fit is judged by the variance of the data minus the fit, as well as a penalty based on the number of steps

%The input var. penalty isn't part of the usual SIC, but there for flexibility
%SIC = numSteps * ln (numPoints) + numPoints * ln(sumVariance) [Simplified to remove constants]
%Reference: Kalafut, Visscher, Com Phy Comm 2008 http://dx.doi.org/10.1016/j.cpc.2008.06.008

%A similar scoring function suggests instead have the penalty be 9*var(noise)
%You can grab from any flat section of data, I guess? (Make sure you filter it the same)
%A test on N25#2 gave an equivalent penalty of 13, giving 23 steps for a 257bp long trace (cf 80+ for pf = 1)
%"Right" value (giving #steps = contour/10) is around 10
%Reference: Aggarwal, et al, Cell Mol Bioeng 2012  dx.doi.org/10.1007/s12195-011-0188-5


if nargin < 3
    penalty = 1;
end

numSteps = length(var);
sumVar = sum(var);

outSIC = penalty*numSteps*log(len) + len*log(sumVar);

end

