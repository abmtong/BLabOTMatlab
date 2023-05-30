function xwlcconvtester()


plrng = .3:.05:1;
frng = [5 10];

figure
hold on
len = length(plrng);
for i = 1:len
    ff = linspace(frng(1), frng(2), 100);
    xx = XWLC(ff, plrng(i), inf);
    %Fit to line and subtract it, simple start-end point
    m = diff(frng) / (xx(end) - xx(1) );
    %%INPROGRESS
    xx = xx-xx(1)+1;
    plot(xx,ff)
    
    
end