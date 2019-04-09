 function shiftplotV2_mlans
    y = 0;     %shared variable
    ax = gca;
    fig = ancestor(ax, 'figure');
    plot( ax, randn(1,50) * 10 );
    XL = get(ax, 'XLim');
    hold(ax, 'on')
    h = plot(ax, XL, [y y]);
    hold(ax, 'off');
    set(fig, 'WindowKeyPressFcn', @KeyPressCb);
    function KeyPressCb(~,evnt)
        if strcmp(evnt.Key,'uparrow')
          fprintf('up!\n');
          y = y + 1;
          set(h, 'YData', [y y]);
        elseif strcmp(evnt.Key, 'downarrow')
          fprintf('down!\n');
          y = y - 1;
          set(h, 'YData', [y y]);
        end
    end
  end