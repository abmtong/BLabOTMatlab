function [outcond, outext] = splitcond2(con, frc, inOpts)
%Alternative to splitcond, 

%Just take condensing parts (low F)
opts.fthr = 5; %pN
opts.trim = [1000 100]; %Trim by these many pts on each side

if nargin > 2
    opts = handleOpts(opts, inOpts);
end


if iscell(con)
    [outraw, outext] = cellfun(@(x,y) splitcond2(x,y,opts), con, frc, 'Un', 0);
    outcond = [outraw{:}];
    outext = [outext{:}];
    outcond = outcond(~cellfun(@isempty, outcond));
    outext = outext(~cellfun(@isempty, outext));
    return
end

con = con(:)';
frc = frc(:)';

%Split by force
ki = frc < opts.fthr;
[in, me] = tra2ind(double(ki));
kii = me == 1; %Keep only low force sections
st = in(kii);
enin = in(2:end);
en = enin(kii);

%Trim ends
outcond = arrayfun(@(x,y) con( x + opts.trim(1) : y - opts.trim(2) ), st, en, 'Un', 0 );
%Extending sections are the middle parts
outext = arrayfun(@(x,y) con( x + opts.trim(1) : y - opts.trim(2) ), en(1:end), [st(2:end) length(con)], 'Un', 0 );
