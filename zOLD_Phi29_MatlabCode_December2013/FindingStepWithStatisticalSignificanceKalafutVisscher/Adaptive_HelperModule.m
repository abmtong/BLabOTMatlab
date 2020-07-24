function [RecordOfValidatedDwells ProposedDwells FinalDwells FinalDwellsValidated] =  Adaptive_HelperModule(RawT,RawY,RawF,PenaltyFactor,ContrastThr,MaxSeparation,AvgNum,Bandwidth,CurrentPhageName,CurrentPhageFile,CurrentFeedbackCycle,analysisPath,s)
% This function makes it easier to manage the operations required for step-finding in a particular
 % feedback cycle in a particular phage
 %

    FiltT  = Adaptive_FilterAndDecimate(RawT, AvgNum);
    FiltY  = Adaptive_FilterAndDecimate(RawY, AvgNum);
    FiltF  = Adaptive_FilterAndDecimate(RawF, AvgNum);
    DwellInd = Adaptive_FindSteps(FiltY,PenaltyFactor); %SIC Step Finding

    DwellInd = Adaptive_GetRidOfSinglePointSteps(DwellInd); %sometimes it finds steps that consist of a single point, those are bad
    
    %We can'd do side-histogram analysis properly with
    %slips, so we have to break up the trace into fragments
    FragDwellInd = Adaptive_FragmentTraceAtSlips(DwellInd);
    % FragDwellInd contains the following fields: (f stands for "Fragment")
    % FragDwellInd{f}(d).Start
    % FragDwellInd{f}(d).Finish
    % FragDwellInd{f}(d).Mean

    %work on each fragment independently
    [RecordOfValidatedDwells ProposedDwells ValidatedFragDwellInd KernelDensity] = Adaptive_ValidateDwells_FragDwellInd(RawT,RawY,FiltT,FiltY,FiltF,FragDwellInd,ContrastThr,MaxSeparation,AvgNum);
    FinalDwells          = Adaptive_FinalDwells(DwellInd,FiltT,FiltY,FiltF,CurrentPhageFile,CurrentFeedbackCycle,Bandwidth);
    FinalDwellsValidated = Adaptive_FinalDwellsValidated(ValidatedFragDwellInd,FiltT,FiltY,FiltF,CurrentPhageFile,CurrentFeedbackCycle,Bandwidth);
    Adaptive_PlotFinalResults(RawT,RawY,FiltT,FiltY,KernelDensity,FinalDwells,FinalDwellsValidated,CurrentFeedbackCycle,CurrentPhageName,analysisPath,Bandwidth,s);
end