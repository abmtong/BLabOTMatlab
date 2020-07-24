% Process a single wiggle calibration file, using the fitting stuff adapted
% from TweezerCalib2.1
%
% Gheorghe Chistol, 27 April 2011

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
% data.FilePath % data.File % data.Fsamp 
% data.AX      % data.AY      % data.ASum    
% data.BX      % data.BY      % data.BSum    
% data.MirrorX % data.MirrorY % data.Time     

CalData.Norm_AX = Data.AX./Data.ASum; 
CalData.Norm_AY = Data.AY./Data.ASum;
CalData.Norm_BX = Data.BX./Data.BSum;
CalData.Norm_BY = Data.BY./Data.BSum;

%% FFT using one pass, then block it with Nblock points in each block
% Select the data that will be analyzed (AX, BX, AY, BY)
fftData = CalData.Norm_AY;

[F,P] = WiggleCal_PowerSpectrum(Fsamp,fftData);
% figure;
% loglog(F,P);
% xlabel('Frequency (Hz)');
% ylabel('Power Spectrum Density (NormVolt^2/Hz');

% max point that corresponds to the trap wiggle
%F(P==max(P))=[]; P(P==max(P))=[];
figure;
loglog(F,P,'.b');
xlabel('Frequency (Hz)');
ylabel('Power Spectrum Density (NormVolt^2/Hz');

%remove the points the correspond to the wiggle peak
fWiggle = 33.38;
fDelta  = 0.5;
RemoveInd = F<(fWiggle+fDelta) & F>(fWiggle-fDelta);
F(RemoveInd)=[];
P(RemoveInd)=[];

figure;
loglog(F,P,'.b');
xlabel('Frequency (Hz)');
ylabel('Power Spectrum Density (NormVolt^2/Hz');

%% Smooth the data, use blocking
Nblock = 1000;
NumBlocks    = floor(length(P)/Nblock);
BlockF       = zeros(1,NumBlocks); %initialize the vectors/arrays
BlockP_Mean  = zeros(1,NumBlocks);
BlockP_StDev = zeros(1,NumBlocks);
BlockP_StErr = zeros(1,NumBlocks);

for i=1:NumBlocks
    KeepInd         = ((i-1)*Nblock+1):(i*Nblock);
    BlockF(i)       = mean(F(KeepInd));
    BlockP_Mean(i)  = mean(P(KeepInd));
    BlockP_StDev(i) = std(P(KeepInd));
    BlockP_StErr(i) = std(P(KeepInd))/sqrt(length(KeepInd));
end

%only use a portion of the data for fitting
%throw away low freq data due to 1/f noise
Ffit_min = 100;
Ffit_max = Fsamp;
IndKeep = BlockF>Ffit_min & BlockF<Ffit_max;
BlockF       = BlockF(IndKeep);
BlockP_Mean  = BlockP_Mean(IndKeep);
BlockP_StDev = BlockP_StDev(IndKeep);
BlockP_StErr = BlockP_StErr(IndKeep);


figure;
%errorbar(BlockF,BlockP_Mean,BlockP_StErr,'.b');
plot(BlockF,BlockP_Mean,'.b');
xlabel('Frequency (Hz)');
ylabel('Power Spectrum Density (NormVolt^2/Hz');
title('Blocked Data, Selected for Aliased/Filtered Spectrum Fitting')
set(gca,'XScale','log','YScale','log');
YLim = [min(BlockP_Mean)/1.1 1.1*max(BlockP_Mean)];
XLim = [min(BlockF)/1.2 1.2*max(BlockF)];
set(gca,'XLim',XLim,'YLim',YLim);

%% Fit the Data to the proper Function, including Aliasing and Parasitic Filtering effects
Lfit_start = 100;
Lfit_end   = 6000;
Ffit_start = 100;
Ffit_end   = 31250;
fSample    = 62500;
parameters = Ghe_FitSpectrum(F,P,Nblock,Lfit_start,Lfit_end,Ffit_start,Ffit_end,fSample);

%% FFT and plot, optimized for the Wiggle Peak detection
Nfft=2^16; %points for each FFT, so we can average the spectra later
Nrounds = floor(length(fftData)/Nfft);
fftReshapedData = reshape(fftData(1:Nrounds*Nfft),Nfft,Nrounds);


AllPowerSpectra = [];
for r=1:Nrounds
    tempData = fftReshapedData(:,r);
    [f,p] = WiggleCal_PowerSpectrum(Fsamp,tempData);
    AllPowerSpectra(r,:) = p; % add the current PowerSpectrumDensity to the matrix
