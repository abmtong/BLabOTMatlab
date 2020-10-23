function out = cropAlan(iny, npts)

%Some way to programmatically [or just plot and do by hand] crop these 77 traces

%Start with easycrop with bounds [20, 90]
yr = [20 100];
ki = iny > yr(1) & iny < yr(2);
%Find largest run within these bounds
di = diff([0 ki 0]);
stI = find(di == 1);
enI = find(di == -1)-1;
wid = enI-stI;
[~, ii] = max(wid);
out = iny(stI(ii):enI(ii));
if nargin == 1
    return
end



plot(out)
xlim( xlim + range(xlim) * [-.1 .1])
drawnow
[xx, ~] = ginput(npts);
xx = [ max(xx(1),1) , min(xx(2), length(out)) ] ;
ylim( yr );
if npts == 1
    out = out(1:floor(xx));
else
    out = out(ceil(xx(1)):floor(xx(2)));
end

