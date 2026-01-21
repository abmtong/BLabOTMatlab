function out = getCoords(inatoms, chains, atomname)
%Gets atom atomname from chains chains from PDB inatoms
% inatoms is from pdbread, .Model.Atom

len = length(inatoms);
rawout = cell(1,len);
for i = 1:len
    tmp = inatoms(i);
    %Check if this is the right chain
    if any( tmp.chainID == chains )
        %And the right atom
        if strcmp(atomname, tmp.AtomName)
            %And assign
            rawout{i} = inatoms(i);
            
        end
    end
end

out = [rawout{:}];
