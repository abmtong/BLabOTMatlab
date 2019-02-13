function outobjs = bDNA2(stpos, hei, nt, ang, col, rad, sz, angoff)
%should probably replace with inputParser
if nargin < 8
    angoff = pi*.75; %angle offset between strands
end
if nargin < 7
    sz = .1; %radius of sphere
end

if nargin < 6
    rad = 1; %radius of bDNA
end

if nargin < 5
    col = .5;
end

if nargin < 4
    ang = 2*pi/10.5; %helical turn, radians)
end

%how many of the helix to plot
if nargin < 3
    nt = 20;
end

if nargin < 2
    hei = .34; %let's make the axes units actual nm
end

if nargin < 1
    stpos = 0;
end

res = 200; % spheres made of this many pts
[spx, spy, spz] = sphere(res);
spx = spx * sz;
spy = spy * sz;
spz = spz * sz;

%expand singletons to arrays of length nt
if isscalar(hei)
    hei = hei * ones(1,nt);
end
if isscalar(ang)
    ang = ang * ones(1,nt);
end
if isscalar(col)
    col = col * ones(1,nt);
end
if isscalar(rad)
    rad = rad * ones(1,nt);
end

%these 4 specify helix center and current angle, travel along z
cenx = 0;
ceny = 0;
cenz = stpos;
cena = 0;
outobjs = gobjects(2, nt);
for i = 0:nt-1
    posx = cenx + cos(cena) * rad(i+1);
    posy = ceny + sin(cena) * rad(i+1);
    posz = cenz;
    
    posx2 = cenx + cos(cena+angoff) * rad(i+1);
    posy2 = ceny + sin(cena+angoff) * rad(i+1);
    posz2 = cenz;
    
    %draw sphere
    outobjs(1, i+1) = surf(spx + posx , spy + posy , spz + posz , col(i+1) * ones(res), 'EdgeColor', 'none');
    outobjs(2, i+1) = surf(spx + posx2, spy + posy2, spz + posz2, col(i+1) * ones(res), 'EdgeColor', 'none');
    
    %increment helix, just moving in Z for now so only cenz increments
    cenx = cenx + 0;
    ceny = ceny + 0;
    cenz = cenz + hei(i+1);
    cena = cena + ang(i+1);
end








