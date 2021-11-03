function out = gausmooth(y, dy, sd, circ)
%Gaussian smoothing, with given y/dy/sd
% If data is circular, set circ = 1 to circular-smooth

if sd == 0
    out = y;
    return
end

rpl = floor(length(y)/2);
ngau = floor(min( rpl, round(sd/dy)*3 ) /2);
fila = normpdf( (-ngau:ngau) * dy, 0, sd);

if circ
    rptpausm = filter( fila, 1,[y y]);
    rptpausm = rptpausm( rpl + (1:length(y)) );
    out = circshift(rptpausm, [0 -rpl-ngau]); %-1?
else
    %Filter, pad edge with... zero?
    out = filter(fila, 1, [y zeros(1,ngau)]);
    %Calculate weight (sum of pts in filter
    wgh = filter(fila, 1, [ones(1,length(y)) zeros(1,ngau)]);
    out = out ./ wgh;
    out = out(ngau+1:end);
end