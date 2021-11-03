function out = rmShortSteps(intr, ptmin)
%Removes dwells with a length <ptmin, assigns it to the previous dwell(?)

%Mean to be used after fitVitterbi for 'denoising'

[in, me] = tra2ind(intr);
dw = diff(in);
ki = dw > ptmin;

outme = me(ki);

%Must keep both edges
outin = in([true ki]);

out = ind2tra(outin, outme);



