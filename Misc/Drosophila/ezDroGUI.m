function ezDroGUI(inst)
%ezDrosophila GUI for checking data


if nargin < 1
    return
end

%Set up figure

fg = figure('Name', 'ezDrosophilaGUI');
%Axes for mask and data...
ax1 = axes('Position', [.1 .55 .8 .35]);
ax2 = axes('Position', [.1 .1 .8 .35]);
hold(ax1, 'on')
hold(ax2, 'on')
linkaxes([ax1, ax2], 'xy');

%Slider for frame no.s
frameSlider= uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.1 .90 .2 .08], 'Callback', @frameSlider_callback);
% channSlider= uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.3 .95 1 .1], 'Callback', @channSlider_callback);

%Set up slider
len = length(inst);
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
        fg.Name = sprintf('ezDrosophilaGUI: %s', frameSlider.String{ind});
        
        %Clear axes
        cla(ax1)
        cla(ax2)
        
        %Get data
        tmp = inst(ind);
        %Draw image
        surface(ax1, zeros(size( tmp.img  )), tmp.img, 'EdgeColor', 'none')
%         axis equal
        %Draw circles on accepted regions
        hei = length(tmp.rprops);
        for i = 1:hei
            if tmp.ki(i)
                plot(ax1,  tmp.rprops(i).bdy(:,2), tmp.rprops(i).bdy(:,1), 'r')
            end
        end
        colormap gray
        colorbar(ax1)
        
%         axis tight
        
        %And do the same for the mask
        surface(ax2, zeros(size( tmp.msk)), tmp.msk, 'EdgeColor', 'none')
%         axis equal
        %Draw circles on accepted regions
        for i = 1:hei
            if tmp.ki(i)
                plot(ax2, tmp.rprops(i).bdy(:,2), tmp.rprops(i).bdy(:,1), 'r')
            end
        end
        colormap gray
        colorbar(ax2)
%         axis tight

        xlim([1 size(tmp.msk, 2)])
        ylim([1 size(tmp.msk, 1)])
        
    end
end




