function out = getcropns(path)

if nargin < 1
    path ='C:\Users\interstellar\Box Sync\Res\Current Data\012420 RR+gS';
end

ps = dir([path filesep 'CropFiles*']);
drs = ps( [ps.isdir]);
out = {drs.name};

out = strrep(out, 'CropFiles', '');

%Get number of crops in each folder
len = length(out);
nn = cell(1,len);
for i = 1:length(out)
    tmp = dir(fullfile(path, ['CropFiles' out{i}], '*.crop'));
    nn{i} = length(tmp);
end

fg = figure('Name', sprintf('CropNames for %s', path), 'MenuBar', 'none', 'ToolBar', 'none', 'Visible', 'off');
tb = uitable(fg, 'Data',[{'CropName' 'Files'}; [out' nn']]);
ext = tb.Extent(3:4);
tb.Position = [0 0 ext];
fg.Position(3:4) = ext;
fg.Visible = 'on';