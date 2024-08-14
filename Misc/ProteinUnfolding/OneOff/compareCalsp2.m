function out = compareCalsp2(inst)
%Input: output of compareCals

%Plots and collates noise/Fc data

figure
hold on
len = length(inst);
for i = 1:len
    loglog(inst(i).cal.Fall, inst(i).cal.Pall)
end
%I guess hold on sets XYScale linear first so...
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
axis tight

%Create legend
lgn = arrayfun(@(x) sprintf('%0.1fpN', x), [inst.frc], 'Un', 0);
legend(lgn)


%Assume that it's force that's changing every time...
outraw = cell(1,4); %Force, k, noise, Fc
tmp = [inst.frc];
outraw{1} = tmp(:);
tmp = [inst.k];
outraw{2} = tmp(:);
tmp = [inst.noi];
outraw{3} = tmp(:);
tmp = arrayfun(@(x) x.cal.fit(1), inst);
outraw{4} = tmp(:);

out = [outraw{:}];
