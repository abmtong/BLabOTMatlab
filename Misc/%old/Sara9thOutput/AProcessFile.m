function out = AProcessFile()
%Gets traces and protocol times


%file = processDatVarIn(10,[5,9,10]);
%traces = getTraces(file.mx,file.s10);

file = processDatVarIn(9,[5,9]);
traces = getTraces(file.mx,file.s9);

out = splitOE(traces,3);
figure('name','eoe')
plot(out.eoe')
figure('name','eoo')
plot(out.eoo')

sampRate = 2500;
chTimes = findChanges(file.s9);
chTimes1 = [0 chTimes];
chTimes2 = [chTimes 0];
pauseLenRaw = (chTimes2 - chTimes1)/sampRate;
pauseLen = pauseLenRaw( 2:length(pauseLenRaw)-1 ); %trim first and last, which are maths with the 0's
times = splitOE(pauseLen);
out.timesE = times.e;
out.timesO = times.o;
end