function modelhohV1(rot)
%Models the 'hand-over-hand translocation mechanism'

if nargin < 1
    rot = 0; %Should the camera rotate to keep the crack in camera POV?
end

%From output, crop to 200x225 px (335 from left, 200 from top) : double now, since uprez'd

%Label the states A#, where the letter is Dwell or Burst and the number is #ATP
ordr = {'T1' 'D1' 'X1' 'T2' 'D2' 'X2' 'T3' 'D3' 'X3' 'T4' 'D4' 'X4' 'T5' 'D5' 'X5' 'T1' }; %Just ATP, ADP, and apo state , others are related by rotational symmetry
%Generate option arrays
pos = repmat( { [0 0 0] [0 0 -.68] [0 0 -.68*2] [0 0 -.68*3] [0 0 -.68*4] [0 0 -.68*5] }, [3,1] );
pos = pos(3:end-1);

%T/D/X generators, where the crack is at the passed var. (e.g. colri(3) puts crack at i-th subunit
colri = @(x) cellfun(@(y)circshift(y, [0 x-1]), {[1 1 1 1 1]+.5 [2 1 1 1 1]+.5 [3 1 1 1 1]+.5}, 'Un', 0);
mhtri = @(x) cellfun(@(y)circshift(y, [0 x]), {[0 -.68 -.68*2 -.68*3 -.68*4] [0 -.68 -.68*2 -.68*3 -.68*4]-.68 [0 -.68 -.68*2 -.68*3 -.68*4]-.68}, 'Un', 0);
dhtri = @(x) cellfun(@(y)circshift(y, [0 x]), {[-.68 -.68 -.68 -.68 -.68] [-.68 -.68 -.68 -.68 0] [-.68 -.68 -.68 -.68 +.68*4] }, 'Un', 0);
mposri= @(x) {[0 0 0] [0 -.68 * (x-1) 0] [0 -.68 * (x-1) 0]};

cols = [colri(5) colri(4) colri(3) colri(2) colri(1)];
mht = [mhtri(5) mhtri(4) mhtri(3) mhtri(2) mhtri(1)];
dht = [dhtri(5) dhtri(4) dhtri(3) dhtri(2) dhtri(1)];
mpos = [mposri(5) mposri(4) mposri(3) mposri(2) mposri(1)];


dopts = struct('pos', [pos pos(end)], 'color', 4);
mopts = struct('cols', [cols cols(1)], 'ht', [mht mht(1)], 'dht', [dht dht(1)], 'mpos', [mpos mpos(1)]);

%Apply changes for rot

%Create figure panels for each state
len = length(ordr);
axs = gobjects(1,len);
for i = 1:len
    axs(i) = modelfig(ordr{i});
    dmotorV2_hoh(axs(i), mopts(i));
    ddna(axs(i), dopts(i));
    addlight(axs(i))
    setcmap(axs(i))
end

% return %Modify for loop range and enable this return to just output one figure, for testing colors

gifres = 3;
frres  = 3;

%Create axis to view
ax = modelfig(ordr{1}, 1);
dmotorV2_hoh(ax, mopts(1));
ddna(ax, dopts(1));
addlight(ax)
setcmap(ax)
% ax.Projection = 'perspective'; %Use MATLAB 3D
addframe('outgif.gif', gcf, 1, gifres)
addframe('outfr.gif', gcf, 1, frres)

%Tween between nframes
twfrms = 5*ones(1,len);%[1 1 5 5 5 5 1 1 5 5 5 5];
for i = 2:len
    ii = i - floor((i-1)/len)*len;
    tweenaxs(ax, axs(ii), twfrms(ii), .1, gifres)
    pause(.5)
    addframe('outgif.gif', gcf, 1, gifres)
    addframe('outfr.gif', gcf, 1, frres)
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

col5 = .3 *ones(1,3); %3: Grey, for apo-motor

col3 = [0 150 255]/255;     %4: Blue, for DNA Pi

col4 = [1 0 0]; %5: Red, for RNA Pi



cspc = [col0; col1; col2; col5; col3; col4];
ax.CLim = [0 size(cspc,1)];
colormap(ax, cspc)
end