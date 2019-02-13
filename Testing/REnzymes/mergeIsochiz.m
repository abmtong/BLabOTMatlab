function out = mergeIsochiz(renz)

%Extract unique sites
[~, sinda, sindc] = unique(renz(:,2));
%Merge names of isochizomers
out = renz(sinda,:);

for i = 1:length(sinda)
    nams = sprintf('%s,', renz{sindc == i,1});
    out{i,1} = nams(1:end-1);
end

%Realphabetize by leading REnzyme
[~, ind] = sort(out(:,1));
out = out(ind,:);