function [out, outtrue] = polTrace(  )


n = 600; %Steps
dw = [( [1333/30; 1333/5] ) [0.9; 0.1]]; %Set up dwells
sig = 3; %Noise, bp

%Make dwells
nk = size(dw, 2);
dws = cell(1,nk);
for i = 1:nk
    dws{i} = max(round(exprnd(dw(i,1), 1, round(dw(i,2)*n))), 1);
end
dws = [dws{:}];
dws = dws(randperm(length(dws)));

in = cumsum([1 dws]);
me = 1:length(dws);

outtrue = ind2tra(in, me);

out = outtrue + randn(size(outtrue))*sig;

