function out = EzCyc_batch_plotFACTtpm(datall)

%Get a singular value for 'asymmetry effect' and compare to TPM of FACT

len = length(datall);
outtpm = nan(1, len);
outfac = nan(1, len);

for i = 1:len
    tmp = datall(i);
    if isempty(tmp.facttpm)
        continue
    end
    outfac(i) = tmp.facttpm;
    %Asymmetry effect at high TPM
%     outtpm(i) = tmp.rna{3}(end,2) - tmp.rna{1}(end,2);
    %Dyad flexibility
%     outtpm(i) = tmp.rna{2}(end,2);
    %Asymmetry effect over all genes
    ki = find( abs(tmp.flex{2}(:,1)) == 48.5 );
    pos = tmp.flex{1}(ki,2);
    neg = tmp.flex{3}(ki,2);
    pos = pos(1)-pos(2);
    neg = neg(2)-neg(1);
    outtpm(i) = (pos+neg)/2;
end


figure, plot(outfac, outtpm, 'o')