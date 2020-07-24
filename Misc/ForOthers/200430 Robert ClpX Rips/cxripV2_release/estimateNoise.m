function outNoise = estimateNoise(inContour, inWidth, ver)
%Estimates the variance of the noise of some data

if nargin < 3
    if nargin == 2
        ver = 1; %Version 1 has a tuning factor, so if it's passed, use it
    else
        ver = 2; %Version 2 has no tuning factor
    end
end
if ver == 2
    %Use median absolute deviation (MAD):
    % If x is normally distributed with mean sig, diff(x) is normally distributed with mean sig*sqrt(2)
    % MAD is related to std (assuming normal distribution) by sig = MAD * 1.4826 (= 1/sqrt(2)/erfinv(.5) )
    % So sig = MAD(diff(x)) / 2 / erfinv(.5) ~ MAD(diff(x)) / 0.9539 [can swap to constant to avoid @erfinv evaluation]
    % For staircase signals, the diff(signal) only shifts a few values, so median / MAD is essentially unchanged
    % For smoother signals, the diff(signal) may be shifted by up to (signal/numpts) which is much smaller than noise anyway
    din = diff(inContour);
    outNoise = ( mad(din,1) / 2 / erfinv(.5) ).^2 ;
else
    %Subtract the moving average to remove the signal [requires tuning of inWidth]
    %For a phi29 trace at 2.5kHz, 125 works well. Scaling linearly with frequency seems to work fine.
    if nargin < 2 || isempty(inWidth)
        inWidth = 125;
    end
    inWidth = ceil(inWidth);
    outNoise = var(inContour - windowFilter(@mean, inContour, inWidth));
end