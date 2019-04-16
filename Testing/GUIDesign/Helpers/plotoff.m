function plotoff(inoff)
%plots offset file

figure Name OffsetFile
hold on
plot(inoff.MX, inoff.AX, 'Color', 'b', 'LineWidth', 2);
plot(inoff.MX, inoff.BX, 'Color', 'g', 'LineWidth', 2);
plot(inoff.MX, inoff.AY, 'Color', 'b');
plot(inoff.MX, inoff.BY, 'Color', 'g');
