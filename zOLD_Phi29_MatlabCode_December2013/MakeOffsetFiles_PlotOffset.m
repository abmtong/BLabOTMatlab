function MakeOffsetFiles_PlotOffset()
% This function displays the offset voltages Vx for traps A and B. You can
% use it when you want to double check that a given offset file does not
% have any anomalies. The offset voltage is the voltage that corresponds to
% zero force for various bead separations. The offset voltage is not zero
% because of interference effects. Bead separation is measured in volts,
% ranging from 0 to 10V
%
% MakeOffsetFiles_PlotOffset()
% 
% Gheorghe Chistol, 09 Feb 2012

    global analysisPath;
    [OffsetFile, OffsetFilePath] = uigetfile([analysisPath filesep 'offset' '*.mat'], 'MultiSelect', 'off');
    load([OffsetFilePath filesep OffsetFile]);

    figure('Units','normalized','Position', [0.0059 0.0625 0.4883 0.8359] );
    subplot(2,1,1); hold on;
    plot(offset.Mirror_X, offset.A_X, '.r'); 
    set(gca,'Box','on');
    xlabel('Bead Separation, (V)');
    ylabel('Zero-Force AX Voltage (V)');
    title(['Offset Voltages for ', OffsetFile]);
    
    subplot(2,1,2); hold on;
    plot(offset.Mirror_X,offset.B_X,'.b');    
    set(gca,'Box','on');
    xlabel('Bead Separation, (V)');
    ylabel('Zero-Force BX Voltage (V)');

end

