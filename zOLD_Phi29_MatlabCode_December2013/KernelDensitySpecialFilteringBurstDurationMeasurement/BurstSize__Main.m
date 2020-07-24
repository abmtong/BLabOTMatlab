function BurstSize__Main()
% Load trace, select a feedback cycle, filtering frequency. Then the
% function allows the user to select a region of the trace to compute the
% kernel density and thus measure the burst size. The regions have to be
% selected manually. Eventually I need to make a way of saving the results
% to one location.
%
% Gheorghe Chistol, 29 dec 2012

    Bandwidth = 2500; %in hertz
    FiltFreq  = 250; %initial filtering frequency
    FiltFreqKD = 60; % Kernel density peaks are found easily with heavier filtering
    FiltFact  = round(Bandwidth/FiltFreq); %Filtering Factor
    FiltFactKD  = round(Bandwidth/FiltFreqKD); % filtering factor

    
    %% Select the portion of the data that you want analyzed
    Length = [];
    Time   = [];
    figure('Units','normalized','Position',[0.0073    0.0651    0.9876    0.8659],'Resize','on','Name','No Data Has Been Loaded Yet','PaperPosition',[0 0 12 6]);
    PlotAxis   = axes('Units','normalized','Position',[0.0756    0.0702    0.6440    0.8086],'Box','on','Layer','top','Tag','PlotAxes');
    xlabel('Time (sec)'); ylabel('Tether Length (bp)');

    KernelAxis = axes('Units','normalized','Position',[0.7244    0.0702    0.2630    0.8086],'Box','on','Layer','top','Tag','KernelAxes');
    set(gca,'XTickLabel',[],'YTickLabel',[]);

    BurstSize__Main_GUI('Initialize');
end