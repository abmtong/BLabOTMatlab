function outSIC = calculateSIC(var, len, penalty)
%Calculates the Schwarz Information Criterion (SIC) for a Heaviside-like stepping function of input data
%The fit is judged by the variance of the data minus the fit, as well as a penalty based on the number of steps

%The input var. penalty isn't part of the usual SIC, but there for flexibility
%SIC = numSteps * ln (numPoints) + numPoints * ln(sumVariance) [Simplified to remove constants]
%Reference: Kalafut, Visscher, Com Phy Comm 2008 http://dx.doi.org/10.1016/j.cpc.2008.06.008


numSteps = length(var);

if nargin < 3
    penalty = numSteps*log(len);
end

outSIC = penalty*numSteps + len*log(sum(var));

end

