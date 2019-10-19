function outscales = scalecontourwrap(insd)
%does scalecontour for all fcs in insd

len = length(insd.time);
outscales = zeros(1, len-1);

for i = 1:len-1
    outscales(i) = scalecontour(insd.time{i}, insd.contour{i}, insd.time{i+1}(1)-insd.time{i}(1), ...
        insd.mxpos(i:i+1), [median(insd.force{i}) insd.opts.dnaPL insd.opts.dnaSM]);
end