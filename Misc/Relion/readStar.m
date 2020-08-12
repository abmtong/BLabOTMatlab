function readStar()

[f p] = uigetfile('C:\*.star');
if ~p
    return
end


tbl = xlsread(fullfile(p,f), 'FileType', 'text', 'ReadVariableNames', 0, 'ReadRowNames', 0, 'Delimiter', ' ');

a=1;