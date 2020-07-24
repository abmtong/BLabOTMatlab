function Script_CrudeHighFillingDwellAnalysis(Dwells)
% Dwells.Duration
% Dwells.Filling
% Dwells.SizeStepAfter
%
% 0-30% filling
% 40-70% filling
% 80-100% filling
%
% Gheorghe Chistol 02 Nov 2012

LoFill = [0  40 80 ];
HiFill = [30 70 100];
DurationCutoff = [1 1 3];
for i=1:length(LoFill)
    KeepInd = Dwells.Filling>LoFill(i) & Dwells.Filling<HiFill(i);
    Duration{i} = Dwells.Duration(KeepInd);
    Duration{i} = Duration{i}(Duration{i}<DurationCutoff(i));
end

figure
N=3;
BinSize= [0.05 0.05 0.1];
XLim = [0 3];
for i = 1:length(BinSize)
    Bins{i} = BinSize(i)/2:BinSize(i):XLim(2);
end

for i=1:N
    subplot(N,1,i)
    hist(Duration{i},Bins{i});
    ylabel([num2str(length(Duration{i})) ' dwells']);
    Nmin = uCalculateNminConfInt(Duration{i}, 1000, 0.95);
    text = sprintf('Filling: %d-%d%%; Nmin: %1.1f (%1.1f-%1.1f)',LoFill(i),HiFill(i),Nmin(2),Nmin(1),Nmin(3));
    legend(text);
    set(gca,'XLim',XLim);
end
xlabel('Dwell Duration (s)');
subplot(N,1,1);