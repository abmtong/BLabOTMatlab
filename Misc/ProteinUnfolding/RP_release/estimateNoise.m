function outNoise = estimateNoise(inContour, inWidth, ver)
%Estimates the variance of the noise of some data

if nargin < 3
    if nargin == 2
        ver = 1; %Version 1 has a tuning factor, so if it's passed, use it
    else %nargin == 1
        ver = 2; %Version 2's tuning factor is based on autocorrelation. at normal Fs, should be none; at Calibration Fs there may be some, so give the option
        inWidth = 1;
    end
end
if ver == 2
    %Use median absolute deviation (MAD):
    % If x is normally distributed with mean sig, diff(x) is normally distributed with mean sig*sqrt(2)
    % MAD is related to std (assuming normal distribution) by sig = MAD * 1.4826 (= 1/sqrt(2)/erfinv(.5) )
    % So sig = MAD(diff(x)) / 2 / erfinv(.5) ~ MAD(diff(x)) / 0.9539 [can swap to constant to avoid @erfinv evaluation]
    % For staircase signals, the diff(signal) only shifts a few values, so median / MAD is essentially unchanged
    % For smoother signals, the diff(signal) may be shifted by up to (signal*width/numpts) which is much smaller than noise anyway
    
    %Let inWidth determine the nth derivative
    %Choose a width (subtract i and i+width point) that is larger than the bead autocorrelation time, so diff doesn't involve correlated points.
    % But also don't choose too large such that the motion of the system is apparent
    %  For HiRes, it's ~5pts @ 2.5kHz, so let's default to 10
    if isempty(inWidth)
        inWidth = 1;
    end
    if length(inContour) <= inWidth
        outNoise = std(inContour);
        return
    end

%     din = inContour(inWidth+1:end) - inContour(1:end-inWidth);
    din = diff(inContour, inWidth);
%     outNoise = var(din)/2;
    outNoise = ( mad(din,1) / 2 / erfinv(.5) ).^2 ; %Or could just var() this, but mad is more robust to outliers?
    % Note that since we're using a median-based approach, this really gives median-squared, not variance. Which is fine for a normal distribution, but not necessarily for other distributions
else
    %Subtract the moving average to remove the signal [requires tuning of inWidth]
    %For a phi29 trace at 2.5kHz, 125 works well. Scaling linearly with frequency seems to work fine.
    if nargin < 2 || isempty(inWidth)
        inWidth = 125;
    end
    inWidth = ceil(inWidth);
    outNoise = var(inContour - windowFilter(@mean, inContour, inWidth));
end