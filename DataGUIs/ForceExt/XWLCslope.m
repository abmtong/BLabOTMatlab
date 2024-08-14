function [outXpLm, outx] = XWLCslope(F, P, S, kT)
%Calculates the slope of the XWLC curve, which is proportional to SNR

%Defaults
if nargin < 1 || isempty(F)
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

%Take derivative by ( f(x+dx) - f(x+dx) ) / 2dx
dx = 1e-3; %relative dx, actual dx = F*dx. In case input F is smaller than dx, will never cross zero

xpl1 = XWLC(F*(1-dx), P, S, kT);
xpl2 = XWLC(F*(1+dx), P, S, kT);

slps = ( F*2*dx ) ./ ( xpl2 - xpl1 );
slpx = F ;

%Plot if no argout
if ~nargout
    figure, plot(slpx, slps)
    hold on, plot(slpx([1 end]), S * [1 1])
    xlabel('Force (pN)')
    ylabel('DNA stiffness (pN)')
else
    outXpLm = slps;
    outx = slpx;
end

