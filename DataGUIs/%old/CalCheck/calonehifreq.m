function calonehifreq( )
%plot power spectra of hifreqfiles

%calc'd as NV^2/Hz, since 1NV = 1e3nm (alpha), to conver to A^2/Hz,
%  mult. by 1e8

[f, p] = uigetfile('D:\Data\*.dat', 'MultiSelect', 'on');
if ~p
    return
end

if ~iscell(f)
    f = {f};
end
Fs = 62.5e3;
ln = length(f);
figure('Name', sprintf('%s spectra, et al', f{1}))
for ii = 1:ln

mmp = memmapfile([p f{ii}], 'Format', 'single', 'Offset', 336);

dat = swapbytes(mmp.Data);
len = length(dat);

P = ( abs( fft(dat) ) .^2 )/Fs/(len-1);
P = P(2:end/2);
F = (2:len/2)*Fs/(len-1);
filfact = 10;
P = double(P);
F = double(F);

len2 = floor(length(P)/filfact);
Pf = zeros(1,len2);
Ff = zeros(1,len2);
for i = 1:len2
    Pf(i) = mean(P( (1:filfact) + (i-1)*filfact ));
    Ff(i) = mean(F( (1:filfact) + (i-1)*filfact ));
end

% Ff = smooth(F, filfact);
% Pf = smooth(P, filfact);

loglog(Ff,Pf), hold on, text(Ff(1), Pf(1), f{ii})
end


end

