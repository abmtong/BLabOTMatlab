function out = procFranFigs(opt)

if ~nargin
    opt = 2;
end

fg = gcf;
g0 = fg.Parent;
fgs = g0.Children;

%Apply constant settings to each figure
for i = 1:length(fgs);
    fg = fgs(i);
    %Set position
    fg.Position = [100 100 800 400];
    fg.Color = [1 1 1]; %White figure background
    
    %Set axis options
    ax = fg.Children(end);
    axis(ax, 'tight');
    ax.FontSize = 14;
    xlabel(ax, 'Position (bp)')
    ylabel(ax, 'Residence Time (s/bp)')
    
    bdys = [558 631 704]-16;
%     plot(ax, bdys([1 1 2 2 2 3 3],  -1  ,'k')
    
    
    switch opt
        case 1
            xlim(ax, [0 64*8]);
        case 2
            xlim(ax, [64*8+1, 704-16+5]);
                %opts.disp = ;
    end
end