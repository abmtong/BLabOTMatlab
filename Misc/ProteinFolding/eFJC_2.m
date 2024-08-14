function out = eFJC_2(F, K, L, N, kT)
%xFJC of N links of L length, in the theoretical F = f(F,X) form

%Equation is: F*L/kT = N * (x/L - F/K) / (1 - (x/L-F/K)^2)
% F and X on both sides; solve via symbolic math

%Prep some substitution variables
FLkT = F*L/kT;
FK = F/K;
% Maybe do two variables, F/K and F/K*KLkT (so one vector, one constant) instead of two vectors. Eh works fine like this, @solve doesn't care?

syms xpL flkt fk
%Use lowers for sym variants of FLkT and FK

%Solving this equation is the majority of the runtime, so let's precalc and save it between runs
persistent efjc_solution
if isempty(efjc_solution)
    %Solve this equation
    eqn = flkt - 2*(xpL-fk)/(1- (xpL-fk)^2);
    s = solve(eqn, xpL);
    efjc_solution = vpa(s);
end

%Evaluate with subs
out = subs(efjc_solution, {flkt fk}, {FLkT FK});
out = double(out);

%Pick ... the most positive x?
npos = sum( sign(out), 2);
[~, maxi] = max(npos);

out = out(maxi, :) * L * N; %this is ext per L, multiply by L and N(?) to get total extension 

