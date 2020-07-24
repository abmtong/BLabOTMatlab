function outPWD = kdf_leia(inData, binsz, sdgauss)

if nargin < 3
    sdgauss= .5;
end
if nargin < 2
    binsz = 0.05;
end

    function [y, x] = pwd(inx)
        y = real(ifft(abs(fft(inx)).^2));
        y = y(1:floor(end/2)) / y(1);
        x = binsz*(0:length(y)-1);
    end

inData = double(inData);

inData = smooth(inData, 20)';
% inData = inData(20:20:end);
%Fork 1: KDF or normHist

%take original pdf, either by kdf (me) or binning (leia)
% [p1, px] = kdf(inData, binsz, sdgauss);
% [p1, px] = kdftri(inData, binsz, 3);

[p1, px] = cdf(inData, binsz);
p1 = diff(p1);
px = px(1:end-1);

% p = normHist(inData, binsz);
% p1 = p(:,3);
% px = p(:,1);

%chop ends, b/c weirdness with low ends (want a KDF which is mostly constant in height)
% len = length(p1);
% ran = round(len/10):round(.9*len);
% p1 = p1(ran);
% px = px(ran);

%Fork 2: Second derivative as diff(diff(x))/4 (del2) or -diff(diff(x))/binsize^2 (actual second deriv., same sign as peaks)

%add its (negative) second derivative
% p2 = - diff(diff(p1)) / binsz^2;
% p1 = p1(2:end-1); %diff chops off a value, so do the same to p1
% px = px(2:end-1);
%Or use del2, like LEIA paper says
p2 = del2(p1);

p3 = p1 + p2;
% p3 = smooth(p3, 10)';

%square, because reasons?
% p3 = p3.^2;% .* sign(p3);
% p3 = smooth(p3, 10)';

%LEIA: = inerp1( maxima, pchip ) + interp1( minima, pchip)

[pk, pklc] = findpeaks(p3, px);
[tr, trlc] = findpeaks(-p3, px);
tr = -tr;

hi = interp1(pklc, pk, px, 'pchip', 'extrap'); %linear or pchip
lo = interp1(trlc, tr, px, 'pchip', 'extrap');

%take sum (reglar) or product (me) of upper/lower envelope
p4 = (hi+lo)/2;
% p4 = (hi-lo)/2;
% p4 = p3 - lo;
% p4 = p3;

[p1pw, p1pwx] = pwd(p1);
[p2pw, p2pwx] = pwd(p2);
[p3pw, p3pwx] = pwd(p3);
[phpw, phpwx] = pwd(hi);
[plpw, plpwx] = pwd(lo);
[phlpw, phlpwx] = pwd(hi+lo);
[outPWD, outX] = pwd(p4);
[pw5, pwx5] = pwd(outPWD);

figure, hold on, plot(px,p1), plot(px,p2), plot(px,p3), plot(px,hi), plot(px,lo), plot(px, p4, 'LineWidth', 2)
figure, hold on, plot(p1pwx, p1pw), plot(p2pwx,p2pw), plot(p3pwx,p3pw), plot(phpwx,phpw), plot(plpwx, plpw), plot(phlpwx, phlpw), plot(outX, outPWD, 'LineWidth', 2)
fnlp(outX, outPWD, 1)

fnlp(pwx5, pw5, 1)
end
