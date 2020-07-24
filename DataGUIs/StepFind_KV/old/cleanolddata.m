function outind = cleanolddata(incell)

lenfil = cellfun(@length, incell)>50;
nanfil = cellfun(@(x)~any(isnan(x)),incell);
outind = lenfil & nanfil;
