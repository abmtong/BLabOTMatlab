function out = polPassivep3(inst, inOpts)
%Fit to Boltzmann relation

%Function is: v(f) = (1+A)/(1+Aexp(Fdx/kT))
% v is normalized velocity (V/Vmax), f is normalized force (F/F(V=Vmax/2))
% Two parameters, A (dependence on mechanical transitions) and dx (distance to transition state)