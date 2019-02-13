function DPI=DetectPauses_VPItoDPI(ContourLength,VPI)
% This function converts VelocityPauseIndex (VPI) into DataPauseIndex (DPI)
% Suppose my VPI is [1 2 3 6 7 10 11];
% The corresponding DPI has to be [1 2 3 4 6 7 8 10 11 12];
%
% USE: DPI=DetectPauses_VPItoDPI(ContourLength,VPI)
%
% Gheorghe Chistol, 26 Aug 2010

DPI=[]; %Data Pause Index, initialize, make it empty to start with
for i=2:length(VPI)
    if VPI(i)-VPI(i-1)==1
        DPI=[DPI VPI(i-1)];
    else
        DPI=[DPI VPI(i-1) VPI(i-1)+1];
    end
    %deal with the very last point
    if i==length(VPI) 
       DPI=[DPI VPI(end)];
       if VPI(end)<length(ContourLength)
          DPI=[DPI VPI(end)+1];
       end
    end
end
