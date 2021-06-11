function [out, mes] = kvNP(dat, seq)

if ischar(seq)
    seq = seq2st(seq);
end

%Cut each in data to n steps ( n = length(seq) )

len = length(dat);
nst = length(seq);

trs = cell(1,len);
ins = cell(1,len);
mes = cell(1,len);
for i = 1:len
    [ins{i}, mes{i}, trs{i}] = AFindStepsV5(dat{i}, 0, nst-1, 0);
end

%Save table of mes
mes = cellfun(@(x) x', mes, 'Un', 0);
mes = [mes{:}]';

bk = 0;
fw = 0;
ksd = 2;


%Get total kdf, to be used to normalize later
[ky, kx] = kdf([dat{:}], 0.1, ksd);

pkhei = cell(1,nst);
pkhei2 = cell(1,nst);
pkloc = cell(1,nst);
pki = cell(1,nst);
out = zeros(1,nst);
out2 = zeros(1,nst);
for i = 1:nst
    stin = max(1, i-bk);
    enin = min(nst, i+fw);
    mecrp = mes(:,stin:enin);
    tmp = mecrp(~isnan(mecrp));
    [yy, xx] = kdf(tmp, .1, ksd);
    [pkhei{i}, pkloc{i}] = findpeaks(yy, xx);
    pkhei2{i} = pkhei{i} ./ interp1(kx, ky, pkloc{i});
    pki{i} = ones(1,length(pkhei{i}))*i;
    [~, maxi] = max(pkhei{i});
    out(i) = pkloc{i}(maxi);
    [~, maxi2] = max(pkhei2{i});
    out2(i) = pkloc{i}(maxi2);
end

%Straight up
figure, scatter([pki{:}], [pkloc{:}], [pkhei{:}]/min([pkhei{:}])*4)
hold on, plot(1:nst, out);

%Weight better low-residence times
figure, scatter([pki{:}], [pkloc{:}], [pkhei2{:}]/min([pkhei2{:}])*4)
hold on, plot(1:nst, out2);

% %Find best power such that states replicate kdf
% plen = 20;
% psrch = linspace(0,1,plen);
% scrs = zeros(1,plen);
% outps = cell(1, plen);
% for j = 1:plen
%     %Divide pkhei thru by 
%     tmp = zeros(1,nst);
%     for i = 1:nst
%         [~, maxi] = max(pkhei{i} ./ interp1(kx, ky, pkloc{i}).^psrch(j));
%         tmp(i) = pkloc{i}(maxi);
%     end
%     outps{j} = tmp;
%     %Find the kdf with these steps
%     [py, px] = kdf(tmp, .1, ksd);
%     %And Cauchy-schwarz them
%     [~, ii] = min(abs(kx - px(1)));
%     scrs(j) = sum(py .* ky( ii-1 + (1:length(py)) )) / ( sum(py ) ) /  ( sum(ky) );
% end
% 
% [~, mi] = max(scrs);
% 
% pkhei3 = cell(1,nst);
% for i = 1:nst
%     pkhei3{i} = pkhei{i} ./ interp1(kx, ky, pkloc{i}).^psrch(mi);
% end
% 
% figure, scatter([pki{:}], [pkloc{:}], [pkhei3{:}]/min([pkhei3{:}])*4)
% hold on, plot(1:nst, outps{mi});
% 
% [py, px] = kdf(outps{mi}, .1, ksd);
% figure, plot(kx, ky/max(ky)), hold on, plot(px, py/max(py));



%Method 1, eh
%{
%Try this: Go through step by line, find a peak, remove those that are contained in peak
bk=2; %How many columns to keep behind
fw = 1; %How many columns to look fwd to rm
sdthr = 1; %Group within this many sd
dbg = 1;
if dbg
    figure
    ax = gca;
    pxx = [];
    pyy = [];
end
md = zeros(1,nst);
msd= zeros(1,nst);
msd = 2*ones(1,nst);
for i = 1:nst
    %Get the set of numbers
    stin = max(1, i-bk);
    mecrp = mes(:,stin:i);
    tmp = mecrp(~isnan(mecrp));
    %Get the median and sd
    md(i) = median(tmp);
    msd(i) = mad(tmp,1) * sqrt(2) / erfinv(.5); %convert mad to SD
    
    if dbg
        xx = 20:95;
        cla(ax);
%         plot(ax, xx, normpdf(xx, md(i), msd(i))), hold on, plot(ax, tmp, normpdf(tmp, md(i), msd(i)), 'o')
%         plot(ax, md(i) + msd(i) * sdthr * [-1 -1 1 1], [.2 0 0 .2])
        [xx, yy] = kdf(tmp, .1, 2); plot(yy,xx), hold on, plot(tmp, interp1(yy, xx, tmp), 'o')
        plot(pyy, pxx, 'Color', [.7 .7 .7])
        pyy = yy; pxx = xx;
        xlim([20 95])
        drawnow
        [md(i), ~] = ginput(1);
    end
    bdy = md(i) + msd(i) * sdthr * [-1 1];
    %Select within some threshold (2.5SD) : NaN out these others
    enin = min(nst, i+fw);
    mecrp2 = mes(:, stin:enin);
    ki = mecrp2 < bdy(2) & mecrp2 > bdy(1);
    mes([ false(len, stin-1) ki false(len, enin-i)]) = nan;
end
out = {md msd};
%}