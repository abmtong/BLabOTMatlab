function fitRise_plotraw(inst)

%For each data...

opts.fil = 3;

dy = 500;
ist = 100-18-2; %Start index, for cropping. hacky

fg = figure;
ax(1) = subplot2(fg, [2 1], 1);
ax(2) = subplot2(fg, [2 1], 2);
hold(ax(1), 'on')
hold(ax(2), 'on')

%Resort by green intensity
maxg = arrayfun(@(x) max(x.vals2), inst);
[~, si] = sort(maxg, 'descend');
inst = inst(si);


for i = 1:length(inst);

    %Get data
    tmp1c = inst(i).vals1(ist:end);
    tmp2c = inst(i).vals2(ist:end);
    
    %Filter
    tmp1fc = windowFilter(@median, tmp1c, opts.fil, 1);
    tmp2fc = windowFilter(@median, tmp2c, opts.fil, 1);
    
    %Don't scale. just reusing code
    minmax1 = [0 1];
    minmax2 = [0 2];
    
    %And plot: raw, filtered, fit
    plot(ax(1), dy*(i-1)+ (tmp1c - minmax1(1)) / minmax1(2), 'Color', hsv2rgb( 1/3, .3, .8 ) )
    plot(ax(1), dy*(i-1)+ (tmp1fc - minmax1(1)) / minmax1(2), 'Color', hsv2rgb( 1/3, 1, .5 ) )
    
    plot(ax(2), dy*(i-1)+ (tmp2c - minmax2(1)) / minmax2(2), 'Color', hsv2rgb( 0, .3, .8 ) )
    plot(ax(2), dy*(i-1)+ (tmp2fc - minmax2(1)) / minmax2(2), 'Color', hsv2rgb( 0, 1, .5 ) )
    
    %Dont plot if isnan (was skipped)
    if ~isnan(inst(i).fr(1))
        %Plot fit line
        plot(ax(1), dy*(i-1)+ (inst(i).frraw{1,1}{2} - minmax1(1)) / minmax1(2), 'Color', hsv2rgb( 1/3, 1, .3 ), 'LineWidth', 1 )
        %And a vertical line at the point
        plot(ax(1), (1+inst(i).fr(1)) * [1 1], dy* ((i-1)+[0 1]), 'Color', 'g')
    end
    if ~isnan(inst(i).fr(2))
        plot(ax(2), dy*(i-1)+ (inst(i).frraw{1,2}{2} - minmax2(1)) / minmax2(2), 'Color', hsv2rgb( 1, 1, .3 ), 'LineWidth', 1 )
        plot(ax(2), (1+inst(i).fr(2)) * [1 1],  dy*((i-1)+[0 1]), 'Color', 'r')
    end
    
end

linkaxes(ax, 'xy')