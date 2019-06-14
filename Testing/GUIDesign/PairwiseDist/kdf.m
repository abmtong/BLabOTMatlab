function [out, y] = kdf(indata, dy, ysd)
%calculates the kdf of a set of data by placing a gaussian at each pt with sd ysd

if nargin < 3
    ysd = 1;
end
if nargin < 2
    dy = 0.1;
end

miny = floor( min(indata)/dy ) * dy;
maxy = ceil( max(indata)/dy) * dy;
y = miny:dy:maxy;
%can be slow / impossible if y and indata are very large (this allocates a length(y) x length(indata) matrix)
% but is generally the fastest run in Matlab, so check the size of the matrix
if length(indata) * length(y) * 8 < 1e6 %if array is <1GB, use this faster one
    out = sum(exp(-bsxfun(@minus, y(:), indata(:)').^2/2/ysd^2),2);
else %use low memory version
    out = zeros(1, length(y));
    gauss = @(x) exp( -(y-x).^2 /2 /ysd^2);
    for i = indata
        out = out + gauss(i);
    end
end

%worse implementations
%second best: loop

% tic
% toc
%third best: sum bsx gauss
% tic
% gbsx = @(x,y) exp(-(x-y).^2 /2 /ysd^2);
% out = sum(bsxfun(gbsx, y(:), indata(:)'),2);
% toc
% fourth: sum reshape arrayfun
% tic
% out = arrayfun(gauss, indata, 'uni', 0);
% out = sum(reshape([out{:}], length(y), []),2);
% toc

