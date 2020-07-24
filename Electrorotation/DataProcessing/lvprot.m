function [outv outx] = lvprot(inx, iny)

%Takes input protocol, outputs what LV would use (circsmooth by 3, spline)
%Splining doesn't do much actually
%Assumes inx(1,1) == 0, inx is degrees

%Might be more accurate to do diff(protfull) instead
% Seems to mess up the end bit? Too upsampled for spline to work similarly?

%if only one nargin, expect protfull(:,3)
if nargin == 1
    iny = diff(inx);
    inx = inx(1:end-1);
else
    inx = inx(:);
    iny = iny(:);
    iny = circsmooth(iny, 3);
end

xv = (0:.1:359.9)';
yv = spline([inx; 360], [iny; iny(1)], xv);

outv = [xv yv];

if nargout > 1
    %Mimic labview protocol position-time calculation
    dt = 0.01;
    t =3;
    
    
end