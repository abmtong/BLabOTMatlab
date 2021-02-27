function out = gausmooth(y, dy, sd, circ)
%Gaussian smoothing, with given y/dy/sd
% If data is circular, set circ = 1 to circular-smooth (else, edge effects)

rpl = floor(length(y)/2);
ngau = floor(min( rpl, round(sd/dy)*3 ) /2);
fila = normpdf( (-ngau:ngau) * dy, 0, sd);

if circ
    rptpausm = filter( fila, 1,[y y]);
    rptpausm = rptpausm( rpl + (1:length(y)) );
    out = circshift(rptpausm, [0 -rpl-ngau]);
else
    out = filter(fila, 1, [y zeros(1,ngau-1)]);
    out = out(ngau:end);
end