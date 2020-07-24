function hifill_yyaxis(ax, totlen)
%Adds an axis on the right of the plot that corresponds to % packaging, assuming 21kb construct

if nargin < 1
    ax = gca;
end
if nargin < 2
    %Total length
    totlen = 20e3;
end
%Genome length
genlen = 19.3e3;

ya = ax.YAxis;

%Create second axis if necessary
if length(ya) < 2
    yyaxis(ax, 'right');
end

%Axis to match
yl1 = ya(1).Limits;
%Match second axis
ya(2).Limits = yl1;
%Get tick values
yt = ya(1).TickValues;
%Convert values to labels
ya(2).TickLabels = arrayfun(@(x) sprintf('%0.0f', 100 * (totlen-x)/genlen), yt, 'Un', 0);
ylabel('Percent Filling')