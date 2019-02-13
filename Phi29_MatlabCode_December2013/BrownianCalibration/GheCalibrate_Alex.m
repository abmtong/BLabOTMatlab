function GheCalibrate_Alex(AnalysisFile)
% This function talks to the TweezerCalib2.1 suite of functions and
% performs calibration based on power spectra of trapped beads.
% TweezerCalib2.1 is very powerful, but it does a lot of things we don't
% need and it slow. This function makes things faster by doing only the
% neccessary operations with TweezerCalib.
%
% Gheorghe Chistol, 3 Feb 2012
% Modified by Alex to add batch processing, readability

    %Bead Paramters
    Def.bRadiusA    = 1000/2;   %Steerable trap bead radius (nm)
    Def.bRadiusB    = 1000/2;   %Fixed trap bead radius (nm)
    %Data Paramters
    Def.fSample     = 62.5e3;   %Data sampling rate (Hz). 62.5k is the maximum our card can do for 8 channels.
    Def.fNyq        = floor(Def.fSample/2); %Nyquist frequency
    %Filtering Paramters
    Def.nBlock      = 1500; 	%Number of points per block, to filter the power spectrum
    %Fitting Parameters
    Def.nAlias      = 20;       %Number of aliasing terms, to estimate fit parameters before fitting
    Def.nFitIter    = 50;       %Max number of iterations (see e.g. 'doc Optimization Options Reference')
    Def.TolX        = 1e-7;     %Tolerance (see e.g. 'doc Optimization Options Reference')
    Def.iFitStart   = 100;      %Start frequency for initial fit (Hz)
    Def.iFitEnd     = 10000;    %End   frequency for initial fit (Hz)
    Def.fFitStart   = 100;      %Start frequency for final   fit (Hz)
    Def.fFitEnd     = 62500/2;  %End   frequency for final   fit (Hz)
    %Physical Constants
    Def.kB          = 1.3807e-2;%Boltzmann's Constant (pN*nm/K)
    Def.wViscosity  = 9.1e-10;  %Viscosity of water at 24C (pN*s/nm^2)
    Def.wTemp       = 273+24;   %Temperature of water in chamber (K)

    %Declare globals
    global fNyq nAlias;
    fNyq   = Def.fNyq;   
    nAlias = Def.nAlias;

    %Grab globals, should never occur if using @AlexCreateAnalysisFile
    global analysisPath rawDataPath; %get the analysis path
    if isempty(rawDataPath)
        error('rawDataPath not found. Define rawDataPath properly.');
    end
    if isempty(analysisPath)
        error('analysisPath not found. Define analysisPath properly.');
    end

    %Parse MATLABanalysis.txt for files to analyze
    if(nargin<1);
        %Pick from UI if not supplied
        [file, path] = uigetfile([analysisPath filesep '*.txt'],'MultiSelect','off','Select Batch File'); 
        AnalysisFile = [path filesep file];
    end
    %Read file
    fid = fopen(AnalysisFile);
    scn = textscan(fid, '%s %s %s');
    fclose(fid);
    %Third column is calMMDDYYN##
    CalFiles = scn{3};
    %If empty, return
    if isempty(CalFiles)
        error('No files were selected');
    end
    %Add '.dat', remove 'cal'
    CalFiles = strcat(CalFiles, '.dat');
    CalFiles = strrep(CalFiles,'cal','');
    %Loop over files
    for i = 1:length(CalFiles)
        %Load normalized detector readouts into struct, fields {AX, AY, BX, BY}
        NormVoltage = GheCalibrate_ReadHighFreqFile(rawDataPath, CalFiles{i});
        %Process data from trap A, B
        Report = [];
        [Result.AX, Result.AY, Report] = GheCalibrate_ProcessOneDetector(NormVoltage.AX, NormVoltage.AY, Def, Report);
        [Result.BX, Result.BY, Report] = GheCalibrate_ProcessOneDetector(NormVoltage.BX, NormVoltage.BY, Def, Report); %#ok<ASGLU>
        %Organize results to be saved
        [Result, cal] = GheCalibrate_OrganizeResults(Result,Def,rawDataPath,CalFiles{i}); %#ok<ASGLU>
        %Save, plot Lorentzian
        Result.Settings = Def;
        SaveFile = [analysisPath filesep 'cal' CalFiles{i}(1:end-4) '.mat'];
        save(SaveFile,'Result','cal');
        fprintf('Calibration saved to %s.mat\n',CalFiles{i}(1:end-4));
        GheCalibrate_PlotFits(Result,i,CalFiles{i});
        drawnow
    end
    %Cleanup globals
    clear global fNyq nAlias;
end