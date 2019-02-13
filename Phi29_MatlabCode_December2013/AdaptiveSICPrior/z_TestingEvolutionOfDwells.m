% plot how the SIC steps evolve over time 
% Helps with optimizing StepFinding

%RawT, RawY, FiltT, FiltY, Evolution
if isempty(Evolution(1).StepInd)
    Evolution(1) = [];%Evolution(1) is empty
end

% Evolution(i).DwellInd
% 1x2 struct array with fields:
%     Start
%     Finish
%     Mean
%     Var

for i=1:length(Evolution)
    figure; hold on;
    title(['Round #' num2str(i)]);
    plot(RawT, RawY,'Color',0.85*[1 1 1]);
    plot(FiltT, FiltY,'Color',0.5*[1 1 1]);
    Dwells = Evolution(i).DwellInd;
    t=[];
    y=[];
    for d=1:length(Dwells)
        t(end+1:end+2) = [FiltT(Dwells(d).Start) FiltT(Dwells(d).Finish)];
        Ind = Dwells(d).Start:Dwells(d).Finish;
        y(end+1:end+2) = mean(FiltY(Ind))*[1 1];
    end
    plot(t,y,'k','LineWidth',2);
end