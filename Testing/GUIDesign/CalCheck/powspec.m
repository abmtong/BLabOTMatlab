function [Pf, Ff, P, F] = powspec(dat, Fs, binfacts, splitnum, legnam)

if nargin < 5
    legnam = [];
end

%Hires max fsamp 62500;
%Lumicks fsamp 78125;
%Meitner max fsamp 66666etc or (2e5/3)


len = length(dat);

P = ( abs( fft(dat) ) .^2 )/Fs/(len-1);
P = P(2:end/2);
F = (2:len/2)*Fs/(len-1);
P = double(P(:))';
F = double(F(:))';

len2 = length(P);
Pf = cell(1,splitnum);
Ff = cell(1, splitnum);
%divide Pf into exponentially equivalent length
inds = round(len2 .^ [(0:splitnum )/ splitnum]);

for i = 1:splitnum
    Pf{i} = windowFilter(@mean, P(inds(i):inds(i+1)), [], binfacts(min(i, length(binfacts))));
    Ff{i} = windowFilter(@mean, F(inds(i):inds(i+1)), [], binfacts(min(i, length(binfacts))));
end
Pf = [Pf{:}]';
Ff = [Ff{:}]';
% Ff = smooth(F, filfact);
% Pf = smooth(P, filfact);

loglog(Ff,Pf, 'DisplayName', legnam)