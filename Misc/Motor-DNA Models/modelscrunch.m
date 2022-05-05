function modelscrunch
%Models the 'scrunchworm'

%Label the states A#, where the letter is Dwell or Burst and the number is #ATP
ordr = {'B' 'B' 'A' 'B'}; %12 states, but 0's and 5's are equal
%Generate option arrays
dopts = struct('pos', {[0 0 -6.8] [0 0 -6.8] [0 0 -6.8+.85] [0 0 -6.8+.85]} , ...
               'isAform', { [] [] 11:20  []} ...
            );



mopts = struct('cols', { [1 1 1 1 1] [2 1 1 1 1] [2 2 1 1 1] [2 2 1 1 1] [2 2 2 1 1] [2 2 2 2 1] [2 2 2 2 2] [2 2 2 2 2] [1 2 2 2 2] [1 1 2 2 2] [1 1 1 2 2 2] [1 1 1 1 2] [1 1 1 1 1] }, ...
    'dht', repmat({[0 -.85 -.85 -.85 -.85]},[1 13]),... [0 -.85 -.85 -.85 -.85] [0 0 -.85 -.85 -.85] [0 0 0 -.85 -.85] [0 0 0 0 -.85] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 -.85 0 0 0] [0 -.85 -.85 0 0] [0 -.85 -.85 -.85 0] [0 -.85 -.85 -.85 -.85] },...
    'pos', repmat({[0 0 0]}, [1 13])...
    );


%Create figure panels for each state
len = length(ordr);
axs = gobjects(1,len);
for i = 1:len
    axs(i) = modelfig(ordr{i});
    dmotorV2(axs(i), mopts(i));
    ddna_scrunch(axs(i), dopts(i));
    addlight(axs(i))
    setcmap(axs(i))
end

% return %Modify for loop range and enable this return to just output one figure, for testing colors

error %Havent checked later steps
gifres = 3;
frres  = 3;

%Create axis to view
ax = modelfig(ordr{1}, 1);
dmotorV2(ax, mopts(1));
ddna(ax, dopts(1));
addlight(ax)
setcmap(ax)
% ax.Projection = 'perspective'; %Use MATLAB 3D
addframe('outgif2c.gif', gcf, 1, gifres)
addframe('outfr2c.gif', gcf, 1, frres)

%Tween between nframes
twfrms = [1 1 5 5 5 5 1 1 5 5 5 5];
for i = 2:12
    ii = i - floor((i-1)/len)*len;
    tweenaxs(ax, axs(ii), twfrms(ii), .1, gifres)
    pause(.5)
    addframe('outgif2c.gif', gcf, 1, gifres)
    addframe('outfr2c.gif', gcf, 1, frres)
end

end

function [ax, fh] = modelfig(name, scale)
if nargin < 2
    scale = 1;
end
fh = figure('Name', sprintf('Springworm %s', name), 'Position', scale*[200 200 960 480]);
ax = gca;
hold on
xlim([-5 5])
ylim([-5 5])
zlim([-5 5])

campos = 2;
switch campos
    case 0 %Original: Slightly from above
        ax.CameraPosition = [0 5 1];
    case 2 %Normal but tilted, ball at camera
        ax.CameraPosition = [-1.5 5 0];
    case 3 %From top
        ax.CameraPosition = [0 0 2];
        ax.Projection = 'perspective';
    otherwise %Normal look, SSU on left
        ax.CameraPosition = [0 5 0];
end

ax.CameraTarget = [0 0 0];
axis square
end

function addlight(ax)
light(ax, 'Position', [5 5 5])
% material dull
material(ax, [.6 .9 .0]) %Usual 'dull' preset is [.3. 8 0]
%Material params are ambient, diffuse, specular lighting
%V2 uses .6 .9 0, to be brighter for orange
end

function setcmap(ax)
col0 = [ 0 0 0];    %0: Black, for cel shading / etc.

% col1 = [0 1 0];     %1: Green, for ATP-motor
col1 = [0 255 0]/255;     %1: Light green, for ATP-motor

col2 = [253 180 21 ]/255;   %2: Orange, for ADP-motor
% col2 = [1 1 0];   %2: Yellow, for ADP-motor

col3 = [0 150 255]/255;     %3: Blue, for DNA Pi

col4 = [1 0 0]; %4: Red, for RNA Pi

cspc = [col0; col1; col2; col3; col4];
ax.CLim = [0 size(cspc,1)];
colormap(ax, cspc)
end