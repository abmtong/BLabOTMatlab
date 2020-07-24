function [out] = kdf_pdf(inx, iny, sd, inxs)
%calculates the kdf of a pdf of data by placing a gaussian at each pt with sd ysd
% essentially smoothes a pdf, probs equivalent to just gaussian-filter smoothing?

%if one input, assume x is 1:n
if nargin ==1
    iny = inx;
    inx = 1:length(iny);
end

%if you want to supersample kdf, pass the vector as ysdmult
if nargin < 4
    inxs = inx;
end
if nargin < 3
    sd = 1;
end


out = zeros(size(inxs));

len = length(inxs);
gauss = @(x,ys) exp( -(ys-x).^2 /2 /sd^2);

for i = 1:length(iny)
    lb = max(1, find(inx(i) - sd*5 < inxs, 1, 'first'));
    ub = min(len, find(inx(i) + sd*5 > inxs, 1, 'last'));
    out(lb:ub) = out(lb:ub) + gauss(inx(i), inxs(lb:ub)) * iny(i);
end

%normalize... this should be right?
out = out * (range(inx)/length(inx) * normpdf(0, 0, sd));



