function out = CalAvgV2()
%Averages multiple cal files of the 2444kb size type, norm's per point across traces (treats low freq the best)

[f, p] = uigetfile('F:\BackUpFrom180GBHardDisk\2008\*.dat', 'MultiSelect', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end
len = length(f);
Fs = 62500;
N = 625400;
y = zeros(N/2,1);

for i = 1:len
    dat = processHiFreq([p f{i}]);
    ps = abs( fft( dat.AX./dat.SA ) ).^2;
    y = y + ps(1:end/2);
end
y = y/len/Fs/(N-1);

x = 1:length(y);
x = x * Fs / (length(y));

x = double(x(2:end));
y = double(y(2:end));
figure('Name', sprintf('%s et al, N=%d', f{1}, len) ), loglog(x, y), xlim([x(1) x(end)]), ylim([y(end) y(1)]);

end

