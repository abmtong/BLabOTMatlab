function out = readCalFiles()

path = uigetdir('C:\Data\');

if ~path
    return
end

d = dir([path filesep 'cal*.mat']);
d = {d.name};

len = length(d);
out.axk = zeros(1,len);
out.axa = zeros(1,len);
out.all = cell(1,len);
for i = 1:len
    load([path filesep d{i}]);
    out.axk(i) = cal.kappaAX;
    out.axa(i) = cal.alphaAX;
    out.bxk(i) = cal.kappaBX;
    out.bxa(i) = cal.alphaBX;
    out.all{i} = cal;
end