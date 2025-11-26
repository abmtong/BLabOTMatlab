function plotTraceNice(intr)


Fs = 1e3;
[in me] = tra2ind(intr);
len = length(intr);
xx = (1:len)/Fs;

figure, plot( xx, intr );

%Add dwell annotations
dw = diff(in)/Fs;
for i = 1:length(me)
    text( xx(round( in(i)/2 + in(i+1)/2 )), me(i), sprintf('%0.2f', 1/dw(i) ) )
end