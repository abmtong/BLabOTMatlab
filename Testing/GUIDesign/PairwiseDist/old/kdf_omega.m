function [out, yr] = kdf_omega(iny, ybinsz, winsz, sdmult)

if nargin < 4
    sdmult = .2;
end
if nargin < 3
    winsz = 5;
end
if nargin < 2
    ybinsz = 0.1;
end

if ~isa(iny, 'double')
    iny = double(iny);
end

len = length(iny);
yr = (floor(min(iny)/ybinsz):ceil(max(iny)/ybinsz)) * ybinsz;
yr = [(-10:-1)*ybinsz+yr(1) yr (1:10)*ybinsz+yr(end)]; %pad bdys
out = zeros(1, length(yr));

%other/plotting
outX = ybinsz*(0:(length(out)-1));

for i = 1:len
    wmin = max(1, i-winsz);
    wmax = min(len, i+winsz);
    snip = iny(wmin:wmax);
    
    %rm outliers
    [tf, snip] = isoutlier(snip);
%     if sum(tf)
%         fprintf('%d pts outlierd', sum(tf))
%     end
    
    mn = mean(snip);
    sd = std(snip) * sdmult;
    np = normpdf(yr, mn, sd);
    out = out + np;%/sum(np);
end

%post processing
% out = out.^.5;
% out = out + del2(out);
% out = smooth(out,10,'rlowess')';
out = smooth(out,25)';

[pk, pklc] = findpeaks(out, yr);
[pk, pklc] = findpeaks(out, yr, 'MinPeakProminence', max(yr)/10);
[tr, trlc] = findpeaks(-out, yr);
tr = -tr;

hi = interp1(pklc, pk, yr, 'pchip', 'extrap'); %linear or pchip
lo = interp1(trlc, tr, yr, 'pchip', 'extrap');

med = median(out);
mad = median( abs(out - med) );
madscale = 1.4826; %for normal data, sd > mad conversion
uplim = med + 3*mad*madscale;

out(out>uplim) = uplim;

% out = hi - lo;
% out(out<0) = 0;

% out = out - lo;

% hi = smooth(hi, 25)';
out = out ./ (hi);
% out = smooth(out, 25');

% out = out./real(sqrt(lo));
% stin = find(isinf(out),1);
% enin = find(isnan(out),1);
% out = out(1:enin-1);
% yr = yr(1:enin-1);
% outX = outX(1:enin-1);


figure('Name', sprintf('bsz %0.2f, wsz %d, sdmult %0.2f', ybinsz, winsz, sdmult))
subplot(2, 1, 1)
plot(yr, out)
subplot(2, 1, 2), hold on
% cv = conv(out, out);
% cv = cv(round(end/2):end);
% cv = cv / cv(1);
% plot(outX, cv)
ff = real(ifft(abs(fft(out)).^2));
ff = ff / ff(1);
plot(outX, ff)
% cv2 = cconv(out, out, length(out));
% cv2 = cv2 / cv2(1);
% cv2 = cv2/cv2(1);
% plot(outX, cv2)
xc = xcorr(out, out);
xc = xc(round(end/2):end) / xc(1);
xc = xc/xc(1);
plot(outX, xc)
xlim([0 30])
ylim(sort([min([xc(1:find(outX>30,1)) ff(1:find(outX>30,1))]) 1]))

psps = real(ifft(abs(fft(ff(1:5000))).^2));
psps = psps/psps(1);
figure, plot(outX(1:5000), psps);
xlim([0 30])