end

% AllPowerSpectra = [PowerSpectrum1
%                    PowerSpectrum2
%                    PowerSpectrum3
%                    ...
%                    PowerSpectrumLast];

PowerSpectrum_Mean  = [];
PowerSpectrum_StDev = [];
PowerSpectrum_StErr = [];
[Nrows Ncols]=size(AllPowerSpectra);
for c=1:Ncols
    data = AllPowerSpectra(:,c);
    PowerSpectrum_Mean(c)  = mean(data);
    PowerSpectrum_StDev(c) = std(data);
    PowerSpectrum_StErr(c) = std(data)/sqrt(length(data));
end
% define the baseline for brownian background subtraction
Nbaseline       = 10; %nr of points used for background subtraction
WigglePeakInd   = find(abs(f-fWiggle)==min(abs(f-fWiggle)));
BaselineInd     = [WigglePeakInd-Nbaseline-1:WigglePeakInd-1 WigglePeakInd+1:WigglePeakInd+Nbaseline+1];
BaselineP_Mean  = mean(PowerSpectrum_Mean(BaselineInd));
BaselineP_StDev = std(PowerSpectrum_Mean(BaselineInd));
BaselineP_StErr = std(PowerSpectrum_Mean(BaselineInd))/sqrt(length(BaselineInd));

PeakP_Mean  = PowerSpectrum_Mean(WigglePeakInd);
PeakP_StDev = PowerSpectrum_StDev(WigglePeakInd);
PeakP_StErr = PowerSpectrum_StErr(WigglePeakInd);


%% Plot the Spectrum and the Spike due to the Trap Wiggle
close all; figure('Units','normalized','Position',[0.0059 0.0625 0.4883 0.8359]); 
subplot(3,1,1:2); hold on;
plot(f,PowerSpectrum_Mean,'.b'); %errorbar(f,PowerSpectrum_Mean,PowerSpectrum_StErr,'.b');
%plot(f(BaselineInd),PowerSpectrum_Mean(BaselineInd),'.r');
plot(f(WigglePeakInd),PowerSpectrum_Mean(WigglePeakInd),'or');
line(f(WigglePeakInd)*[1 1],[BaselineP_Mean PeakP_Mean],'Color','k','LineWidth',1); %plot a line from the baseline to the wiggle peak
line([f(BaselineInd(1)) f(BaselineInd(end))], BaselineP_Mean*[1 1],'Color','k','LineWidth',1);
set(gca,'XScale','log','YScale','log');
XLim = [min(f)/1.3 1.3*max(f)];
YLim = [min(PowerSpectrum_Mean)/1.5 1.5*max(PowerSpectrum_Mean)];
set(gca,'XLim',XLim,'YLim',YLim,'box','on');
xlabel('Frequency (Hz)');
ylabel('Power Spectrum Density (NormVolt^2/Hz');
title('Calculating the Detector Response Factor \alpha');

subplot(3,1,3); hold on;
DeltaT = 10/fWiggle; %look at only 0.5sec of trap wiggle
TrapConvY = 580;%nm/V

clear t y;
t = Data.Time(DeltaT<Data.Time & Data.Time<2*DeltaT);
y = TrapConvY*Data.MirrorY(DeltaT<Data.Time & Data.Time<2*DeltaT);
y = y-mean(y); %offset to make it zero-centered
%Filter the data by a factor of 5 to smooth it
FilterFactor = 5;
%t=BoxcarFilter(t,FilterFactor);
y=BoxcarFilter(y,FilterFactor);
WiggleAmplitude = (max(y)-min(y))/2;

plot(t,y,'r'); set(gca,'box','on');
XLim = [min(t) max(t)];
YLim = [min(y)*1.9 1.3*max(y)];
set(gca,'XLim',XLim,'YLim',YLim,'box','on');
legend(['Wiggle Amplitude = ' num2str(WiggleAmplitude) 'nm'],'Location','SW')
xlabel('Time (s)');
ylabel('Trap Y-Motion (nm)');

fCorner = 4000; %Corner frequency needs to be found by fitting the aliased/filtered spectrum sans the wiggle spike
                %the value of 4000 is simply a guess for now, just to check
                %the numbers
ExperSpikePower = (PeakP_Mean-BaselineP_Mean)*(f(2)-f(1)); %Spike Power in NormVolt^2
TheorSpikePower = 1/2*WiggleAmplitude^2/(1+fCorner^2/fWiggle^2);
Alpha = sqrt(TheorSpikePower/ExperSpikePower);

