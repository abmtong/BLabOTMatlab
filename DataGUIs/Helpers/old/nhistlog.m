function [outx, outy] = nhistlog(iny, npts)
%Bins to a 'log-friendly' histogram with unequal bin sizes
%Essentially smooths the ccdf and then takes its derivative

%EH might be better to do @(x) plot( sort(x), 1- (1:length(x))/length(x) )

%Should the passed term be pts to avg or pts to 
if nargin < 1
    %Let's say 10pts or 100pts, whichever is greater
    npts = max(10, length(iny)/100);
end

iny = sort(iny);

sm = windowFilter(@mean, iny, [], npts);
len = length(sm);

outx = (sm(1:end-1)+sm(2:end))/2;
outy = 1./diff(sm)/len;

