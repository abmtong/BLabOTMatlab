function GheCalibrate_170609_Differential(Voltage)
%GheCalibrate but takes in any Result you like
%Needs BrownianCalibration in path

% This function talks to the TweezerCalib2.1 suite of functions and
% performs calibration based on power spectra of trapped beads.
% TweezerCalib2.1 is very powerful, but it does a lot of things we don't
% need and it slow. This function makes things faster by doing only the
% neccessary operations with TweezerCalib.
%
% Gheorghe Chistol, 3 Feb 2012


    %% Define General Parameters

    Def.nBlock       = 1500;      %number of spectrum data points in a block, we want ~50-200 binned points per fit
    Def.nAlias       = 20;        %use 20 aliasing terms
    Def.nFitIter     = 50;        %max number of fit iterations 
    Def.TolX         = 1e-7;      %tolerance in fit
    Def.fSample      = 62500;     %in Hz
    Def.fNyq         = 62500/2;   %in Hz, has to be an integer
    Def.iFitStart    = 100;        %frequency range for initial fitting
    Def.iFitEnd      = 10000;      %in Hz
    Def.fFitStart    = 100;        %frequency range for final fitting
    Def.fFitEnd      = 2500/2;  %in Hz
    Def.kB           = 1.3807e-2; %Boltzmann Const in pN*nm/K
    Def.wViscosity   = 9.1e-10;   %water viscosity at 24C in [pN s/nm^2]
    Def.wTemp        = 273+24;    %water temperature in K
    Def.bRadiusA     = 790/2;     %radius of bead A (usually antibody bead) in nm, steerable trap; usually 900
    Def.bRadiusB     = 1000/2;     %radius of bead B (usually Streptavidin bead) in nm, fixed trap; usually 1000
    
    Report       = ''; %we can print the report to a file with details about the entire process

    global fNyq nAlias; %I hate using globals, but I couldn't do this otherwise
    fNyq   = Def.fNyq;   
    nAlias = Def.nAlias;
        
    NormVoltage.AX = Voltage.ax ./ Voltage.sa;
    NormVoltage.AY = Voltage.ay ./ Voltage.sa;
    NormVoltage.BX = Voltage.bx ./ Voltage.sb;
    NormVoltage.BY = Voltage.by ./ Voltage.sb;

    %% Process Data from DetectorA and DetectorB one at a time
    disp('  Calibrating Detector A');
    [Result.AX Result.AY Report] = GheCalibrate_ProcessOneDetector(NormVoltage.AX-NormVoltage.BX, NormVoltage.AY-NormVoltage.BY, Def, Report);

    disp('  Calibrating Detector B');
    [Result.BX Result.BY Report] = GheCalibrate_ProcessOneDetector(NormVoltage.AX-NormVoltage.BX, NormVoltage.AY-NormVoltage.BY, Def, Report);

    [Result cal] = GheCalibrate_OrganizeResults(Result,Def,'adhoc','adhoc'); %Result is updated with kappa and alpha values

    Result.Settings = Def;
    GheCalibrate_PlotFits(Result,1,'adhoc');
    pause(0.5);
    %close(gcf);

    clear global fNyq nAlias; %I hate using globals, but I couldn't do this otherwise
end