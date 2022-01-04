function out = dateislater(date1, date2, fmt)
%Outputs if day2 is after day1 (1) or not (-1) or same (0)
% fmt is a string eg 'MMDDYY' that says the format of the day1/day2 strings

if nargin  <3
    fmt = 'MMDDYY';
end

%Find string in fmt
mind = strfind(fmt, 'MM');
dind = strfind(fmt, 'DD');
yind = strfind(fmt, 'YY');

if isempty(mind) || isempty(dind) || isempty(yind)
    error('Format is wrong, needs ''MM'', ''DD'', and ''YY'' somewhere in it')
end

%Extract m/d/y from the strings
m1 = str2double( date1(mind+ [0 1]) );
m2 = str2double( date2(mind+ [0 1]) );
d1 = str2double( date1(dind+ [0 1]) );
d2 = str2double( date2(dind+ [0 1]) );
y1 = str2double( date1(yind+ [0 1]) );
y2 = str2double( date2(yind+ [0 1]) );

%Assume we're in the 1950-2050 range
if y1 > 50
    y1 = y1 - 100;
    warning('Year is assumed to be 1950-2050, converting %02d to 19%02d', y1, y1)
end
if y2 > 50
    y2 = y2 - 100;
    warning('Year is assumed to be 1950-2050, converting %02d to 19%02d', y1, y1)
end

ymd1 = [y1 m1 d1];
ymd2 = [y2 m2 d2];

df = ymd2 - ymd1;
ind = find(df ~= 0, 1, 'first');
if isempty(ind) %Dates are same
    out = 0;
else
    out = sign(df(ind));
end
% 
% %Compare years
% if y2 > y1
%     out = 1;
% elseif y2 < y1
%     out = -1;
% elseif m2 > m1
%     out = 1;
% elseif m1 < m2
%     out = -1;
% elseif d2 > d1
%     out = 1;
% elseif d2 < d1
%     out = -1;
    
    
end

