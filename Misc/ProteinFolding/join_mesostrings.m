function [outmesos, outps, outcl] = join_mesostrings(mesos, ps)
%Joins mesostrings if they are off by one
%Input: Mesostrings (cell), percentages

len = length(mesos);
mlen = length(mesos{1});

mgroups = 1:len; %mesos{i} belongs to group mgroups(i)
outmesos = mesos;
for i = 1:len-1
    %If this mesostring has already been absorbed, ignore
    if mgroups(i) ~= i
        continue
    end
    
    %So let's check if there's similar mesostrings to this one 
    ms = mesos{i};
    nsame = cellfun(@(x) sum( x == ms ), mesos);
    
    %Only check for strings after this one
    nsame(1:i) = 0;
    
    %Find exact equals and one-differents
    isame = find(nsame == mlen);
    imone = find(nsame == mlen-1);
    if any(nsame == mlen)
        %Should be unique, so just set
        mgroups( isame ) = i; %#ok<FNDSB>
    end
    
    if any(imone)
        %For the first one, find the difference
        inddiff = find( mesos{imone(1)} ~= ms , 1, 'first' );
        outmesos{i}(inddiff) = '-'; %Make it a dash
        mgroups( imone(1) ) = i;
        
        
        for j = 2:length(imone)
            %Get the one different
            inddiff2 = find( mesos{imone(j)} ~= ms , 1, 'first' );
            if inddiff2 == inddiff
                %Mark to combine
                mgroups( imone(j) ) = i;
            end
            
        end
        
    end
    
    
end

%And combine by mgroups
% mmax = max(mgroups);
[mu, ia, ic] = unique(mgroups);
mmax = length(mu);
outcl = cell(1, mmax);
outps = zeros(1, mmax);
outmesos = outmesos(ia);
for i = 1:mmax
    %Group together mesostrings
    ki = mgroups == i;
    outcl{i} = find(ki)-1;
    outps(i) = sum(ps(ki));
end