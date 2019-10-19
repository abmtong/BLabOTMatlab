function out = protocolfitsort2(inprots, inhists)

%Given an assortment of histograms and protocols
%How can we compare the two to get "universal" stats on them?
len = length(inhists);

%Remember that fit = [ 1x3 1x3 1x3 fits, baseheight ] where each 1x3 is [mean sd amp] of a gaussian
%The gaussian is not standard (bc it's for a circular axis, and I didn't do wrapping), given by eqn:
inx = 0:359;

fitfcn = @(x0,x) x0(1) * cos(2*pi*3*x/360 - x0(2)) + x0(3);

%Distance between peak in inhists and peak in inprots
peakdth = zeros(1,len);
%Relative heights of peaks
peakhts = zeros(1,len);
%Relative height of floors
flrhts = zeros(1,len);

normfits = 1;

nfith = cell(1,len);
nfitp = cell(1,len);

%So, loop over and calculate
for i = 1:len
    fith = inhists{i};
    fitp = inprots{i};
    
    %If amp negative, negate amp and change angle offset by 180
    if fitp(1) < 0
        fitp(1) = -fitp(1);
        fitp(2) = fitp(2) + 180;
    end
    
    if fith(1) < 0
        fith(1) = -fith(1);
        fith(2) = fith(2) + 180;
    end
    
    if normfits %Scale the y-axis to have integral 1.
        fitp([1 3]) = fitp([1 3]) / sum(fitfcn(fitp, inx));
        fith([1 3]) = fith([1 3]) / sum(fitfcn(fith, inx));
    end
    
    
    peakdth(i) = fitp(2) - fith(2);
    peakdth(i) = peakdth(i) - round(peakdth(i)/120)*120;
    
    peakhts(i) = fitp(1) / fith(1);
    flrhts(i) = fitp(3) / fith(3);
    
    nfith{i} = fitp;
    nfitp{i} = fith;
end

out.pdth = peakdth;
out.pht = peakhts;
out.flh = flrhts;

out.fith = inhists;
out.fitp = inprots;
out.nfith = nfith;
out.nfitp = nfitp;

% figure, scatter([ ones(1,len) 2*ones(1,len) 3*ones(1,len) ], [peakdth peakhts flrhts], 100*ones(1,len*3), [(1:len) (1:len) (1:len)] )

end
