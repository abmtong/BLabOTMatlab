function [DwellIndConsolidated FinalDwellsConsolidated FiltT FiltY FiltF] = LLP_HelperModule(RawT,RawY,RawF,PenaltyFactor,AvgNum,Bandwidth,CurrentPhageName,CurrentPhageFile,CurrentFeedbackCycle,analysisPath,Section,MinStep,MinDuration)
% This function makes it easier to manage the operations required for step-finding in a particular
% feedback cycle in a particular phage
%

    FiltT  = LLP_FilterAndDecimate(RawT, AvgNum);
    FiltY  = LLP_FilterAndDecimate(RawY, AvgNum);
    FiltF  = LLP_FilterAndDecimate(RawF, AvgNum);
    [DwellInd ~] = LLP_FindSteps(FiltY,PenaltyFactor); %SIC Step Finding, History contains the history of DwellInd and StepInd

    DwellInd                = LLP_HelperModuleGetRidOfSinglePointSteps(DwellInd); %sometimes it finds steps that consist of a single point, those are bad
    FinalDwells             = LLP_HelperModuleFinalDwells(DwellInd,FiltT,FiltY,FiltF,CurrentPhageFile,CurrentFeedbackCycle,Bandwidth);
    DwellIndConsolidated    = LLP_HelperModuleConsolidateDwells(DwellInd,Bandwidth,FiltY,MinStep,MinDuration);
    FinalDwellsConsolidated = LLP_HelperModuleFinalDwells(DwellIndConsolidated,FiltT,FiltY,FiltF,CurrentPhageFile,CurrentFeedbackCycle,Bandwidth);
    LLP_PlotFinalResults(RawT,RawY,FiltT,FiltY,FinalDwells,FinalDwellsConsolidated,analysisPath,CurrentPhageName,Section);
end