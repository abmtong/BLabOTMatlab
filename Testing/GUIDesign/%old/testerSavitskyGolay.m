%Probably better to just use mean (sg = 0), unless you're looking for 2.5bp steps

deg = [1:4:21];
wid = [101];

for i = deg
    for j = wid
        if i - j - 1 >= 0
            continue
        end
        figure('Name',sprintf('SGolay deg:%d wid:%d',i,j))
        hold on
        plot(guiC, 'Color', [.8 .8 .8])
        plot(sgolayfilt(double(guiC), i, j));
        hold off
    end
end