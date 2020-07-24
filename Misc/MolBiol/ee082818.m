function ee082818( fracs )
if nargin < 1
    fracs = []; %sizes in kb
end
%{
electroelution
082818
1% agarose
generuler 1kb+ ladder
prerun 1.5h
collect 10rpm(or whatever the setting means) * 2min = ~750uL per tube, 56 fractions
%}
fragszs = [1.5 2  3  4  5  7];% 10 20];
stfrc =   [1   6 15 23 28 40];
enfrc =   [3   8 17 25 33 45]; %of 56 fractions
t0 = 90;
dt = 2;

%light blue dye was ~1cm past tunnel [at start of collection?]
%dark blue dye run times
dblst = 40;
dblen = 44;

totim = @(x)t0+ (x-1)*dt;

stt = totim(stfrc);
ent = totim(enfrc+1);

figure, plot(stt, fragszs, 'o'), hold on, plot(ent, fragszs, 'o')
rectangle('Position', [totim(dblst) min(fragszs) totim(dblen)-totim(dblst) max(fragszs)], 'EdgeColor', [.3, .3, 1])
xlabel('Time (m)')
xlim([totim(1) totim(56)])
ylabel('Fragment size (kb)')

m = polyfit(stt, fragszs, 2);
n = polyfit(ent, fragszs, 2);
x = 80:.1:240;
y1 = polyval(m, x);
y2 = polyval(n, x);
plot(x, y1)
plot(x, y2)


%run genome cut with PspGI and BstEII, leading to
% 2.7kb - 9.8kb - 7kb
%Aim to collect over a similar range of times.

%Output estimated elution time, estimation is done by a lookup table from the quadratic fit to known sizes (inaccurate outside range)
if ~isempty(fracs)
    for i = 1:length(fracs)
        t1 = x(find(fracs(i) < y1, 1));
        t2 = x(find(fracs(i) < y2, 1));
        line([t1 t2], fracs(i)* [1 1])
        fprintf('Fragment of %0.1fkb is expected to elute at %3.0fm to %3.0fm\n', fracs(i), t1, t2)
    end
end

end