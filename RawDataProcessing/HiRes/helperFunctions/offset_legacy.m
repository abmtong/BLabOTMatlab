function outOff = offset_legacy(infp)
if nargin < 1
    [f, p] = uigetfile();
    infp = [p filesep f];
end
d = readDat(infp);
mx = d(5,:);

dec = 10;
thr = 1e-3;
pad = 5;
len = size(d, 2);

ind = diff(abs((velocityThresh(mx, dec))) > thr);
indSta = dec*find(ind<0)-pad; %=-1, end of mirror movement (start of segment)
indEnd = dec*find(ind>0)+pad; %=+1, start of mirror movement (end of segment)
%Might need to shift or add, depending on whether ind starts/ends moving or stationary
if isempty(indSta) && isempty(indEnd) %One segment (e.g. if really slow)
    indSta = dec*1;
    indEnd = dec*length(ind);
elseif length(indSta) > length(indEnd)
    indEnd = [indEnd len];
elseif length(indEnd) > length(indSta)
    indSta = [1 indSta];
elseif indSta(1) > indEnd(1) %lengths are equal
    indSta = [1 indSta];
    indEnd = [indEnd len];
end

outOff = zeros(8, length(indEnd));

for i = 1:length(indEnd)
    outOff(:,i) = mean( d(:, (indSta(i):indEnd(i))), 2);
end