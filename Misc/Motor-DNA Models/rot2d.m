function [outx, outy] = rot2d(inx, iny, th)

outx = zeros(size(inx));
outy = zeros(size(iny));

r = rotz(th/pi*180);
r = r(1:2,1:2);

for i = 1:numel(inx)
    tmp = r * [inx(i);iny(i)];
    outx(i) = tmp(1);
    outy(i) = tmp(2);
end


%Slower, but 'one line'
% rx = r(1,1:2);
% ry = r(2,1:2);
% [outx, outy] = arrayfun(@(x,y) deal( rx * [x; y] , ry * [x; y]), inx, iny); 