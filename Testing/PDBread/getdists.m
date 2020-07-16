function [out, atoms] = getdists(atoms, chainIDs, resA)
%Want to find the best difference in distance between residue A in chain(1,i) and all residues in chain(2,i)
% Using to find the best pRNA labelling position for FRET change
%Input atoms is {chn num elem xpos ypos zpos};
%ChainIDs should be [proximal ... distal]
%resA is residue number in gp16 (probably 4 for S4C)

if nargin < 3
    resA = 4;
end

%Make every element in atoms a row vector
atoms = cellfun(@(x) x(:)', atoms, 'Un', 0);

%Measure from an atom, let's say c-alpha on residues, C1' on RNA
atms = {'CA' 'C1'''};

%Filter out atoms that don't match the modifier
ki = cellfun(@(x) any(strcmp(atms, x)), atoms{3});

% ki = strcmp(atms{1}, atoms{3}{1}) | strcmp(atms{2}, atoms{3});
atoms = cellfun(@(x) x(ki), atoms, 'Un', 0);

%For each chain pair...
len = size(chainIDs, 2);
dists = cell(1,len);
reses = cell(1,len);
for i = 1:len
    %Get the xyz of the residue
    resn = find( atoms{1} == chainIDs(1,i) & atoms{2} == resA );
    %Make sure there's only one
    if length(resn) ~= 1
        warning('Found multiple atoms for residue %s%d, taking first', chainIDs(1,i), resA)
    end
    %Compare to XYZ of every residue in chainIDs(2,i)
    ki = atoms{1} == chainIDs(2,i);
    atch = cellfun(@(x) x(ki), atoms, 'Un', 0);
    norm = @(x,y,z) sqrt((x-atoms{4}(resn))^2+(y-atoms{5}(resn))^2+(z-atoms{6}(resn))^2);
    dists{i} = arrayfun(norm, atch{4}, atch{5}, atch{6});
    reses{i} = atch{2};
end

%Arrange dists into an array, sorted by reses
%Might not necessarily be sorted the same, but assume they cover the same residues?
%{Res dist1 dist2 dist3 dist4 dist5}

%Sort by res number
for i = 1:length(reses)
    [reses{i}, si] = sort(reses{i});
    dists{i} = dists{i}(si);
end

%Hopefully this will align them.

%Start with pRNA 1...
out = [reses{1}(:) dists{1}(:)];
for i = 2:len
    if all(reses{1} == reses{i})
        out = [out dists{i}(:)]; %#ok<AGROW>
    else
        %We need to align dists{i} with dists{1}
        nn = length(dists{i});
        dst = zeros(1,nn);
        for j = 1:nn
            ind = find(reses{1}(j) == reses{i},1,'first');
            if isempty(ind)
                dst(i) = dists{i}(ind);
            else
                dst(i) = NaN;
            end
        end
        out = [out dst(:)]; %#ok<AGROW>
    end
end

%Sort by largest distance difference
dx = out(:,end)-out(:,2);
[~, si] = sort(dx, 'descend');
out = out(si,:);