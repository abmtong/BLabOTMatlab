function out = procFran_polar(inst, inOpts)

opts.binsz = 0.5;
opts.rng = [1 147]+557-16;
%[558 631 704]-16
opts.color = [1 0 0];

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);

for i = 1:len
    %Format RTH to per bp
    %Extract thing
    tmp = inst(i).rthc;
    x = tmp(:,1);
    y = tmp(:,2);
    %Crop to range
    ki = x > opts.rng(1)-1 & x <= opts.rng(2);
    ycr = y(ki);
    %Assume the range is enough; else need to pad with 0s or something
    y = mean( reshape(ycr, [], diff(opts.rng)+1) , 1);
    
    %Then polarplot
    figure('Name', sprintf('Polar Plot: %s', inst(i).nam))
    zjPolarPlot(y, opts)
    axis equal
%     set(gca, 'CameraUpVector', [cos(-47.5/180*pi) sin(-47.5/180*pi) 0])
    zjRTH(y, opts)
    set(gcf, 'Name', ['zjRTH : ' inst(i).nam])
    %> print(gcf, './image.png','-dpng',sprintf('-r%d',96*4))
end