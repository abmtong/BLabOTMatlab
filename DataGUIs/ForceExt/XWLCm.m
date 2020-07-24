function out = XWLCm()
%Calculates the slope of the XWLC curve, which is proportional to SNR

f = 0.1:0.1:60;
p = 50;
s = 900;
kT = 4.14;

xpl = XWLC(f, p, s, kT);

slps = ( f(2:end) - f(1:end-1) ) ./ ( xpl(2:end) - xpl(1:end-1) );

slpx = ( f(2:end) + f(1:end-1) ) /2;

figure, plot(slpx, slps)
hold on, plot(slpx([1 end]), s * [1 1])
xlabel('Force (pN)')
ylabel('DNA stiffness (pN/nm * 1nm)')
