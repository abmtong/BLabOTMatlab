function [out, pws, si] = sumPWDV1bMoffV2(incon, varargin)
%Actually try to implement Moff's thing of evaluating a PWD by its Pspec sum

if ~iscell(incon)
    incon = {incon};
end

ip = inputParser;
addRequired(ip, 'incon');
addParameter(ip, 'fpre',{10,1}); %pre filter
addParameter(ip, 'binsz', 0.1); %pwd bin size
addParameter(ip, 'pwdmeth', 1); %pwd method
addParameter(ip, 'thr', 50); %peak integ sort keep threshold
addParameter(ip, 'sz', [8 12]); %pwd peak to keep
addParameter(ip, 'pad', 0); %pad PPWD with these many numbers
parse(ip, incon, varargin{:});

fpre = ip.Results.fpre;
binsz = ip.Results.binsz;
pwdmeth = ip.Results.pwdmeth;
thr = ip.Results.thr;
sz = ip.Results.sz;
nz = ip.Results.pad;

%Convert to frequency if needed
Fs=1/binsz;
sz = sort( 1./ sz); %convert to frequency

len = length(incon);
pws = cell(1,len);
pwsc = zeros(1,len);

pp = gcp('nocreate');

outwid = round(50/binsz);
out = zeros(1, outwid);
% nz = length(outwid)*5; %Zeros to pad

if isempty(pp)
    for i = 1:len
        %Filter, calc pwd with acorr2(diff(cdf(x)))
        pws{i} = pwd(windowFilter(@mean,incon{i},fpre{:}), binsz, pwdmeth, nz);
        pw = [pws{i} mean(pws{i}) * 0* ones(1,nz)];
        hei = length(pw);
        %Take power spectrum
        psp = abs(fft(pw).^2)/Fs/(hei-1);
        psx = (0:hei-1)/(hei-1)*Fs;
        pwsc(i) = sum(psp( psx > sz(1) & psx < sz(2)));
    end
else %same but parfor
    parfor i = 1:len
        %Filter, calc pwd with acorr2(diff(cdf(x)))
        pws{i} = pwd(windowFilter(@mean,incon{i},fpre{:}), binsz, pwdmeth); %#ok<PFBNS>
        pw = [pws{i} mean(pws{i}) * 0* ones(1,nz)];
        hei = length(pw);
        %Take power spectrum
        psp = abs(fft(pw).^2)/Fs/(hei-1);
        psx = (0:hei-1)/(hei-1)*Fs;
        pwsc(i) = sum(psp( psx > sz(1) & psx < sz(2))); %#ok<PFBNS>
    end
end

[s, si] = sort(pwsc);
pws = pws(si);

%keep best half of S's
sc = find(prctile(s, thr) <= s, 1);

%Those that are kept are those with si > sc
si(si < sc) = -1; %-1 if rejected, then kept in sorted order



for i = sc:len
    pw = pws{i};
    %End index is smaller of length of out and pw
    en = min(outwid, length(pw));
    out(1:en) = out(1:en) + pw(1:en);
end
pwx = (0:length(out)-1)*binsz;
figure('Name', sprintf('PWD: Data %s, Filter: %d/%d, PWDmethod %d, Threshold %d, Step size %0.1f-%0.1f', inputname(1), fpre{:}, pwdmeth, thr, 1/sz(2), 1/sz(1)))
hold on
% cellfun(@(x) plot( (0:length(x)-1)*binsz, x, 'Color', [.7 .7 .7]), pws(1:sc-1))
% cellfun(@(x) plot( (0:length(x)-1)*binsz, x), pws(sc:end))
plot(pwx, out/out(1), 'Color', 'k', 'LineWidth', 1)
line(mean(1./sz) * [1 1 2 2 2 3 3], [1 0 0 1 0 0 1], 'Color', 'b', 'LineWidth', 1 )
xlim([0, 30])
yl1 = max( out( find(diff(out)>0,1,'first') :end));
if isempty(yl1)
    yl1 = out(1);
end
yl2 = min(out);
ylim([yl2, yl1]/out(1))
end

function p = pwd(in, bsz, method, pad)
if nargin < 2
    method = 1;
end
pd = diff([0 cdf(in, bsz)]);
pd = pd(2:end-1); %first, end bins are past d
if method == 1 %acorr2, slow, good
    p = acorr2(pd);
elseif method == 2 %fft, quick, ok
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




