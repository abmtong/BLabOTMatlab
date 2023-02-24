function out = omarfrcvel(frc, vel)

frc = frc(:)';
vel = vel(:)';

%Separate traces
dfthr = 2;
inds = [1 find( - frc(2:end) + frc(1:end-1) > dfthr )+1 length(frc)+1];
nn = length(inds)-1;
fs = cell(1,nn);
vs = cell(1,nn);
for i = 1:nn
    fs{i} = frc(inds(i):inds(i+1)-1);
    vs{i} = vel(inds(i):inds(i+1)-1);
end

%Make v non-increasing
vm = cell(1,nn);
for i = 1:nn
    tmp = vs{i};
    for j = length(tmp)-1:-1:1
        tmp(j) = max(tmp(j), tmp(j+1));
    end
    vm{i} = tmp;
end


%Method one: Fit each to fcn
fitfcn = @(x0,x) x0(1) * (1 + x0(2)) ./ (1 + x0(2) * exp(x * x0(3) / 4.14 ));
lb = [0 0 0];
ub = [inf inf inf];
oo = optimoptions('lsqcurvefit', 'Display', 'off');
fts = zeros(nn,3);
for i = 1:nn
    fts(i,:) = lsqcurvefit(fitfcn, [vm{i}(1) 1e-8 5], fs{i}, vm{i}, lb, ub, oo);
end

%And plot
figure, hold on
ax = gca;
for i = 1:nn
    ci = ax.ColorOrderIndex;
    plot(fs{i}, vm{i}, 'o');
    ax.ColorOrderIndex = ci;
    plot(fs{i}, fitfcn( fts(i,:) , fs{i}))
end
%And calculate average fits
% out = mean(fts, 1);
out = fts;



