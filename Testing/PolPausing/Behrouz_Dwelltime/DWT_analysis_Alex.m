function [dtxpdf, bincen, dtxsds, bins, dtx] = DWT_analysis_Alex(inCon, fsamp, dsamp, stsz, binopts, nboot, bincorrect)

if nargin < 2 || isempty(fsamp)
    fsamp = 2e5/3/50; %flzr data with 50 averaging factor for 1333Hz final rate
end
if nargin < 3 || isempty(dsamp)
    dsamp = 13; %to get final rate of 100Hz ish
end
if nargin < 4 || isempty(stsz)
    stsz = 1; %1nt
end
if nargin < 5 || isempty(binopts)
    %bin decade start/stop/pts per decade. 
    binopts = [-3 3 10]; %the author used [-3 2 7]
end
if nargin < 6 || isempty(nboot)
    nboot = 100;
end
if nargin < 7 || isempty(bincorrect)
    bincorrect = 0;
end

%@sgolayfilt requires double
if ~isa(inCon, 'double')
    inCon = double(inCon);
end
%Mean filter
inConF = sgolayfilt(inCon,0,dsamp);
%Find first crossings over a grid of spacing Nw - to estimate step times
tx = firstxing(inConF, stsz);
%Calculate dwell times from crossing sites
dtx = diff(tx)/fsamp;
%remove 0 times (i.e. it crossed two steps in one point
dtx(dtx==0) = []; %make these 1 instead? bc else we're missing steps
%calculate bins - bin in logspace using @logspace
% %estimate starting and ending bin log value ('decade') - logspace uses log base 10
% stdec = floor(log10(min(dtx))*binopts);
% endec = ceil(log10(max(dtx))*binopts);
%calculate bin edges
bins = logspace(binopts(1), binopts(2), (binopts(2)-binopts(1))*binopts(3)+1);
%for some reason, they correct the bin edges, so they are multiples of dt [ok w/e]
%bin edges might not be bigger than dt?
if bincorrect
    bins = ceil(bins*fsamp)/fsamp;
end
%define binning function
binfcn = @(y) diff(arrayfun(@(x)sum(y < x), bins));
%calculate cdf: dtxcdf(i) = number of data pts that's less than bins(i)
%calculate pdf
dtxpdf = binfcn(dtx);
%do bootstrapping to estimate errors
dtxsds = std(bootstrp(nboot, binfcn, dtx), 0, 1);
%calculate bin centers for plotting: geometric mean of adjacent values
bincen = sqrt(bins(1:end-1) .* bins(2:end));
% %calculate bin widths for normalizing dtxpdf?
% binwid = diff(bins);
% normfact = sum(dtxpdf);
% dtxpdf = dtxpdf ./ binwid / normfact;
% dtxsds = dtxsds ./ binwid / normfact;
% % sum(dtxpdf .* binwid) %should be 1
%plot sd with errorbars
figure, loglog(bincen, dtxpdf), hold on
errorbar(bincen, dtxpdf, dtxsds)

% 
% Tc_array2 = tx * t0;
% %compare Tx and Tc_array)
% 
% DWT_array = diff(Tc_array);
% 
% [bar_pos, bins]=make_bins(Ti,bins_per_decade,number_of_decades,dt,correction);
% 
% [DWT_hist] = DwellTimeHist_v3(DWT_array, dt, bins);
% 
% bootstat = bootstrp(nboot,@ (DWT_array) DwellTimeHist_v3(DWT_array, dt, bins),DWT_array);
% 
% Err=zeros([1, length(DWT_hist)]);
% 
% for i=1:length(DWT_hist)
%     Err(:,i)=std(bootstat(:,i));
% end

