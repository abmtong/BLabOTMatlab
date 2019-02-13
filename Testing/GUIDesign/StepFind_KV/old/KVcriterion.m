function tf = KVcriterion(curQE, dQE, penalty)

%Original K-V Criterion
%tf = dQE/curQE < penalty

%Remove length dependence
%Penalty = (MinStepHeight)^2*(MinStepWidth)
tf = dQE < -penalty;