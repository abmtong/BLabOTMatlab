function GheCalibrate()
% This function talks to the TweezerCalib2.1 suite of functions and
% performs calibration based on power spectra of trapped beads.
% TweezerCalib2.1 is very powerful, but it does a lot of things we don't
% need and it slow. This function makes things faster by doing only the
% neccessary operations with TweezerCalib.
%
% Gheorghe Chistol, 3 Feb 2012


    % Define General Parameters

    Def.nBlock       = 1500;      %number of spectrum data points in a block, we want ~50-200 binned points per fit
    Def.nAlias       = 20;        %use 20 aliasing terms
    Def.nFitIter     = 50;        %max number of fit iterations 
    Def.TolX         = 1e-7;      %tolerance in fit
    Def.fSample      = 62500;     %in Hz
    Def.fNyq         = 62500/2;   %in Hz, has to be an integer
    Def.iFitStart    = 100;        %frequency range for initial fitting
    Def.iFitEnd      = 10000;      %in Hz
    Def.fFitStart    = 100;        %frequency range for final fitting
    Def.fFitEnd      = 62500/2;  %in Hz
    Def.kB           = 1.3807e-2; %Boltzmann Const in pN*nm/K
    Def.wViscosity   = 9.1e-10;   %water viscosity at 24C in [pN s/nm^2]
    Def.wTemp        = 273+24;    %water temperature in K
    Def.bRadiusA     = 1000/2;     %radius of bead in (steerable) trap A in nm
    Def.bRadiusB     = 1000/2;     %radius of bead in (fixed) trap B nm
    
    %Def.wDensity     = 1e-21;     %water density in [pN s^2/nm^4]
    %Def.bDensity     = 1.05e-21; % [pN s^2/nm^4] bead density
    %need them only for hydrodynamic corrections, and we don't do that

    Report       = ''; %we can print the report to a file with details about the entire process

    global fNyq nAlias; %I hate using globals, but I couldn't do this otherwise
    fNyq   = Def.fNyq;   
    nAlias = Def.nAlias;

    % Select File(s) of Interest
    global analysisPath rawDataPath; %get the analysis path
    if isempty(rawDataPath)
        error('rawDataPath not found. Define rawDataPath properly.');
    end
    if isempty(analysisPath)
        error('analysisPath not found. Define analysisPath properly.');
    end

    [HighFreqFile HighFreqPath] = uigetfile([ [rawDataPath filesep] '*.dat'], ...
                                  'Select the F1 file(s) for Power-Spectrum calibration:','MultiSelect','on');
    if isempty(HighFreqFile) %if no files were selected
        error('No files were selected');
    end

    if ~iscell(HighFreqFile) %convert into a cell for convenience
        temp = HighFreqFile; HighFreqFile=''; HighFreqFile{1}=temp; clear temp;    
    end

    for i = 1:length(HighFreqFile) %process one file at a time
        % Load Data
        NormVoltage = GheCalibrate_ReadHighFreqFile(HighFreqPath, HighFreqFile{i});
        % Struct fields AX, BX, AY, BY
        
        % Process Data from DetectorA and DetectorB one at a time
        disp('  Calibrating Detector A');
        [Result.AX Result.AY Report] = GheCalibrate_ProcessOneDetector(NormVoltage.AX, NormVoltage.AY, Def, Report);

        disp('  Calibrating Detector B');
        [Result.BX Result.BY Report] = GheCalibrate_ProcessOneDetector(NormVoltage.BX, NormVoltage.BY, Def, Report);

        [Result cal] = GheCalibrate_OrganizeResults(Result,Def,HighFreqPath,HighFreqFile{i}); %Result is updated with kappa and alpha values

        disp(['------ Saving calibration results to cal' HighFreqFile{i}(1:end-4) '.mat']);
        Result.Settings = Def;
        SaveFile = [analysisPath filesep 'cal' HighFreqFile{i}(1:end-4) '.mat'];
        save(SaveFile,'Result','cal');
        GheCalibrate_PlotFits(Result,i,HighFreqFile{i});
        pause(0.5);
        %close(gcf);
    end

    clear global fNyq nAlias; %I hate using globals, but I couldn't do this otherwise
end