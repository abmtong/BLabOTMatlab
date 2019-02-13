function modelB(hei, pos, outname)

if nargin < 1
% hei = [-2 1 1 0 0 0] * .85;
hei = [0 0 0 0 0 0]*.85;
end

if nargin < 2
    pos = .85 * 2;
end

if nargin < 3
    outname = '';
end
%start as 5 units
fig = figure ('Position', [0 0 960 540]); hold on
ax1 = gca;

%Plot motor
%For a ring of N balls, the ball radius should be sin(pi/n) times the ring radius r
motor = bDNA(3.4 + hei(1),hei(2:end),5,2*pi/5,0.7,5, 5*sin(pi/5),0);
%Remove half of the balls
delete(motor(2,:));
motor(2,:) = [];
%Make the unit that faces the camera (the special one) transparent
alpha(motor(1), .2)
%Plot DNA
dn1 = bDNA( pos -3.4*2  ,.34,51,2*pi/10,.1,1,.3);
%Set the 1, 11th phosphates to a different color for emphasis
dn1(1,1).CData = .5*ones(200);
dn1(1,11).CData = .5* ones(200);
dn1(1,21).CData = .5* ones(200);
dn1(1,31).CData = .5* ones(200);
dn1(1,41).CData = .5* ones(200);
dn1(1,51).CData = .5* ones(200);

%Set colormap, define color limits so 1=red, 0=blue, 0.5=green, etc.
colormap(modelabccmap); %color is [blue grn yel purp darpurp] for .1:.2:.9
ax1.CLim = [0 1];
%Make the camera look along x
ax1.CameraPosition = [10 0 3];
ax1.CameraTarget = [0 0 3];
%Make axes proportional

axis equal
% axis off
ylim([-9 9])
zlim([-5 12])

%3D Lighting
li = light;

% %Make a cone pointing along x
% [zc, yc, xc] = cone(.5);
% xc = xc * 2 + 1; %stretch, move xc
% 
% 
% % for i = 1:5
%     
%     
%     %Rotate about Z-axis
%     xcrot = cos(ang) * xc - sin(ang) * yc;
%     ycrot = sin(ang) * xc + cos(ang) * yc;
%    
%     %bottom, top cone
%     
%     if ~state %0 if pre, 1 if post movement
%         cn = surface(xcrot, ycrot, zc+ .34*8.75, .8 * ones(size(zc)));
%     else
%         cn2 = surface(xcrot, ycrot, zc + .34 * 11.25, .8 * ones(size(zc)));
%     end
%     %Move dna up by 0.85nm
%     for j = 1:20
%         dn1.
%     
% 
% 

%save image
% print(fig, sprintf('.\\%s\\%s%0.4d',fileout,fileout,i),'-dpng',sprintf('-r%d',96*scale))
        
%save image
if ~isempty(outname)
    print(fig, outname,'-dpng',sprintf('-r%d',96*2))
    close(fig);
end
        








