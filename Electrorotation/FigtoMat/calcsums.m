function out = calcsums(inmat)
%Inmat should be a nx26 matrix, gotten as rows from the csv output of getnrgfromfig
%columns: [name, 6xmeans, hz, space ]x3, without trailing space (= 26)

%Do sanity check (make sure energies for hy > nrg syn)
% Turn off if e.g. doing brownian
sanchk =0;

%Hzs to separate
hzs = [1 5 10];

rmn = zeros(length(hzs), 6);
rsd = zeros(length(hzs), 6);
rnn = zeros(length(hzs), 6);
n = zeros(length(hzs),1);

%And for pooled (weighted by N) ones
rmnp = zeros(length(hzs), 6);
rsdp = zeros(length(hzs), 6);
rnnp = zeros(length(hzs), 6);

%process by row
len = size(inmat,1);
exitflag = zeros(len,1);

for i = 1:len
    tmp = inmat(i,:);
    ind = find( hzs == tmp(8),1);
    %Check if rotation rate is ok
    if isempty(ind)
        exitflag(i) = 1;
        continue
    end
    
    %Ignore if any data isnan
    if any(isnan(tmp(2:7))) || any(isnan(tmp((2:7) + 9))) || any(isnan(tmp((2:7) + 18)))
        exitflag(i) = 2;
        continue
    end
        
    %Sanity check
    %Column order is [nS nH oS oH oSo oHo]
    if sanchk
        if any(tmp([2 4 6]) > tmp([3 5 7]))
            exitflag(i) = 3;
            continue
        end
    end
    
    %If passes all checks, add
    rmn(ind, :) = rmn(ind, :) + tmp(2:7);
    rsd(ind, :) = rsd(ind, :) + tmp( (2:7) +9);
    rnn(ind, :) = rnn(ind, :) + tmp( (2:7) +18);
    
    rmnp(ind, :) = rmnp(ind, :) + tmp(2:7) .* (tmp( (2:7) +18) -1);
    rsdp(ind, :) = rsdp(ind, :) + tmp((2:7)+9).* (tmp( (2:7) +18) -1);
    rnnp(ind, :) = rnnp(ind, :) + tmp( (2:7) +18) -1;
    n(ind) = n(ind) + 1;
end

%Calculate regulars = sum / n
rmn = bsxfun(@rdivide, rmn, n);
rsd = bsxfun(@rdivide, rsd, n);
rsm = bsxfun(@rdivide, rsd, sqrt(rnn));

%Calculate mean weighted by n samples
rmnp = bsxfun(@rdivide, rmnp, rnnp);
rsdp = bsxfun(@rdivide, rsdp, rnnp);
rsmp = bsxfun(@rdivide, rsdp, sqrt(bsxfun(@plus, rnnp, n)));

%output them

out.reg = [rmn rsd rsm rnn];
out.pool = [rmnp rsdp rsmp bsxfun(@plus, rnnp, n)];
out.exfl = exitflag; %0 if ok, 1-3 if excluded for some reason

