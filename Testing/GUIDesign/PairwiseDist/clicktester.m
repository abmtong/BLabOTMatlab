function outmatrx = clicktester()

fg = figure;

%generate axes array

nd = 4;
axs = gobjects(nd);
for i = 1:nd^2
	axs(i) = subplot(nd, nd, i);
end
axs = axs';
emptyaxes = ones(nd);

ended = 0;
while ~all(emptyaxes(:))
    %plot things
    for i = 1:nd^2
        if emptyaxes(i)
            plot(axs(i), randn(1,10))
            emptyaxes(i) = 0;
        end
    end
    
    %wait for click
    figure(fg) %make fg current
    prs = waitforbuttonpress;
    if prs == 0 %mouseclick
        curpt = fg.CurrentPoint; %in pixels
        lmb = fg.SelectionType; %lmb or rmb, see >doc Figure Properties
        %check whether overlaps an axis
        %get figure dims
        dms = fg.Position;
        ptx = curpt(1)/dms(3);
        pty = curpt(2)/dms(4);
        for i = 1:nd^2
            axp = axs(i).Position;
            tfx = axp(1) < ptx && ptx < (axp(1) + axp(3));
            tfy = axp(2) < pty && pty < (axp(2) + axp(4));
            if tfx && tfy
                cla(axs(i))
                emptyaxes(i) = 1;
            end
        end
    end
    pause(.1)%"real-time' loopiness
end
