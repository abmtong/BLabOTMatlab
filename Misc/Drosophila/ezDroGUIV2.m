function ezDroGUIV2(inst)
%ezDrosophila GUI for checking data


if nargin < 1
    return
end

%Make starting figure size as 3/4 of window size
scrsz = get(0, 'ScreenSize');
fgsz = [scrsz(3:4)*.125 scrsz(3:4)*.75];

%Set up figure
nam = inputname(1);
fg = figure('Name', 'ezDrosophilaGUI', 'Position', fgsz);
%Axes for mask and data...
ax1 = axes('Position', [.05 .55 .425 .35]);
ax2 = axes('Position', [.05 .1 .425 .35]);
ax3 = axes('Position', [.525 .55 .425 .35]);
ax4 = axes('Position', [.525 .1 .425 .35]);

title(ax1, 'Ch1 (Green)')
title(ax2, 'Ch1 (Green) Spots')
title(ax3, 'Ch2 (Red)')
title(ax4, 'Ch2 (Red) Spots')

hold(ax1, 'on')
hold(ax2, 'on')
hold(ax3, 'on')
hold(ax4, 'on')
linkaxes([ax1 ax2 ax3 ax4], 'xy');

%Slider for frame no.s
frameSlider= uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.05 .94 .85 .04], 'Callback', @frameSlider_callback);
% channSlider= uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.3 .95 1 .1], 'Callback', @channSlider_callback);

%Set up slider
len = length(inst)/2;
frs = [inst.frame];
chs = [inst.ch];
frameSlider.Min = 1;
frameSlider.Max = len;
frameSlider.String = arrayfun(@(x,y,z) sprintf('Frame %03d, Ch %02d, %03d spots',x, y,z ), [inst.frame], [inst.ch], cellfun(@length, {inst.rprops}), 'Un', 0);
frameSlider.SliderStep = [1 10] ./ (len-1); %Moves one position on arrow, 10 on bigmove
frameSlider.Value = 1;

%Load first data to start GUI
loadData_callback([],[],1);

    function frameSlider_callback(~,~)
        %If the slider is moved, load the corresponding data
        loadData_callback([], [], round(frameSlider.Value) )
    end

    function loadData_callback(~,~,ind)
        %Update figure title
        fg.Name = sprintf('ezDrosophilaGUI %s: %s', nam, frameSlider.String{ind});
        
        %Clear axes
        cla(ax1)
        cla(ax2)
        cla(ax3)
        cla(ax4)
        
        %Get data
        tmp1 = inst( frs == frs(ind) & chs == 1 );
        tmp2 = inst( frs == frs(ind) & chs == 2 );
        
        %Channel 1:
        %Draw image
        surface(ax1, zeros(size( tmp1.img  )), tmp1.img, 'EdgeColor', 'none')
%         axis equal
        %Draw circles on accepted regions
        hei = length(tmp1.rprops);
        for i = 1:hei
            if tmp1.ki(i)
                plot(ax1,  tmp1.rprops(i).bdy(:,2), tmp1.rprops(i).bdy(:,1), 'r')
            end
        end
        colormap gray
        colorbar(ax1)
        
%         axis tight
        
        %And do the same for the mask
        surface(ax2, zeros(size( tmp1.msk)), tmp1.msk, 'EdgeColor', 'none')
%         axis equal
        %Draw circles on accepted regions
        for i = 1:hei
            if tmp1.ki(i)
                plot(ax2, tmp1.rprops(i).bdy(:,2), tmp1.rprops(i).bdy(:,1), 'r')
            end
        end
        colormap gray
        colorbar(ax2)
%         axis tight
        
        %And the same for ch2
        
        %Draw image
        surface(ax3, zeros(size( tmp2.img  )), tmp2.img, 'EdgeColor', 'none')
%         axis equal
        %Draw circles on accepted regions
        hei = length(tmp2.rprops);
        for i = 1:hei
            if tmp2.ki(i)
                plot(ax3,  tmp2.rprops(i).bdy(:,2), tmp2.rprops(i).bdy(:,1), 'r')
            end
        end
        colormap gray
        colorbar(ax3)
        
%         axis tight

        %And do the same for the mask
        surface(ax4, zeros(size( tmp2.msk)), tmp2.msk, 'EdgeColor', 'none')
%         axis equal
        %Draw circles on accepted regions
        for i = 1:hei
            if tmp2.ki(i)
                plot(ax4, tmp2.rprops(i).bdy(:,2), tmp2.rprops(i).bdy(:,1), 'r')
            end
        end
        colormap gray
        colorbar(ax4)
%         axis tight
        
        %Set lims. Since they're linkaxes-ed, just one should be ok
        xlim([1 size(tmp1.msk, 2)])
        ylim([1 size(tmp1.msk, 1)])
        
    end
end




