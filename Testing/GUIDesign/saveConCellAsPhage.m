function saveConCellAsPhage(inContour, Fs, outstr)

if nargin< 3
    outstr = '';
end
if nargin < 2
    Fs = 2500;
end
len = length(inContour);
stepdata.contour = inContour;
stepdata.time = cell(1,len);
lens = cellfun(@length, inContour);
inds = [0 cumsum(lens)];
for i = 1:len
    stepdata.time{i} = (inds(i)+1:inds(i+1))/Fs;
    stepdata.force{i} = [7*ones(1,lens(i)-1) 12];
end
save(sprintf('phage%sN%s',datestr(now,'mmddyy'),outstr),'stepdata')