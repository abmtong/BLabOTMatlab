function [out, outraw] = computePRNAdist(dat, r0)
%Dat is array of [pRNA 1, pRNA 2, etc.] from pdbread and sorted
%Calculates pairwise distances of each, returns biggest delta between
%distances of both structures
if nargin < 2
    r0 = 54; %Angstrom, FRET pair r0
end
% rr = r0; %Just rename for typing ease

len = length(dat);
hei = length(dat{1});
outraw = nan(hei,hei,len);
for i = 1:len
    %Calculate pairwise distances
    xyz = [[dat{i}.X]' [dat{i}.Y]' [dat{i}.Z]'];
    for j = 1:hei
        outraw(j,:,i) =  sqrt(sum( (xyz - repmat(xyz(j,:), hei, 1)).^2 , 2));
    end
end

% %Remove dupes (i,j and j,i)
% outrawtri = triu(outraw);

%Calculate r0 for each
out = 1./(1+(outraw/r0).^6);

dE = abs( max(out, [], 3) - min(out,[],3)) ;
% dE = out(:,:,5) - out(:,:,1);

dEco = max(prctile(dE(:), 90), .1);


figure, hold on
for i = 1:hei
    for j = 1:hei
        %Just do upper diag
        if i > j
            continue
        end
        %Skip some?
        if dE(i,j) < dEco
            continue
        end
        %Only do continuously increasing? or just 5 minus 1?
        tmp = squeeze(out(i,j,:));
        df = diff(tmp);
        if ~all(df > -.05)
            continue
        end
        
        tmp = tmp-tmp(1);
        
        plot( tmp );
        text( 5, tmp(5), sprintf('[%d, %d: %0.2f]', i,j, dE(i,j)))
    end
end


