function annotateTest(inTrNoi, inTraReal, inInd, inMea, inTra)

figure
%plot fit trace, underlying steps, and stepfinding result
plottt(inTrNoi, inTraReal, inTra)
hold on
%plot blue line above each found step
for i = 1:length(inMea)
    line(inInd(i+1)*[1 1]+ [-1 50],inMea(i)*[1 1] + [0 20])
end

%plot red line below each real step
[in, me] = tra2ind(inTraReal);
for i = 1:length(me)
    line(in(i+1)*[1 1]+ [-1 -50],me(i)*[1 1] + [0 -20],'Color',[1 0 0])
end