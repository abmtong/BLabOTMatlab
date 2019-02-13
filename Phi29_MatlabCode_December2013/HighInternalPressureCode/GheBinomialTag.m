function Rnd = GheBinomialTag(Rnd, t, r, BinThresh, phageData, PlotInstr)
% This function goes through the data, looks at the Cdf values and
% determines if a given dwell contains a step. If a given dwell may contain
% a step, the function tags that dwell with a 'warning' tag, otherwise it
% tags the dwell with an 'ok' tag. This function can also plot the data
% with blue if the dwell does not contain steps. The data will be plotted
% in red if a given dwell is thought to contain a step.
%
% Gheorghe Chistol
% last modified March, 9th, 2009

% Rnd{Trace#}{Round#} is the data structure
% t - stands for the trace #
% r - index of the current binomial analysis round
% BinThresh is the confidence limit set on this analysis

% PlotInstr is the instruction of whether to plot the data or not. 
% If PlotInstr='plot' plot the data
% If PlotInstr='noplot' do not plot the data

    if strcmp(PlotInstr,'plot') %if the instructions are to plot the data
       figure; hold on;
    end

    for i=1:length( Rnd{t}{r}.total ) %go through each dwell within the current round of step finding
        if ( (Rnd{t}{r}.Cdf1(i) < BinThresh) || (Rnd{t}{r}.Cdf2(i)<BinThresh) ) %if either half of the data is below the confidence threshold
            Rnd{t}{r}.Tag{i} = 'warning';
            
            if strcmp(PlotInstr,'plot') %if the instructions are to plot the data
                plot(phageData(t).time(Rnd{t}{r}.start(i):Rnd{t}{r}.finish(i)), phageData(t).contour(Rnd{t}{r}.start(i):Rnd{t}{r}.finish(i)),'r');
                % The dwells that seem like they might have a step inside
                % are plotted in red
            end
        else
            Rnd{t}{r}.Tag{i} = 'ok';
            
            if strcmp(PlotInstr,'plot')
                plot(phageData(t).time(Rnd{t}{r}.start(i):Rnd{t}{r}.finish(i)), phageData(t).contour(Rnd{t}{r}.start(i):Rnd{t}{r}.finish(i)), 'Color', [.5 .5 .5]);
                % The dwells that do not have any steps inside are plotted
                % in blue
            end
        end
    end
    
    if strcmp(PlotInstr,'plot')
       plot(phageData(t).timeFit, phageData(t).contourFit,'k');
       % Plot the steps as found by the current analysis round
    end

%now the questionable dwells have been tagged, proceed to subsequent rounds
%of binomial analysis
disp(['Finished applying the Binomial Tags for trace ', num2str(t), ' round ', num2str(r)]);
