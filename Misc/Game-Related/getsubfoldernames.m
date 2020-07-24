function out = getsubfoldernames()
%for e.g. phase shift song names
p = uigetdir('D:\Games\Phase Shift\music');

d1 = dir(p);
d1 = d1([d1.isdir]); %only take dirs
d1= {d1.name}; %get names
d1 = d1(3:end); %remove . and ..

out =[];
for i = 1:length(d1)
    d2 = dir([p filesep d1{i}]);
    d2 = d2([d2.isdir]);
    d2 = d2(3:end);
    out = [out {d2.name}]; %#ok<AGROW>
end