function outNoise = estimateNoise(inContour, inWidth, ver)
%Estimates the noise of a noisy stepfunction
%Method:
% If x is normally distributed with mean sig, diff(x) is normally distributed with mean sig*sqrt(2)
% MAD is related to the normally-distributed mean by sig = MAD * 1.4826 (= 1/sqrt(2)/erfinv(.5) )
% So sig = MAD(diff(x)) / 2 / erfinv(.5) ~ MAD(diff(x)) / 0.9539 [can swap to constant to avoid @erfinv evaluation]
%For staircase signals, the diff(signal) only shifts a few values, so median / MAD is essentially unchanged
%For smoother signals, the diff(signal) may be shifted by up to (signal/numpts) which is much smaller than noise anyway
%Outputs the variance of the noise for historical reasons (current users expect variance)
%Sanity check: Try estimateNoise(randn(1,1e6)), should be ~1
if nargin < 3
    ver = 1;
end
if ver == 2
    din = diff(inContour);
    outNoise = ( median( abs( din - median(din) ) ) / 2 / erfinv(.5) ).^2 ;
elseif ver == 3
    din = diff(inContour);
    outNoise = ( median( abs( din - median(din) ) ) / 2 / erfinv(.5) ).^2 * inWidth; %make this tunable
else %use old ver
    %Estimates the variance of the noise of a trace.
    %Subtracts the moving average to try to remove signal
    %For a phi29 trace at 2.5kHz, 125 works well. Scaling linearly with frequency seems to work fine.
    
    if nargin < 2 || isempty(inWidth)
        inWidth = 125;
    end
    
    inWidth = ceil(inWidth);
    outNoise = var(inContour - windowFilter(@mean, inContour, inWidth));
end