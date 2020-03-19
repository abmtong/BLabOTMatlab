function out = ddna(axorob, inOpts)
n = [-31 11]; %bps to draw
px = 30; %resolution of balls

opts.dht = .34; %nm/bp
opts.dth = -36 / 180 * pi; %rad/bp, 36 for 10/pitch, 33 for 10.5/pitch

opts.dims= .2; %Dimensions of phosphate sphere
opts.dq = [0 -.2]; %Depth queue: modifier on each dimension
opts.pos = [0 0 0]; %Position
opts.r = 1; %Radius of motor center of mass, nm
opts.color = 3;


if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Create the unit sphere
[sx, sy, sz] = sphere(px);
%Scale to dimensions
sx = sx * opts.dims;
sy = sy * opts.dims;
sz = sz * opts.dims;
sc = ones(size(sx))*opts.color;

bps = n(1):n(2);
%Translate/rotate/resize this sphere to make the motor
for i = 1:length(bps)
    %Get angle, in radians
    th = -opts.dth * bps(i);
    %Translate to SSU position, say this is along +x
    x = opts.r;
    y = 0;
    %Rotate along z by theta
    [x, y] = rot2d(x, y, th);
    %Translate along z
    z = opts.dht * bps(i);
    %Calculate depth queue factor
    dq = 1 + sum(opts.dq .* (opts.r - [x y]));
    
    %Plot or update coords
    if isa(axorob(1), 'matlab.graphics.axis.Axes')
        out(i) = surf(axorob,opts.pos(1)+x+sx*dq,opts.pos(2)+y+sy*dq,opts.pos(3)+z+sz*dq,sc,'EdgeColor', 'none');
    else
        axorob(i).XData = opts.pos(1)+x+sx*dq;
        axorob(i).YData = opts.pos(2)+y+sy*dq;
        axorob(i).ZData = opts.pos(3)+z+sz*dq;
        axorob(i).CData = sc; %#ok<*AGROW>
        out=axorob;
    end
end


end