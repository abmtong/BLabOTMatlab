function [num, mmddyy, com] = scanTest(in)

fid = fopen(in);

line = textscan(fid, '%d %d %d %s','Delimiter','\n','Whitespace','');
fclose(fid)








%%Works fine
% %First line is MMDDYY
% line = textscan(fid, '%s','Delimiter','\n','Whitespace','');
% mmddyy = sprintf('%06d', str2double(line{1}{1}));
% 
% i = 0;
% while true
%     i = i + 1;
%     line = textscan(fid, '%s',1,'Delimiter','\n','Whitespace','');
%     if isempty(line{1})
%         break
%     end
%     linedat = textscan(line{1}{1}, '%d %d %d %s','Whitespace','');
%     num(i,1:3) = [linedat{1:3}]; %#ok<*AGROW>
%     
%     note = linedat{4};
%     if isempty(note)
%         note = {''};
%     end
%     com{i} = note{1};
% end