function out = rndtesttr()

%make random steps, equal chance
sts = [7 8 9];
%noise
sd = 3;
%dwell time
stlen = [50 70];

%number of steps
nstep = 20;

out = [];
curhei = 0;
for i = 1:nstep
    if i == round(nstep/2)
        len = 50;
    else
        len = randi(range(stlen)) + stlen(1);
    end
    curhei = curhei + sts(randi(2));
    out = [out curhei*ones(1,len)]; %#ok<AGROW>
end

% out = smooth(out, 20)';

out = out + randn(1, length(out)) * sd;
        