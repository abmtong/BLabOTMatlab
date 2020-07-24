function x = ForceExt_XWLC_LookupTable(F)
% Here we pre-fit the experimentally measured curves to 9th degree polynomials and use them to
% generate a lookup table of Normalized Extension vs Force. We use the lookup table to compute x/L
% given a certain force. This helps compensate for the fact that at high force our traps are no
% longer linear.
%
% USE: x = ForceExt_XWLC_LookupTable(F)
%
% Gheorghe Chistol, 1 Jun 2012

%load the lookup table file
load('LookupTable_031312N58.mat'); %contains Force and NormalizedExtension

x = interp1(Force, NormalizedExtension, F, 'linear');

end    