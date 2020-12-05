function plotoff(inoff)
%plots offset file

figure Name OffsetFile
hold on
if isfield(inoff, 'MX')
    xx = inoff.MX;
elseif isfield(inoff, 'TX')
    xx = inoff.TX;
end
plot(xx, inoff.AX, 'Color', 'b', 'LineWidth', 2);
plot(xx, inoff.BX, 'Color', 'g', 'LineWidth', 2);
plot(xx, inoff.AY, 'Color', 'b');
plot(xx, inoff.BY, 'Color', 'g');

axis tight
