function [out, outraw] = clusterBBs(inpp)
%Cluster structures based on backbone dihedral angle
%Input: Cell of backbone dihedrals from @ramachandran

%Hmm may need to rewrite algorithm with cyclic distance...
% Or can we rewrite as like e(i theta) ? This will compute the right 'distance' ? hmm not quite... shift phi/psi so the zero is somewhere less populated?

%Also accept struct
if isstruct(inpp) && isscalar(inpp) && isfield(inpp, 'bb')
    inpp = {inst.phipsi};
end

%Grab phipsi from full @ramachandran output
phi = cellfun(@(x)  x(2:end-1, 1), inpp, 'Un', 0);
psi = cellfun(@(x)  x(2:end-1, 2), inpp, 'Un', 0);

%Concatenate

%I guess we'll cluster in this Naa*2 space

%Can we recreate a pdb with these phipsi? Or find the closest structure of input?

