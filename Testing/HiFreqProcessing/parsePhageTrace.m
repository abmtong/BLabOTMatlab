function stepdata = parsePhageTrace( inData, inOpts )

%Full flow:
%{
Load data, normalize
Apply offset
Calc ext, for
break into cycles
%}

Fs = 2500;

%Hard coded 2500Hz reference pt, higher Fs will move less per step (while noise stays constant) > lower SNR; so decimate
dec = min(round(Fs/2500),1);
thr = 2e-5;
%Filter the data, find where the absolute difference is over a certain threshold, then find the bdys of the changes
ind = diff(abs(diff(windowFilter(@mean, inData.mx, 250*dec, dec))) > thr);

indSta = dec*find(ind<0); %=-1, end of mirror movement (start of segment)
indEnd = dec*find(ind>0); %=+1, start of mirror movement (end of segment)

%Maybe need to do some checking on indSta/indEnd- most likely, trace may end moving, which is fine; if trace starts moving, need to fix


for i = 1:length(indEnd)
    out.force{i} = force(indSta(i):indEnd(i));
end
