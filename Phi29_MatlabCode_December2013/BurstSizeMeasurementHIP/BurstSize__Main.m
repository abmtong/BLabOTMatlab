function BurstSize__Main()
% Load trace, select a feedback cycle, filtering frequency. Then the
% function allows the user to select a region of the trace to compute the
% kernel density and thus measure the burst size. The regions have to be
% selected manually. Eventually I need to make a way of saving the results
% to one location.
%
% Gheorghe Chistol, 29 dec 2012

    Bandwidth = 2500; %in hertz
    FiltFreq  = 100; %initial filtering frequency
    FiltFact  = round(Bandwidth/FiltFreq); %Filtering Factor

    %% Select the portion of the data that you want analyzed
    Length = [];
    Time   = [];
    figure('Units','normalized','Position',[0.02 0.1 0.95 0.8],'Resize','on','Name','No Data Has Been Loaded Yet','PaperPosition',[0 0 8.1 6.5]);
    PlotAxis   = axes('Units','normalized','Position',[0.0873 0.0702 0.6323 0.8086],'Box','on','Layer','top','Tag','PlotAxes');
    xlabel('Time (sec)'); ylabel('Tether Length (bp)');

    KernelAxis = axes('Units','normalized','Position',[0.7244 0.0702 0.2708 0.8086],'Box','on','Layer','top','Tag','KernelAxes');
    set(gca,'XTickLabel',[],'YTickLabel',[]);

    BurstSize__Main_GUI('Initialize');
end