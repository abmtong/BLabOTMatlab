function procFran(dop)

p = uigetdir('D:\Data');

%Get every subfolder
d = dir(p);
fol = {d([d.isdir]).name};
fols = fol(3:end); %Remove '.' and '..'

%Pass the txt file of p\folnam\folnam.txt

if nargin < 1
    dop = DataOptsPopup;
end

if isempty(dop)
    return
end

for i = 1:length(fols)
    AProcessDataV2(fullfile(p, fols{i}, [fols{i} '.txt']), dop);
end