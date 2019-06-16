function kdfsfind(varargin)

[~, lc] = findpeaks(kdf(varargin{:}));

ssz = diff(lc);

if nargin<2
    dy = 0.1;
else
    dy = varargin{2};
end

figure, hist(ssz*dy, 100);