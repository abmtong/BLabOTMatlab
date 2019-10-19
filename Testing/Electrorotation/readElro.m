function readElro()

%need to add a way to take account of slide tilting...
%might not be the same across one log file, as tilt is per-chamber
%then again, tilt ~ 0-1deg << sd(noise) ~= 7deg, so maybe won't matter?
% I guess it's less about noise, more about the width of the trap
[f, p] = uigetfile('*log.txt');

% [f, p] = uigetfile('*.txt','MultiSelect', 'on');
if ~p
    return
end
% if ~iscell(f)
%     f={f};
% end

fid = fopen([p f]);
lg = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'WhiteSpace', '\t');
fclose(fid);
lg=[lg{:}];

%get first row (column headers), process into valid fieldnames
fns = lg(1,:);
lg = lg(2:end,:);
for i = 1:length(fns)
    fn = fns{i};
    %remove space and parens
    fn(fn==' ' | fn == '(' | fn == ')') = [];
    fns{i} = fn;
end

%for rows that are numbers, convert to numbers
numcols = [4 5 6 10 11 13]; %FPS, Frames, Lost, SoftStarts, FGFreq, Gain
for i = 1:length(numcols)
    lg(:,numcols(i)) = cellfun(@str2double, lg(:,numcols(i)) , 'Un', 0);
end

lg(:,1) = cellfun(@(x) [x(1:end-4) '.txt'], lg(:,1), 'Uni',0);

for i = 1:size(lg, 1)
    %format inf part
    strcel = [fns ;lg(i,:)];
    inf = struct(strcel{:});
    try
        readElro_one(fullfile(p, lg{i,1}),inf);
    catch ME
        warning('File %s failed, Error: %s\n', lg{i,1}, ME.message)
    end
end

switch questdlg('Would you like to move the MAT files?','Cleanup?','To subfolder','No','Choose','No');
    case 'To subfolder'
        movefile([p '*.mat'], [p 'MATs' filesep])
        fprintf('Files moved to .\\MATs\\\n');
    case 'Choose'
        endp = uigetdir();
        movefile([p '*.mat'], [endp filesep])
        fprintf('Files moved to %s\\\n', endp);
    otherwise
end