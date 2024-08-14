function setBs(bfacs)

%Bfacs as a nx2 array of [residue number, b-factor]
%indat is output of pdb2mat

a = pdb2mat;
%pdb2mat has multiselect, just take first
if length(a)>1
    a = a(1);
    warning('Don''t use Multiselect, just taking first file')
end

res = a.resNum;
natom = length(res);

%Cull b's so that they're 'okay'
minb = min(bfacs(:,2)); %Minimum to overwrite the NaNs = not aligned
% minb = 0;
maxb = prctile(bfacs(:,2), 75); %Reduce the maximum 

for i = 1:natom
    rn = res(i);
    %Check if this residue number is in bfacs(i)
    ind = find(rn == bfacs(:,1));
    
    if ~isempty(ind) && ~isnan(bfacs(ind,2)) %Skip NaN = unaligned
        %If so, set to the calc'd value
        a.betaFactor(i) = min(bfacs(ind,2), maxb);
    else
        %Else, set to a minimum value
        a.betaFactor(i) = minb;
    end
end

%Save, add '_setB' to filename
[tp, tf, te] = fileparts(a.outfile);
a.outfile = fullfile(tp, [tf '_setB' te]);
mat2pdb(a);