function [ResultX ResultY Report] = GheCalibrate_ProcessOneDetector(X,Y,Def,Report)
%
%
%
% Gheorghe Chistol, 3 Feb 2012

% Unpackage the defined parameters, for convenience
nBlock    = Def.nBlock;       % = 1500;  %number of spectrum data points in a block, we want ~50-200 binned points per fit
nAlias    = Def.nAlias;       % = 20;    %use 20 aliasing terms
nFitIter  = Def.nFitIter;     % = 50;    %max number of fit iterations 
TolX      = Def.TolX;         % = 1e-7;  %tolerance in fit
fSample   = Def.fSample;      % = 62500; %in Hz
fNyq      = Def.fNyq;         % = round(fSample/2); %in Hz, has to be an integer
iFitStart = Def.iFitStart;    % = 50;     %frequency range for initial fitting
iFitEnd   = Def.iFitEnd;      % = 6000;   %in Hz
fFitStart = Def.fFitStart;    % = 50;     %frequency range for final fitting
fFitEnd   = Def.fFitEnd;      % = fNyq;   %in Hz

% Calculate the Power in X signal
X   = X-mean(X); %pretty sure this is unneccessary for power-spectr
Y   = Y-mean(Y);
[~, Px, ~] = GheCalibrate_CalcPowerSpectrum(X, fSample);
[f, Py, T] = GheCalibrate_CalcPowerSpectrum(Y, fSample);

% fprintf('  Decorrelating X and Y channels, ');
% [Px, Py, X, Y, b, c Report] = GheCalibrate_DecorrelateXY(X, Y, T, f, Px, Py, fFitStart, fFitEnd, fNyq, nBlock, nFitIter, TolX, Report); %remove cross-talk between Px and Py
% disp(['    Decorrelation Parameters: b=' num2str(b ,'%5.2f') ', c=' num2str(c ,'%5.2f') '/n']);

% Perform the fit for channels X and Y one at a time
ResultX = GheCalibrate_ProcessOneChannel(f,Px,T,Def);
%ResultX.bDecorrXYCoeff = b;
%ResultX.cDecorrXYCoeff = c;

ResultY = GheCalibrate_ProcessOneChannel(f,Py,T,Def);
%ResultY.bDecorrXYCoeff = b;
%ResultY.cDecorrXYCoeff = c;
end