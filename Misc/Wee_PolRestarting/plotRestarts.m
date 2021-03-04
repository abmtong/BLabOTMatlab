function plotRestarts(rs)

%Restart struct with fields {ind, long, frc, fp}

Fs = 4000/3;

frcrng = [4 6 10 13 17 25];

dws = cellfun(@(x) diff(x)/Fs, {rs.ind});
frcs = [rs.frc];
longs = cellfun(@(x)x(2), {rs.long});

%Plot dw-frc scatter, colored by longs
figure, subplot(2,1,1)
scatter(frcs, dws, [], longs)
colormap jet
colorbar

%Plot ccdf by frcrng
nf = length(frcrng)-1;
dwfs = cell(1, nf);
fs = zeros(1,nf);
for i = 1:nf
    ki = frcs >= frcrng(i) & frcs < frcrng(i+1);
    d = dws(ki);
    d(logical(longs(ki))) = inf;
    dwfs{i} = d;
    fs(i) = mean(frcs(ki));
end
xlabel('Force (pN)')
ylabel('Restart Time (s), red = break')

pcc = @(x) plot( sort(x), (length(x):-1:1) / length(x) );
subplot(2,1,2)
hold on
cellfun(pcc, dwfs)
set(gca, 'YScale', 'log')
legend(arrayfun(@(x) sprintf('%0.1fpN', x), fs, 'Un', 0))
axis tight
xlabel('Restart Time (s)')
ylabel('CCDF (arb.)')
