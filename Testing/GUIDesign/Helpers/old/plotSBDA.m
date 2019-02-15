function plotSBDA(Trace)
%Plots a stepfcn from SaraBurstDurationAnalysis

t = Trace.Time;
c = Trace.Contour;

tf = Trace.Dwells.FiltT; %windowFilter(@mean, t, floor(Trace.FiltFact/2), Trace.FiltFact);
cf = Trace.Dwells.FiltY; %windowFilter(@mean, c, floor(Trace.FiltFact/2), Trace.FiltFact);

ind = [Trace.Dwells.StartInd Trace.Dwells.FinishInd(end)];
figure
plot(t,c, 'Color', [.8 .8 .8])
hold on
plot(tf, cf)
plot(tf, ind3tra(ind, cf),'Color','k')