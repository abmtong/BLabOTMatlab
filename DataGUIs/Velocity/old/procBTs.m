function [fs, dts, dcs] = procBTs()

[f, p] = uigetfile('phBT*.mat', 'MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f={f};
end

len = length(f);

fs = zeros(1,len);
dts = zeros(1,len);
dcs = zeros(1,len);

twin = 0.1; %average force +- 0.1s from start pt.
cff = @(y,x,t) y(x>t(1) & x < t(2));

for  i = 1:len
    load([p f{i}], 'stepback');
    kf = cellfun(@(x,y)cff(x,y, stepback.sb(1) + twin * [-1 1]), stepback.frc, stepback.tim, 'uni', 0);
    fs(i) = mean([kf{:}]);
    dts(i) = stepback.sb(2)-stepback.sb(1);
    dcs(i) = stepback.sb(4)-stepback.sb(3);
end

% figure, scatter(fs, dts)
% figure, scatter(fs, dcs)

vs = dcs./dts;

dcmin = 0;
fs = fs(dcs>dcmin);
dts = dts(dcs > dcmin);
dcs = dcs(dcs>dcmin);

fthr = 20;

tlo = dts(fs < fthr);
thi = dts(fs >= fthr);

clo = dcs(fs < fthr);
chi = dcs(fs >= fthr);

ste = @(x) std(x) / sqrt(length(x));

figure('Name', 'Time per bt event')
errorbar([ mean(tlo), mean(thi)], [std(tlo), std(thi)])
hold on, errorbar([ mean(tlo), mean(thi)], [ste(tlo), ste(thi)])

figure ('Name', 'Length per bt event'), errorbar([ mean(clo), mean(chi)], [std(clo), std(chi)])
hold on, errorbar([ mean(clo), mean(chi)], [ste(clo), ste(chi)])

vlo = clo ./ tlo;
vhi = chi ./ thi;
figure('Name', 'Velocity per bt event'), errorbar([ mean(vlo), mean(vhi)], [std(vlo), std(vhi)])
hold on, errorbar([ mean(vlo), mean(vhi)], [ste(vlo), ste(vhi)])


fbins = [5 15 25 35];
fcc = arrayfun(@(z,zz) fs(fs>z & fs< zz), fbins(1:end-1), fbins(2:end), 'Uni', 0);
tcc = arrayfun(@(z,zz) dts(fs>z & fs< zz), fbins(1:end-1), fbins(2:end), 'Uni', 0);
ccc = arrayfun(@(z,zz) dcs(fs>z & fs< zz), fbins(1:end-1), fbins(2:end), 'Uni', 0);

figure('Name', 'Time per bt event')
errorbar(cellfun(@mean, ccc), cellfun(@std, ccc))
hold on, errorbar(cellfun(@mean, ccc), cellfun(ste, ccc))

figure ('Name', 'Length per bt event')
errorbar(cellfun(@mean, tcc), cellfun(@std, tcc))
hold on, errorbar(cellfun(@mean, tcc), cellfun(ste, tcc))


vcc = cellfun(@(x,y) x./y, ccc, tcc,'uni', 0);

figure('Name', 'Velocity per bt event')
errorbar(cellfun(@mean, vcc), cellfun(@std, vcc))
hold on, errorbar(cellfun(@mean, vcc), cellfun(ste, vcc))

figure('Name', 'Velocity per bt event')
errorbar(cellfun(@mean, vcc), cellfun(@std, vcc))
hold on, errorbar(cellfun(@mean, vcc), cellfun(ste, vcc))

figure('Name', 'Velocity per bt event wght by length')
vwt = cellfun(@(x,y) sum(x)/sum(y), ccc , tcc);

% errorbar(vwt, cellfun(@(z,x,y)z* sqrt(std(x)/mean(), vcc))
% hold on, errorbar(vwt, cellfun(ste, vcc))

% figure, plot3(dts, dcs, fs, 'o')
% figure, plot3(dts, vs, fs, 'o')




    