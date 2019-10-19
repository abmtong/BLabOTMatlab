function sumPWDV1bMoff(incon, fpre)
%Actually try to implement Moff's thing of evaluating a PWD by its Pspec sum
% Inputs not handled correctly yet, should take in:
% PWD filtering, binsize; PS peak integration, PS score threshold cutoff

if ~iscell(incon)
    incon = {incon};
end

%Default filter (for @windowFilter) option
if nargin < 2
    fpre = {10 2};
end

binsz = 0.1;
Fs=1/binsz;
sz = [7 8];
sz = sort( 1./ sz); %convert to frequency
thr = 50; %percentile cutoff for keep, [higher = more strenuous]
pwdmeth = 2;
%Moff did PWD judgment by integral of FFT [powspec], can we also do that?
% Since it relies on FFT, cannot post-filter

len = length(incon);
pws = cell(1,len);
pwsc = zeros(1,len);

pp = gcp('nocreate');

if isempty(pp)
    for i = 1:len
        %Filter, calc pwd with acorr2(diff(cdf(x)))
        pws{i} = pwd(windowFilter(@mean,incon{i},fpre{:}), binsz, pwdmeth);
        hei = length(pws{i});
        %Take power spectrum
        psp = abs(fft(pws{i}).^2)/Fs/(hei-1);
        psx = (0:hei-1)/(hei-1)*Fs;
        pwsc(i) = sum(psp( psx > sz(1) & psx < sz(2)));
    end
else %same but parfor
    parfor i = 1:len
        %Filter, calc pwd with acorr2(diff(cdf(x)))
        pws{i} = pwd(windowFilter(@mean,incon{i},fpre{:}), binsz, pwdmeth);
        hei = length(pws{i});
        %Take power spectrum
        psp = abs(fft(pws{i}).^2)/Fs/(hei-1);
        psx = (0:hei-1)/(hei-1)*Fs;
        pwsc(i) = sum(psp( psx > sz(1) & psx < sz(2)));
    end
end

[s, si] = sort(pwsc);
pws = pws(si);

%keep best half of S's
si = find(prctile(s, thr) < s, 1);

outwid = round(50/binsz);
out = zeros(1, outwid);

for i = si:len
    pw = pws{i};
    %End index is smaller of length of out and pw
    en = min(outwid, length(pw));
    out(1:en) = out(1:en) + pw(1:en);
end
pwx = (0:length(out)-1)*binsz;
figure, hold on
cellfun(@(x) plot( (0:length(x)-1)*binsz, x, 'Color', [.7 .7 .7]), pws(1:si-1))
cellfun(@(x) plot( (0:length(x)-1)*binsz, x), pws(si:end))
plot(pwx, out/out(1), 'Color', 'k', 'LineWidth', 1)
xlim([0, 30])
end

function p = pwd(in, bsz, method)
if nargin < 2
    method = 1;
end
pd = diff([0 cdf(in, bsz)]);
pd = pd(2:end-1); %first, end bins are past d
if method == 1 %acorr2
    p = acorr2(pd);
elseif method == 2 %fft
    p = ifft(abs(fft(pd)).^2);
    p=p/p(1);
else %fft, trim to middle 2^n pts
    %do pow2... reverse padding
    ppow2 = 2^floor(log2(length(pd)));
    %take middle 2^ppow2 points
    si = ceil( (length(pd)-ppow2 +1) /2);
    pd = pd( si:si+ppow2-1 );
%     p=xcorr(diff([0 cdf(in, bsz)]));
    p = ifft(abs(fft(pd, ppow2)).^2);
%     p = p( floor(end/2)+1:end );
    p=p/p(1);
end

end




