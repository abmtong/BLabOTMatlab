function [out, y] = kdf(indata, dy, ysd)
%calculates the kdf of a set of data by placing a gaussian at each pt with sd ysd

if nargin < 3
    ysd = 1;
end
if nargin < 2
    dy = 0.1;
end

%Placing a gaussian == applying a gaussian filter on the binned data
[out, y] = cdf(indata, dy);
out = [0 diff(out)];

gaufh = @(x)sum(x.*(normpdf((1:length(x))*dy,dy*(length(x)/2+.5),ysd)));

out = windowFilter(gaufh, out, ceil(5*ysd/dy), 1);


% %calc gauss for pt +-5sd. Set up y-binning first
% wid = ceil(ysd/dy*5); %+-5sd, time difference between 3/4/5 sd is negligible so opt for 5, max difference from using full-length y is 1e-2/1e-3/1e-5 respectively
% minyi = floor( min(indata)/dy );
% maxyi = ceil ( max(indata)/dy );
% y = (minyi-wid:maxyi+wid)*dy;
% 
% %calc gauss for only pt within wid (+-5sd)
% leny = length(y);
% out = zeros(1, leny);
% gauss = @(x,ys) exp( -(ys-x).^2 /2 /ysd^2);
% indi = wid+round(indata/dy)-minyi+1;
% lb = indi-wid;
% ub = indi+wid;
% for i = 1:length(indata)
%     out(lb(i):ub(i)) = out(lb(i):ub(i)) + gauss(indata(i), y(lb(i):ub(i)));
% end



%worse implementations

% minyi = floor( min(indata)/dy );
% maxyi = ceil( max(indata)/dy);
% y = (minyi:maxyi)*dy;
% %calc gauss for only pt+-5sd
% leny = length(y);
% out = zeros(1, leny);
% gauss = @(x,ys) exp( -(ys-x).^2 /2 /ysd^2);
% wid = ceil(ysd/dy*5); %+-5sd, time difference between 3/4/5 sd is negligible so opt for 5, max difference from using full-length y is 1e-2/1e-3/1e-5 respectively
% indi = round(indata/dy)-minyi+1;
% for i = 1:length(indata)
%     %Make sure +-wid is in matrix. Alternatively, could pad out instead
%     lb = max(1, indi(i)-wid);
%     ub = min(leny, indi(i)+wid);
%     out(lb:ub) = out(lb:ub) + gauss(indata(i), y(lb:ub));
% end


%used to switch from large array and pt-by-pt, pt-by-pt harvested into current ver (pt +- 5SD)
%can be slow / impossible if y and indata are very large (this allocates a length(y) x length(indata) matrix)
% but is generally the fastest run in Matlab, so check the size of the matrix
% if length(indata) * length(y) * 8 < 1e6 %if array is <1GB, use this faster one
%     out = sum(exp(-bsxfun(@minus, y(:), indata(:)').^2/2/ysd^2),2);
% else %use low memory version
%     out = zeros(1, length(y));
%     gauss = @(x) exp( -(y-x).^2 /2 /ysd^2);
%     for i = indata
%         out = out + gauss(i);
%     end
% end
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