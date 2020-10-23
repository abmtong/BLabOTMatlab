function out = checkAlign(inys, muref)
%The range of the traces on RNA is different than on DNA
%Let's quantify by how much


binsz = 0.5;
xs = 0:binsz:100; %Set bins

%Get the histogram of the trace, and compare it to the histogram of muref

%Generate muref with @kdf because there's fewer points
refhst = smooth(histcounts(muref, xs), 10);

len = length(inys);
out = zeros(1,len);
for i = 1:len
    %Calculate histogram
    his = histcounts((inys{i}), xs);
    %Compute cross-correlation
    [xc, df] = xcorr(his, refhst);
    xc = xc ./ [1:length(xs)-1, length(xs)-2:-1:1];
    %Find the largest overlap
    [~, ii] = max(xc);
    %Convert to offset
    out(i) = df(ii)*binsz;
end
