function outfig = movie_2ch_john_figsetup(indata)
%Just plots the data loaded with readJohnTxts
%Expects a struct with fields {APDTime, Codons, Photons, Time}
% Write the frames with *_animate function

dsampfact = 10;

%Plot the figure
outfig = figure('Name', 'Movie_2chs_John', 'Position', [0 0 960 540]);
outfig.Color = [1 1 1];
ax1 = subplot(2,1,1);
hold(ax1, 'on')
plot(ax1, indata.Time, indata.Codons, 'Color', [.7 .7 .7]);
plot(ax1, indata.Time, smooth(indata.Codons, dsampfact)', 'Color', 'k');
ax2 = subplot(2,1,2);
hold(ax2, 'on')
plot(ax2, indata.APDTime, indata.Photons, 'Color', [.7 .7 .7]);
plot(ax2, indata.APDTime, smooth(indata.Photons, dsampfact)', 'Color', 'g');

ax1.FontSize = 16;
ax2.FontSize = 16;

axis(ax1, 'tight')
axis(ax2, 'tight')
ylabel(ax1, 'Distance (codons)')
ylabel(ax2, 'Photon Rate (kHz)')
xlabel(ax2, 'Time (s)')

%Edit this to get the figure to how you like it; or adjust it manually.

%After it's made how you like, run movie_2ch_john_animate to get the movie frames