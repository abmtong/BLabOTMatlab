function elrofg()
%An arrow spinning, -> show torque

fg = figure('Name', 'Elro Visualization', 'Color', [1 1 1]);
ax = axes(fg);

%Number of field arrows on each side
nf = 1;
[x,y] = meshgrid(-nf:nf, -nf:nf);
z = ones(nf*2+1);
uu = zeros(nf*2+1);
vv = zeros(nf*2+1);
xlim(ax, 1.1 * (nf+1) * [-1 1]);
ylim(ax, 1.1 * (nf+1) * [-1 1]);
axis(ax, 'square');
hold(ax, 'on');

dt = 0.01; %Time sampling rate; arrows spin at 1Hz

tlag = 0.1; %Time lag of induced dipole

ar = []; %Field lines
ar2 = []; %Induced dipole

rectangle('Position', [-1 -1 2 2]*.5, 'Curvature', 1, 'EdgeColor', [0 0 0], 'LineWidth', 1)

for i = 0:dt:3
    %Delete previous quiver [cou  ld update XUVData instead, but eh]
    delete(ar);
    delete(ar2);
    
    %Calculate new field position
    u = sin(2*pi*i)/2;
    v = cos(2*pi*i)/2;
    
    %Lagging arrow direction
    u2 = sin(2*pi*(i-tlag))/2;
    v2 = cos(2*pi*(i-tlag))/2;
    %For some reason, this single arrow head's scale is wonky if it's just one arrow,
    % so make it the same size as regular u/v
    uu(nf+1,nf+1) = u2;
    vv(nf+1,nf+1) = v2;
    
    %e.g. for electro trapping, modulate amp by abs sin x
%     u = u * abs(u);
%     v = v * abs(u);
    
    ar = quiver(x,y,u*z,v*z,0, 'Color', [0 0.447 0.741], 'AutoScale', 'off', 'MaxHeadSize', 1 );%@lines, 1st
    ar2 = quiver(x,y,uu,vv,0, 'Color', [0.635 0.078 0.184], 'AutoScale', 'off', 'MaxHeadSize', 1); %@lines, 7th
    pause(.01)
end