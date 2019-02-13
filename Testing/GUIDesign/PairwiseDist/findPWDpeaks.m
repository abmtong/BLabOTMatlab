function out = findPWDpeaks(inData, filfact, binsz)

if nargin<3
    binsz = 0.2;
end
if nargin < 2
    filfact = 10;
end

if ~isa(inData, 'double')
    inData = double(inData);
end

[p, x] = calcPWD(inData, binsz);
p = smooth(p,filfact);
[pks, loc] = findpeaks(p, x, 'MinPeakProminence', 1e-2);
figure('Name','FindPWDPeaks')
findpeaks(p, x, 'MinPeakProminence', 1e-2)
ylim(p(10) + [-.1 .05])
xlim([0 30])
if isempty(pks)
    fprintf('No peaks found\n')
    return
end


%For some reason pks is column, loc is row
pks = [pks(1) pks'];
loc = [0 loc];
sz = diff(loc);
for i = 1:length(sz);
    text(mean(loc(i:i+1)), mean(pks(i:i+1)), sprintf('%0.1f',sz(i)));
end

out.pks = pks;
out.loc = loc;
out.sz = sz;