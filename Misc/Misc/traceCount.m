function out = traceCount(inp)

if nargin < 1
    inp = uigetdir;
end

%Get subfolders
d = dir(inp);
d = d(3:end); %Strip . and ..
fol = {d.name};
fol = fol( [d.isdir] );
len = length(fol);
frc = cell(1,len);
nn = zeros(1,len);

for i = 1:len
    
    dd = dir(fullfile(inp, fol{i}, '*.mat'));
    fnam = {dd.name};
    fnam = fnam( ~[dd.isdir] );
    
    hei = length(fnam);
    ftmp = nan(1,hei);
    for j = 1:hei
        tmp = load( fullfile( inp, fol{i}, fnam{j} ) );
        fn = fieldnames(tmp);
        tmp = tmp.(fn{1});
        tfrc = tmp.force;
        if iscell(tfrc)
            tfrc = tfrc{1};
        end
        ftmp(j) = median(tfrc);
    end
    frc{i} = median(ftmp);
    nn(i) = hei;
end

%Create output
out = struct('Name', fol, 'N', num2cell(nn), 'Force', frc);