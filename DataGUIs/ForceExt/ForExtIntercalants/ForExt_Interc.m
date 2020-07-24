function outExt = ForExt_Interc( inFor, inXWLC, dx, n, KI )
%Calculates the intercalated extension given by these ext, for.s.

%inXWLC = [PerLen(nm) StrMod(pN) ConLen(bp)]

kT = 4.14;%pN-nm, 1.38e-23J/K * 300K * J/1e-21pN-nm
% outExt = ForceExt_XWLC_Wikipedia(inFor, inXWLC(1), inXWLC(2)) ...
%          .* (inXWLC(3)*.34 + dx* inXWLC(3)/n * (1+ exp(-inFor*dx/kT)/n/KI ).^-1 ); 
         %could factor inXWLC(3), but reads worse
         
         
outExt = inXWLC(3) * (.34 * ForceExt_XWLC_Wikipedia(inFor, inXWLC(1), inXWLC(2)) ...
                      + dx/n * (1+ exp(-inFor*dx/kT)/n/KI ).^-1 );
         %could factor inXWLC(3), but reads worse