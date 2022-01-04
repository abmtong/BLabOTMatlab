function filtersplitcond()

%Gets folders, for each folder, get *.mat files, delete based on length, var(frc) 
%Too short (length) or var(frc) (not actually a force hold section)

minlen = 3e3;
maxstd = 4;

%Get folders
p = uigetdir();
d = dir(p);
fols = d( [d.isdir] );
fols = {fols.name};
fols = fols(3:end); %Remove '.' and '..' folders

%Find .mat in the folders
len = length(fols);
ct = 0;
for i = 1:len
    dd = dir(fullfile(p, fols{i}, '*.mat'));
    fils = {dd.name};
    hei = length(fils);
    for j = 1:hei
        %Loop over files
        fp = fullfile(p, fols{i}, fils{j});
        sd = load(fp);
        sd = sd.stepdata;
        %Load frc, check var and length
        frc = sd.force{1};
        n = length(frc);
        s = std(frc);
        %Delete if too short
        if n < minlen || s > maxstd
            ct = ct + 1;
            delete(fp)
        end
    end
end
fprintf('Deleted %d files\n', ct)




end