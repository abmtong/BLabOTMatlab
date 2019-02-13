function CalculateVelocity_PlotFeedbackCycle(Data)
% Plot the raw data, filtered data, the stepping ladder.
% The SlipPauseFreeSegments are plotted in a different color to 

    OddColor    = 'y';
    EvenColor   = 'm';
    LadderColor = 'k';
    RawColor    = 0.7*[1 1 1];
    FilterColor = 'b';

    figure; hold on;
    %plot raw data
    plot(Data.Time, Data.Contour, '-', 'Color', RawColor);

    %plot the slip/pause-free-segments in alternating colors
    for s = 1:length(Data.SlipPauseFreeSegments.StartTime);
        StartTime  = Data.SlipPauseFreeSegments.StartTime(s);
        FinishTime = Data.SlipPauseFreeSegments.FinishTime(s);
        Ind = Data.Time>StartTime & Data.Time<FinishTime;

        if rem(s,2)==1
            plot(Data.Time(Ind), Data.Contour(Ind), '-', 'Color', OddColor);
        else
            plot(Data.Time(Ind), Data.Contour(Ind), '-', 'Color', EvenColor);
        end
    end

    %plot filtered data
    plot(Data.FiltTime, Data.FiltContour, '-', 'Color', FilterColor);

    %plot stepping ladder
    plot(Data.LadderTime, Data.LadderContour, '-', 'Color', LadderColor);
    close(gcf);
    figure; hold on;
    
    plot(Data.Time,Data.Force,'y');
    plot(Data.FiltTime,Data.FiltForce,'b');
    
end