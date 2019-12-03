function out = protocolfitsort(inhists, inprots)

%Given an assortment of histograms and protocols
%How can we compare the two to get "universal" stats on them?
len = length(inhists);

%Remember that fit = [ 1x3 1x3 1x3 fits, baseheight ] where each 1x3 is [mean sd amp] of a gaussian
%The gaussian is not standard (bc it's for a circular axis, and I didn't do wrapping), given by eqn:
inx = 0:359;
dth = 1;
function p = circgauss(mu, sig)
    p = normpdf(inx , 180+rem(mu, dth), sig);
    p = p/max(p);
    p = circshift(p, [0,180/dth+floor(mu/dth)]);
end
fitfcn = @(x0) circgauss(x0(1), x0(2))*x0(3) + circgauss(x0(4), x0(5))*x0(6) ...
    + circgauss(x0(7), x0(8))*x0(9) + x0(10);
%Above taken from @protocolfit

%Distance between peak in inhists and peak in inprots
peakdth = cell(1,len);
%Relative heights of corresponding peaks
peakhts = cell(1,len);
%Relative height of floors
flrhts = zeros(1,len);

normfits = 1;

%So, loop over and calculate
for i = 1:len
    fith = inhists{i};
    fitp = inprots{i};
    
    if normfits
        %Make area = 1 (per rotation)
        fith([3 6 9 10]) = fith([3 6 9 10]) / sum(fitfcn(fith)) ;
        fitp([3 6 9 10]) = fitp([3 6 9 10]) / sum(fitfcn(fitp)) ;
    end
    
    %Find the best pairing of peaks
    
    %First sort the three peaks by mean angle
    [~, si] = sort(fith([1 4 7]));
    si = repmat(si, [3 1]);
    si = (si(:)' -1) * 3 + [1 2 3 1 2 3 1 2 3];
    fith = fith([si 10]);
    [~, si] = sort(fitp([1 4 7]));
    si = repmat(si, [3 1]);
    si = (si(:)' -1) * 3 + [1 2 3 1 2 3 1 2 3];
    fitp = fitp([si 10]);
    
    %Calculate pairwise differences between peaks
    diffs = bsxfun(@minus, fith([1,4,7]), fitp([1,4,7])');
    diffs = diffs - round(diffs/360) * 360;
    diffs = abs(diffs);
    
    prms = [ 1 2 3; 2 3 1; 3 1 2];
    prmsum = zeros(1,3);
    
    for j = 1:3
        prmsum(j) = diffs(1,j) + diffs(2,j) + diffs(3,prms(3,j));
    end
    
    [~, mini] = min(prmsum);
    
    %Sort based on min_i
    bestperm = prms(:,mini)';
    
    %fitp needs to be rearranged
    si = repmat(bestperm, [3 1]);
    si = (si(:)' -1) * 3 + [1 2 3 1 2 3 1 2 3];
    fitp = fitp([si 10]);
    
    %And then gather the bits
    peakdth{i} = fitp([1 4 7]) - fith([1 4 7]);
    peakhts{i} = fitp([3 6 9])./fith([3 6 9]);
    flrhts(i) = fitp(10) / fith(10);
end

out.pdth = peakdth;
out.pht = peakhts;
out.flh = flrhts;

end
