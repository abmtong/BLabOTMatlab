% Load a single High Frequency Wiggle Calibration file, do a fourier
% transform to calculate its power-spectrum, then fit the appropriate
% lorentian to calculate calibration parameters, including the drag
% coefficient of the bead. The advantage of this method is that the drag
% coefficient can be calculated without any prior assumptions about the
% viscosity of the fluid or the size of the bead
%
% Gheorghe Chistol, 15 April 2011

%     %% Ask for the Parameters
%     Prompt = {'Dwell Time Histogram Bin Size [sec]'};
%     Title = 'Enter the Following Parameters';
%     Lines = 1;
%     Default = {'0.02'};
%     Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
%     Answer = inputdlg(Prompt, Title, Lines, Default, Options);
%     %Hist parameters refer to the histogram display at the end
%     DwellTimeBinSize             = str2num(Answer{1});

%% Global Variables and select the folder where Step/Dwell Data is stored
global rawDataPath;
if isempty(rawDataPath)
   disp('rawDataPath not defined. Use "SetRawDataPath" to define it'); return;
end

[HighFreqFile FilePath] = uigetfile([ [rawDataPath filesep ] '*.dat'], 'Please select a HighFreq Wiggle Calibration file','MultiSelect', 'off');
Fsamp = 62500;
Data = WiggleCal_ReadHighFreqFile(Fsamp,FilePath,HighFreqFile);
% data.FilePath 
% data.File     
% data.Fsamp    
% data.AX      
% data.AY      
% data.ASum    
% data.BX      
% data.BY      
% data.BSum    
% data.MirrorX 
% data.MirrorY 
% data.Time     

CalData.Norm_AX = Data.AX./Data.ASum; 
CalData.Norm_AY = Data.AY./Data.ASum;
CalData.Norm_BX = Data.BX./Data.BSum;
CalData.Norm_BY = Data.BY./Data.BSum;

% write the data to a text file that can be read by TweezerCalib2.0
% NormalizedVx NormalizedVy Sum
%%
%WiggleCal_WriteTestCalFile(CalData.Norm_AX,CalData.Norm_AY,'TestCal.txt');
%%
fftData = CalData.Norm_AY;
Nfft=2^16; %points for each FFT, so we can average the spectra later
Nrounds = floor(length(fftData)/Nfft);
fftData = reshape(fftData(1:Nrounds*Nfft),Nfft,Nrounds);

AvgPowerSpectrum = [];
for r=1:Nrounds
    tempData = fftData(:,r);
    [f,y] = WiggleCal_PowerSpectrum(Fsamp,tempData);

    if r==1
        AvgPowerSpectrum = y;
    else
        AvgPowerSpectrum = AvgPowerSpectrum+y;
    end
end
avgPSD = AvgPowerSpectrum/Nrounds; %average
f(1) = []; avgPSD(1) = []; %remove the first point, it's always funny

% Plot the Spectrum
close all;
loglog(f,avgPSD,'.b','MarkerSize',15);
%%

% Ok, so now we have the power-spectrum, fit it to a simple Lorentzian and
% a pseudo-delta-function
Fmax = 4e4;
avgPSD = avgPSD(f<Fmax);
f      = f(f<Fmax);
PeakInd = 1+find(avgPSD(2:end)==max(avgPSD(2:end)));
%when fitting the lorentzian alone ignore PeakInd-1:PeakInd+1
IgnoreInd = PeakInd-1:PeakInd+1;
FitLorentzian.f   = double(f); 
FitLorentzian.PSD = double(avgPSD);
FitLorentzian.f(IgnoreInd)   = []; %remove the points that correspond to the wiggle peak
FitLorentzian.PSD(IgnoreInd) = [];

%
DeltaF = FitLorentzian.f(3)-FitLorentzian.f(2); %the frequency resolution of the current measurement
GuessParam = [3e3]; %D and Fc 
% Set an options file for LSQNONLIN to use the
% medium-scale algorithm 
Options = optimset('lsqnonlin'); %the default options for LSQNONLIN
Options.TolFun = 1e-25;
Options.TolX   = 1e-25;
Options.FunValCheck = 'on';
Options.DiffMinChange = 1e-20;
Options.GradObj = 'on';
Options.MaxFunEvals = 1e4;
Options.MaxIter = 1e4;
XX = FitLorentzian.f(2:end);
YY = FitLorentzian.PSD(2:end)';
Nblock = 200;
X=[];
Y=[];
for b=1:floor(length(XX)/Nblock)
    Ind = 1+(b-1)*Nblock:b*Nblock;
    X(end+1) = mean(XX(Ind));
    Y(end+1) = mean(YY(Ind));
end
D = mean(Y(1:7));
%Param  = lsqnonlin(@WiggleCal_Lorentzian_lsqnonlin,[1e-7 1e3 2e4 0.5],[0 0 0 0],[],Options,X,Y);
clear Options;
%Options = statset('robust','on');
[Param, fitResidual]=nlinfit(X, Y, @WiggleCal_Lorentzian_DiodeFiltering, [1e-9 4e3 1.8e4 0.2]);
fitPSD = WiggleCal_Lorentzian_DiodeFiltering(Param,X);
% Generate the plot, title and labels. 
close all;
figure('Units','normalized','Position',[0.0059 0.0625 0.4883 0.8359]);
subplot(4,1,1:3);
loglog(X,Y,'.m','MarkerSize',15); 
title('Power Spectrum Density','FontSize',14); 
ylabel('Power (NV^2/Hz)'); 
%axis([1 1e5 1e-11 2e-7]);
hold on;
%loglog(f,avgPSD,'.k');
loglog(X,fitPSD,'-k','LineWidth',1.5);
XLim = [min(X)/1.1 1.1*max(X)];
YLim = [min(Y)/1.2 1.2*max(Y)];
set(gca,'XLim',XLim,'YLim',YLim);

subplot(4,1,4)
y=fitResidual./Y*100;
semilogx(X,y,'.m','MarkerSize',15);
hold on;
loglog(X,zeros(size(X)),'-k','LineWidth',1.5);
YLim = [min(y)*1.2 1.2*max(y)];
set(gca,'XLim',XLim,'YLim',YLim);
xlabel('Frequency (Hz)'); 
ylabel('Residual (%)');