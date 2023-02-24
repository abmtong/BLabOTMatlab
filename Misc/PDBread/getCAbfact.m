function out = getCAbfact(inpdb)

if nargin < 1
    [f, p] = uigetfile('*.pdb', 'Mu', 'on');
    if ~iscell(f)
        f = {f};
    end
    inpdb = cellfun(@(x) pdb2mat(fullfile(p, x)), f ,'Un', 0);
    inpdb = [inpdb{:}];
end

%inpdb is a struct with fieldnames = PDB data

%For each PDB file...
len = length(inpdb);
out = cell(1,len);
for i = 1:len
    tmp = inpdb(i);
    tfca = strcmp(tmp.atomName, 'CA');
    anum = tmp.resNum(tfca);
    bfac = tmp.betaFactor(tfca);
    out{i} = [ anum(:) bfac(:) ];
end

figure, hold on, cellfun(@(x) plot(x(:,1),x(:,2)), out)

if exist('f', 'var')
    legend(f)
end