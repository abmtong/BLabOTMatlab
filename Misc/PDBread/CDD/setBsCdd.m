function pdbstartres = setBsCdd(infp, bfacs, chainID, pdbstartres)
%Bfacs as a nx2 array of [residue number, b-factor]
%ChainID is a chain ID (string, so 'A')

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.pdb');
    infp = fullfile(p,f);
end

if nargin < 3
    chainID = 'A';
end

%Load pdb
a = pdbread(infp);

%Remove atoms outside of chainID
a.Model.Atom = a.Model.Atom( [a.Model.Atom.chainID] == chainID );

%Get data
res = [a.Model.Atom.resSeq];
natom = length(a.Model.Atom);

%Set minimum b to deal with NaN bfactor
minb = min(bfacs(:,2)); %Minimum to overwrite the NaNs = not aligned
%Use rangecolor in Chimera to set color range in plotting (?)

if nargin < 4
    %Get PDB start residue -- if it's nonzero, then we need to shift, as CDD doesn't account for this
%     pdbstartres = min(res);
    pdbstartres = 1;
    %Maybe we can do better? if we have the raw data, just do a sequence alignment
end

%EH Just warn
if min(res) ~= 1
    warning('PDB doesnt start at residue 1 (starts at %d), maybe need to shift', min(res))
end


%Shift bfacs
bfacs(:,1) = bfacs(:,1) -1 + pdbstartres;

for i = natom:-1:1
    rn = res(i);
    %Check if this residue number is in bfacs(i)
    ind = find(rn == bfacs(:,1));
    
    if ~isempty(ind) && ~isnan(bfacs(ind,2)) %Skip NaN = unaligned
        %If so, set to the calc'd value
        a.Model.Atom(i).tempFactor = bfacs(ind,2); %min(bfacs(ind,2), maxb);
    else
        %Else, set to a minimum value
        a.Model.Atom(i).tempFactor = minb;
    end
end

%Save, add '_setB' to filename
[tp, tf, te] = fileparts(infp);
pdbwrite( fullfile(tp, [tf '_setB' te]), a );