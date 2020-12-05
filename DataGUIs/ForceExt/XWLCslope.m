function [outXpLm, outx] = XWLCslope(F, P, S, kT)
%Calculates the slope of the XWLC curve, which is proportional to SNR

%Defaults
if nargin < 1
    F = 0.1:0.1:60;
end
if nargin < 2
    P = 50;
end
if nargin < 3
    S = 900;
end
if nargin < 4
    kT = 4.14;
end

xpl = XWLC(F, P, S, kT);

slps = ( F(2:end) - F(1:end-1) ) ./ ( xpl(2:end) - xpl(1:end-1) );
slpx = ( F(2:end) + F(1:end-1) ) /2;

%Plot if no nargout
if ~nargout
    figure, plot(slpx, slps)
    hold on, plot(slpx([1 end]), S * [1 1])
    xlabel('Force (pN)')
    ylabel('DNA stiffness (pN/nm * 1nm)')
else
    outXpLm = slps;
    outx = slpx;
end

