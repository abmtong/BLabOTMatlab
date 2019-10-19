function [pkloc, ssz] = kdfsfind(varargin)
%takes same input as @kdf

%If first input is cell, batch process
if iscell(varargin{1})
    [pkloc, ssz] = cellfun(@(x) kdfsfind(x, varargin{2:end}),varargin{1},'Un',0);
    ssz = [ssz{:}];
    return
end




[histy, histxx] = kdf(varargin{:});

pkhei = findpeaks(double(histy), double(histxx));
trhei = findpeaks(-double(histy), double(histxx));
%Set MinPeakProminence to be half the median peak difference
medpk = median(pkhei);
medtr = -median(trhei);
mpp = (medpk - medtr) / 2;
[~, pkloc] = findpeaks(double(histy), double(histxx), 'MinPeakProminence', mpp);

ssz = diff(pkloc);

% if nargin<2
%     dy = 0.1;
% else
%     dy = 1;
% end
% 
% figure, hist(ssz*dy, 100);

%now try to find dwells
%...could HMM this I guess, with lc as steps
% Or could KV this with known nsteps? accept if they overlap? Ghe did this, I think