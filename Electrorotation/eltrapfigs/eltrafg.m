function eltrafg()
%An arrow spinning, then show approximation as boxcar in eltrafg2

fg = figure('Name', 'Elro Visualization', 'Color', [1 1 1]);
ax = axes(fg);

%Number of field arrows on each side
nf = 1;
[x,y] = meshgrid(-nf:nf, -nf:nf);
z = ones(nf*2+1);
z(nf+1,nf+1) = 0;
uu = zeros(nf*2+1);
vv = zeros(nf*2+1);
xlim(ax, 1.1 * (nf+1) * [-1 1]);
ylim(ax, 1.1 * (nf+1) * [-1 1]);
axis(ax, 'square');
hold(ax, 'on');

dt = 0.01; %Time sampling rate; arrows spin at 1Hz

tlag = 0; %Time lag of induced dipole

ar = []; %Field lines
ar2 = []; %Induced dipole

%Rectangle with width 1.5, height 1
xlen = 1.5;
ylen = 1;
rectangle('Position', [-xlen -ylen xlen*2 ylen*2]/2, 'Curvature', [1 1], 'EdgeColor', [0 0 0], 'LineWidth', 1)
% rectangle('Position', [-1 -1 2 2]*.5, 'Curvature', 1, 'EdgeColor', [0 0 0], 'LineWidth', 1)

for i = 0:dt:1
    %Delete previous quiver [could update XUVData instead, but eh]
    delete(ar);
    delete(ar2);
    
    %Calculate new field position
    u = sin(2*pi*i)/2;
    v = cos(2*pi*i)/2;
    
    %for electro trapping, modulate amp by abs sin x
    trapdir = 1;
    if trapdir %trap along x
        u = u * abs(u)*2;
        v = v * abs(u)*2;
    else %trap along y
        u = u * abs(v)*2;
        v = v * abs(v)*2;
    end
    
    %Lagging arrow direction
    u2 = u*xlen;
    v2 = v*ylen;
    %For some reason, this single arrow head's scale is wonky if it's just one arrow,
    % so make it the same size as regular u/v
    uu(nf+1,nf+1) = u2;
    vv(nf+1,nf+1) = v2;
    
    ar = quiver(x,y,u*z,v*z,0, 'Color','k', 'AutoScale', 'off', 'MaxHeadSize', 1, 'LineWidth', 2 );%@lines, 1st
    ar2 = quiver(x,y,uu,vv,0, 'Color', [0.635 0.078 0.184], 'AutoScale', 'off', 'MaxHeadSize', 1, 'LineWidth', 2); %@lines, 7th
    pause(.01)
    print(sprintf('img%04d.png',round(i/dt)),'-dpng', '-r192')
end