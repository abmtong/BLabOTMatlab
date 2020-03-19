function out = splitffb(inx, maxlen)
%Splits a force feedback trace into parts, since they can be very long
% A loF semi-passive trace (DNA, D2O) is 1.5-2k pts

if nargin < 2
    maxlen = 2e3;
end

if iscell(inx)
    out = cellfun(@(x)splitffb(x, maxlen), inx, 'Un', 0);
    out = [out{:}];
    return
end

%Define places to chop trace ('edges')
len = length(inx);
ns = ceil(len/maxlen);
edges = round(linspace(1,len,ns+1));

out = cell(1,ns);
for i = 1:ns
    out{i} = inx(edges(i):edges(i+1)-1);
end