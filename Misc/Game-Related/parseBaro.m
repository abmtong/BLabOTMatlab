function [out, dats] = parseBaro(intxt)
%intxt = {Text, date, date, date, Text, date, date, etc.

outraw = [];
nams(1) = intxt(1);
dats = [];
tmp = [];
medg = [];
avgg = [];
for i = 2:length(intxt)
    %Check if it's a date or not
    try
        dn = datenum(intxt{i});
    catch %Errored, so this is a name, so restart
        outraw = [outraw {tmp}];
        dats = [dats {tmp}];
        if length(tmp) > 1
            medg = [medg {datestr( round( tmp(end) + median(diff(tmp)) ) )}];
            avgg = [avgg {datestr( round( tmp(end) + mean(diff(tmp)) ) )}];
        else
            medg = [medg {datestr( tmp )}];
            avgg = [avgg {datestr( tmp )}];
        end
        tmp = [];
        nams = [nams intxt(i)];
        continue
    end
    %This is a date, add to date
    tmp = [tmp dn];
end
%Add final guy to cell
dats = [dats {tmp}];
medg = [medg {datestr( round( tmp(end) + median(diff(tmp)) ), 'yy/mm/dd')}];
avgg = [avgg {datestr( round( tmp(end) +   mean(diff(tmp)) ), 'yy/mm/dd')}];

%Process per data
nams = cellfun(@(x) x(1:end-4), nams, 'Un', 0); %Strip .png

%Output
out = [nams; medg; avgg;];

dd = cellfun(@diff, dats, 'Un', 0);
dd = [dd{:}];
fprintf('Average delay: %d days\n', median(dd))