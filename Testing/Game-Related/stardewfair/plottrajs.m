function plottrajs(ncoin, ratios, nspin, ntraj)

figure('Name', 'Spin To Win')
ends = zeros(length(ratios), ntraj);
ax = gca;
hold(ax, 'on')
for i = 1:ntraj
    for j = 1:length(ratios)
        traj = zeros(1, 1+nspin);
        for k = 1:10
            traj = traj + spin(ncoin, ratios(j), nspin);
        end
        plot(ax, log(traj/10), 'Color', getColor(j))
        ends(j,i) = log(traj(end)/10);
    end
    if mod(i, 10)
        drawnow
    end
end

for j = 1:length(ratios)
    yl = ylim;
    text(1, yl(2)/5 + j * yl(2)/10, sprintf('%0.3f, lgmean %0.1f, sd %0.1f', ratios(j), mean(ends(j,:)), std(ends(j,:))), 'Color', getColor(j))
end

xlim([1 nspin])

    function outColor = getColor(i)
        col0 = 2/3; %blue
        dcol = 1/length(ratios);
        h = mod(col0 + (i-1)*dcol,1); %Color wheel
        s = 1; %1 for bold colors, .25 for pastel-y colors
        v = .6; % too high makes yellow difficult to see, too low and everything is muddy
        outColor = hsv2rgb( h, s, v);
    end
end