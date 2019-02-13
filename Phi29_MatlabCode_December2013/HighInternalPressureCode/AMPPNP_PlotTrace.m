function AMPPNP_PlotTrace(FilterBandwidth)
% This is a function that allows you to load a phage trace, and plot it for
% diagnostic purposes. This is to be used as an exploratory tool - a quick
% and dirty way of inspecting your data.
%
% AMPPNP_PlotTrace(FilterBandwidth)
%
% Gheorghe Chistol, 23 Nov 2010
%global X Y;
Bandwidth = 2500;
if nargin<1
    Filter=100; %default filter bandwidth
else
    Filter = FilterBandwidth;
end
FiltFact  = round(Bandwidth/Filter); %Filtering Factor
Phage=LoadPhage(); %the location of the file is stored in analysisPath

% ---- Select the portion of the data that you want analyzed
Length = [];
Time   = [];
Figure1 = figure; 
set(Figure1,'Position',[9 49 667 642]);
hold on;
X=[];
Y=[];
for i=1:length(Phage.contour)
    clear FiltTime FiltLength;
    FiltTime   = FilterAndDecimate(Phage.time{i}, FiltFact);
    FiltLength = FilterAndDecimate(Phage.contour{i}, FiltFact);
    
    %Length = [Length Phage.contour{i}];
    %Time   = [Time   Phage.time{i}];
    plot(FiltTime,FiltLength,'b');
    X(i) = round(1000*mean(FiltTime))/1000;
    Y(i) = round(1000*mean(FiltLength))/1000;
end
for i=1:length(Phage.contour)
    %X(i)
    %Y(i)
    %num2str(i)
    if ~isnan(X(i)) && ~isnan(Y(i))
        %disp('trying now')
        text(X(i),Y(i),['#' num2str(i)],'FontSize',8);
    end
end

hold off;
xlabel('Time (sec)');
ylabel('Tether Length (bp)');
legend(['File: ' Phage.file ]);