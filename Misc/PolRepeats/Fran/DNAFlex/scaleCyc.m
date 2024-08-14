function out = scaleCyc(incyc, opt)
%Scales the cyclizibility output to have mean ~ 0 and sd ~ 1
% The cyc distribution isn't gaussian, so there's some options for what mean, sd to use to normalize

%Opt: scale mean and sd (1) or just sd (2) (i.e., for scaling mean vs scaling SD)

%Here's some values for the human genome:
scalemethod = 3;
switch scalemethod
    case 1
        %Straightforwards mean, sd of all data
        ym = -0.1443;
        ysd = 0.3969;
    case 2
        %Match a gaussian to the main peak, by eye
        ym = -.245;
        ysd = 0.26;
    case 3 %Findpeaks mean and half-width
        ym = -0.2471;
        ysd = .6626/2.355; %SD = FWHM / 2.355
        %Pretty similar to case 2.
    case 4
        %Least-squares curve fitting of one gaussian
        ym = -0.20946;
        ysd = 0.32606;
        % A decent in-between. Fits the negative end pretty well
    case 5
        %MLE Normal distribution
        ym = -0.14435;
        ysd = 0.40684;
end

%Shift and scale (opt == 1) or just scale (opt == 2)
if nargin < 2 || opt == 1
    out = (incyc - ym) / ysd;
else
    out = incyc / ysd;
end