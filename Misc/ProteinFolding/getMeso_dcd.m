function [out, phipsi, outraw] = getMeso_dcd(pdb, dcd)

%Input: PDB data from @pdbread and dcd data from @readdcd_all

nf = length(dcd); %Number of frames
na = length(pdb.Model.Atom); %Number of atoms

out = cell(1, nf); %Store @rama output for each frame
phipsi = cell(1,nf);
if nargout > 1
    outraw = cell(1,nf); %Store raw coords if asked
end
for i = 1:nf
    %Get atom coords
    xyz = dcd{i};
    
    %Edit the pdb to be this state
    for j = 1:na
        pdb.Model.Atom(j).X = xyz(j,1);
        pdb.Model.Atom(j).Y = xyz(j,2);
        pdb.Model.Atom(j).Z = xyz(j,3);
    end
    
    %And get+classify dihedral angle
    [out{i} phipsi{i}] = getMeso(pdb);
    if nargout > 1
        outraw{i} = pdb;
    end
end