function [out, outraw] = findDNPs(o, or)
%Find double nucleotide polymorphisms (2 snps next to each other)
%input: out and outraw from @alignSeqs

%Find guys with 2 SNPs, 0indels

if iscell(o)
    [out, outraw] = cellfun(@findDNPs, o, or, 'Un', 0);
    return
end

ki = find( o(1,:) == 2 & o(2,:) == 0 & o(3,:) == 0) ;

len = length(ki);
kiki = false(1, len);
locs = zeros(1, len);
snpdist = zeros(1,len);
for i = 1:len
    %Get this alignment txt
    tmp = or{ki(i)};
    %Search for spaces
    tmp2 = regexp(tmp(2,:), ' ');
    %tmp2 should be of length 2
    
    %Check for distance between spaces
    snpdist(i) = diff(tmp2);
    %If double space, store
    if diff(tmp2) == 1;
        kiki(i) = true;
        locs(i) = tmp2(1);
    end
end
out = locs(kiki);
outraw.aln = or(ki(kiki));
outraw.dst = snpdist;


figure Name SNPdist, plot(sort(outraw.dst))
ylabel('SNP distance')
xlabel('Transcript no.')



% %Find guys with adjacent SNPs? Ignore ones with both?
% 
% maxerr = 4;
% 
% nerr = sum(o,1);
% ki = nerr <= maxerr;
% 
% len = length(ki);
% kiki = false(1,len);
% locs = zeros(1,len);
% for i = 1:len
%     %Look for SNP
%     
%     
% end