function x = ForceExt_FunctionWLC_Real(Param,F)
% This function serves as an interface to the real Worm Like Chain
% function. This is done for convenience.
% P  = Param(1);
% S  = Param(2);
% L  = Param(3)*0.34; %DNA contour length, converted from bp to nm
% x0 = Param(4);
%
% USE: x = ForceExt_FunctionWLC(Param,F)
%
% Gheorghe Chistol, 10 Feb 2012

P  = real(Param(1));
S  = real(Param(2));
L  = real(Param(3))*0.34; %DNA contour length, converted from bp to nm
x0 = real(Param(4));
F0 = real(Param(5));
kT = 4.14;

%L  = 3000*0.34;  %bp in nm
%L  = 4145*0.34;  %bp in nm
%L  = 5160*0.34;  %bp in nm
%L  = 6149*0.34;
F = F0+F; %apply the force offset

XoverL = ForceExt_XWLC(F, P, S, kT); %extension over contour length
x      = x0+XoverL*L; %extension in nm
end