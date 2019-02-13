function Pauses=DetectPauses_CheckSlope(Time, ContourLength, Pauses, VelThr)
% Check the slope, if the tentative pause is consistently sloped one way,
% it's probably not a real pause, just a slow translocation
%
% USE: Pauses=DetectPauses_CheckSlope(Time, ContourLength, Pauses, VelThr)
%
% Gheorghe Chistol, 28 Aug 2010

if ~isempty(Pauses.Index) %if there are any pauses, sort through
    %% Calculate the Slope of each pause
    for i=1:length(Pauses.Index)
        X = Time(Pauses.Index{i});
        Y = ContourLength(Pauses.Index{i}); %in base-pairs
        p = polyfit(X,Y,1); %fit to a line
        Slope(i)=p(1); %select the slope

        N=length(Pauses.Index(i)); %nr of data points in this pause
        if abs(Slope(i))>VelThr/sqrt(N) 
            %this tentative pause is too sloped, so it's not a real pause
            %the Factor penalizes very long sloped sections
            PauseStatus(i)=0;%this is not a pause
        else
            PauseStatus(i)=1;%this is a pause
        end
    end


    %find the pauses that have been thrown away; RI=RemoveIndex
    RI = find(PauseStatus==0);
    N=length(RI); %number of pauses that will be canceled due to non-zero slope
    if N>0
        disp([num2str(N) ' tentative pauses have been cancelled due to slope']);
        %remove the data that corresponds to these mis-identified pauses
        Pauses.Start(RI)=[];
        Pauses.End(RI)=[];
        Pauses.Duration(RI)=[];
        Pauses.Location(RI)=[];
        Pauses.LocationSTD(RI)=[];
        Pauses.Index(RI)=[];
    end
end