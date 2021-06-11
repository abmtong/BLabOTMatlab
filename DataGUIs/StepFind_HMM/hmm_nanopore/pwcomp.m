function out = pwcomp(dat)

%Pairwise compare each dat: check difference by overlap

len = length(dat);

ddsmp = cell(1,len);
npts = 1e4;

for i = 1:len
    %Filter dat, resample to 10k pts
    df = smooth(dat{i}, 10);
    hei = length(df);
    ddsmp{i} = interp1(1:hei, df, linspace(1, hei, npts));
end

%Pairwise compare these
out = zeros(len);

for i = 1:len
    for j = 1:len
        out(i,j) = sum( (ddsmp{i} - ddsmp{j}).^2 );
    end
end
