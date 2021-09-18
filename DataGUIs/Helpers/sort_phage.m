function [sorted, ind] = sort_phage(infilenames)
%Sorts phage filenames. Generally, sorts cell strings of similar formatting with dates in the form of mmddyy and other numbers <=65408
%Algorithm: Extracts numbers from infilenames, converts the numbers to one unicode char (0-65535), then uses native @sort
% Made to fix the misordering of N100 before N11 [since phage's filenaming is %02d]

sortfilenames = cell(size(infilenames));
for i = 1:length(infilenames)
    str = infilenames{i};
    [st, en] = regexp(str,'\d+');
    sortnum = zeros(1,length(st));
    for j = 1:length(st)
        if en(j)-st(j) == 5 %6 digit number
            %Date, in mmddyy - change to [days since 2015]
            mm = (str(st:st+1));
            dd = (str(st+2:st+3));
            yy = (str(st+4:st+5));
            sortnum(j) = daysact('1/1/15',[mm '/' dd '/' yy]); %Financial toolbox only. Find a replacement, eg round(posixtime( datetime ( 'now' ) )/3600/24-45*365)
        elseif en(j)-st(j) <5 %5 char or less, should be sortable
            sortnum(j) = str2double(str(st(j):en(j)))+127; %The last 'regular' character is tilde, 126, so put numbers after a-z
        else %number is larger than 6 char.
            sortnum(j) = 65535;
        end
    end
    for j = length(st):-1:1
        str(st(j):en(j)) = char(sortnum(j));
    end
    sortfilenames{i} = str;
end
[~, ind] = sort(sortfilenames);
sorted = infilenames(ind);