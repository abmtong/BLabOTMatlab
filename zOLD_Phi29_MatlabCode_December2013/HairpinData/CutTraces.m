function [XDataSeg,YDataSeg]=CutTraces(Sigma,Force,XData,YData)
% CutTrace takes a hairpin file and finds where did we change the 
% force.
% We are supposed to provide the force vector, so it color codes it
% acoordingly
% USE: Value = WordWrap_DrawValue(Mean,StdFract)
%
% gheorghe chistol, 19 Feb 2013

ind=YData>(mean(YData)+Sigma*std(YData));
XPosPeaks=XData(ind);
ind=find(diff(XPosPeaks)>100)+1;
ind=[1,ind];
XPeaks=XPosPeaks(ind);


XDataSeg{1}=XData(XData<XPeaks(1));
YDataSeg{1}=YData(XData<XPeaks(1));

for i=1:(length(XPeaks)-1)
    XDataSeg{i+1}=XData(XData<XPeaks(i+1)& XData>XPeaks(i));
    YDataSeg{i+1}=YData(XData<XPeaks(i+1)& XData>XPeaks(i));
end

XDataSeg{length(XPeaks)+1}=XData(XData>XPeaks(end));
YDataSeg{length(XPeaks)+1}=YData(XData>XPeaks(end));
DropForce=XDataSeg{length(XPeaks)+1}(find(abs(diff(YDataSeg{length(XPeaks)+1}))>2.3*std(YData)));

if ~isempty(DropForce)>0
    XDataSeg{length(XPeaks)+1}=XData(XData>XPeaks(end)& XData<DropForce);
    YDataSeg{length(XPeaks)+1}=YData(XData>XPeaks(end)& XData<DropForce);
    XDataSeg{length(XPeaks)+2}=XData(XData>DropForce); 
    YDataSeg{length(XPeaks)+2}=YData(XData>DropForce);
end


figure;
hold on;
for i=1:length(XDataSeg)
    range=4;
    Azul(i)=1-(14 -Force(i))/range;
    plot(XDataSeg{i},YDataSeg{i},'Color',[1-Azul(i) 0 Azul(i)]);
end

end