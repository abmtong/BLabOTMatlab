for i = 1:length(KernelCurve)
    figure;
    plot(KernelCurve(i).x,KernelCurve(i).y,'b');
    axis([-30 30 0 1.1]);
    set(gca,'FontSize',15);
    title(num2str(i));
    [a b]=ginput(1);
    close gcf;
end
