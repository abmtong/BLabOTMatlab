function folder2comment(inp)
%For data that is organized as Data\Condition\*.mat, reoragnizes to Data\fol2cmt\*.mat with the Condition saved as a comment field

if nargin < 1
    inp = uigetdir('Mu', 'on');
    if ~inp
        return
    end
end

%Get folders of inp...
p = dir(inp);
p = p(3:end); %Remove . and ..
p = p( [p.isdir] ); %Just take folders
p = {p.name};
%Remove a 'fol2cmt' folder, if it exists
p( strcmp(p, 'fol2cmt') ) = [];

hei = length(p);

outp = fullfile(inp, 'fol2cmt');

%Create dir
if ~exist( outp, 'dir' )
    mkdir(outp);
end

for j = 1:hei
    %For each .mat file in the folder...
    f = dir( fullfile(inp, p{j}, '*.mat') );
    f = {f.name};
    len = length(f);
    
    for i = 1:len
        %Load...
        fp = fullfile(inp, p{j}, f{i});
        dt = load(fp);
        
        %Get fieldname
        fn = fieldnames(dt);
        fn = fn{1};
        
        %Check for 'comment' and add path name to comment
        if isfield(dt.(fn), 'comment')
            dt.(fn).comment = [p{j} ' ' dt.(fn).comment];
        else
            dt.(fn).comment = p{j};
        end
        
        %Save with original struct name using save -struct
        save(fullfile(outp, f{i}), '-struct', 'dt')
    end
    
    
end