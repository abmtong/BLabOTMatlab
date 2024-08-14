function [out, bb] = ramaV2(inp)
%Calculates ramachandran angles for a pdb (from @pdbread)

%Get atoms
at = inp.Model(1).Atom(:);

resnum = [at.resSeq]; %Residue numbers
atnam = {at.AtomName}; %Atom names

%Let's assume residue numberings start from 1 and don't skip. Otherwise could handle this with @unique
len = max( [at.resSeq] );


bbnam = {'N' 'CA' 'C'}; %Backbone atom names
bb = repmat( {nan(1,3)}, 3, len);
for i = 1:len
    %Get C, Ca, and N for each residue. Write to handle the ACE and NHE cappers for MD
    
    %Get backbone atoms
    for j = 1:3
        tmp = at( resnum == i & strcmp(atnam, bbnam{j}) );
        if ~isempty(tmp)
            bb{j,i} = [tmp.X tmp.Y tmp.Z];
        end
    end
end

%Calculate the dihedral angles for each set of 4 points
out = nan(3, len-1); %Will be [psi; omega; phi]

%Precalc u's, vectors between points
uu = cellfun(@(x,y) x - y, bb(2:end), bb(1:end-1), 'Un', 0);
isn = cellfun(@(x) any(isnan(x)), uu);
for i = 1:len*3-3
    %Calculation from Wikipedia/Dihedral_angle
    
    %Check that they aren't NaN
    if any(isn(i:i+2))
        continue
    end
    
    %Calculate angle with atan2
%     out(i) = atan2( dot( uu{i+1} , cross( cross(uu{i},uu{i+1}), cross(uu{i+1}, uu{i+2}) ) ),...
%                 sqrt(sum(uu{i+1}.^2)) * dot( cross(uu{i},uu{i+1}), cross(uu{i+1}, uu{i+2}) ) );
    out(i) = atan2( sqrt(sum(uu{i+1}.^2)) * dot( uu{i} , cross(uu{i+1}, uu{i+2}) ),...
                dot( cross(uu{i},uu{i+1}), cross(uu{i+1}, uu{i+2}) ) );
    
	%Matches @ramachandran, but seems like phi (i) actually is phi(i-1)
end

%This is in radians, convert to degrees
out = out / pi * 180;








