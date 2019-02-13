function BurstAlignment_DrawShading(DwellBefore,DwellAfter,AxisHandle,Color)
%
%
% USE: BurstAlignment_DrawShading(DwellBefore,DwellAfter,AxisHandle,Color)
%
% Gheorghe Chistol
XLim  = get(AxisHandle,'XLim');
RectX = [XLim(1)*[1 1] XLim(2)*[1 1]];%[Start Start Rip Rip];
RectY = [DwellAfter DwellBefore DwellBefore DwellAfter ];%[ExtensionLimit(1) ExtensionLimit(2) ExtensionLimit(2) ExtensionLimit(1)];
h     = patch(RectX,RectY,Color);
set(h,'FaceAlpha',0.08,'EdgeColor','none');
XLim       = get(gca,'XLim');
BurstValue = round((DwellBefore-DwellAfter)*10)/10;
text(XLim(2)+0.01*range(XLim),(DwellBefore+DwellAfter)/2,num2str(BurstValue));