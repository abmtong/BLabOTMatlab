function ezCdd(incell, pdbstartres)
%Run importCDD > cddColorBits > setBs in order

if nargin < 2
    pdbstartres = 1;
end

b = importCDD(incell);
c = cddColorBits(b, pdbstartres);

setBs(c);