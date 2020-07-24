function modelspwm()

%Models the 'springworm'

%Label the states A#, where the letter is Dwell or Burst and the number is #ATP
ordr = {'D0' 'D1' 'D2' 'D3' 'D4' 'D5' 'B5' 'B4' 'B3' 'B2' 'B1' 'B0'}; %12 states, but 0's and 5's are equal
%Generate option arrays
mopts = struct('cols', { [3 3 3 3 3] [1 3 3 3 3] [1 1 3 3 3] [1 1 1 3 3 3] [1 1 1 1 3] [1 1 1 1 1] [1 1 1 1 1] [3 1 1 1 1] [3 3 1 1 1] [3 3 3 1 1] [3 3 3 3 1] [3 3 3 3 3]}, ...
               'dht', {[0 0 0 0 0] [0 0 0 0 0] [0 -.85 0 0 0] [0 -.85 -.85 0 0] [0 -.85 -.85 -.85 0] [0 -.85 -.85 -.85 -.85] [0 -.85 -.85 -.85 -.85] [0 -.85 -.85 -.85 -.85] [0 0 -.85 -.85 -.85] [0 0 0 -.85 -.85] [0 0 0 0 -.85] [0 0 0 0 0]}...
                );
dopts = struct('pos', {[0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 0] [0 0 .85] [0 0 .85*2] [0 0 .85*3] [0 0 .85*4]});

len = length(ordr);

%Loop over next ones
for i = 1:1e6
    if i == 1 %Set up first figure
        [ax, fg]=modelfig(ordr{i});
        dm = dmotor(ax, mopts(1));
        dd = ddna(ax, dopts(1));
        addlight(ax)
        setcmap(ax)
    else
        ii = i - floor((i-1)/len)*len;
        %Rename figure
        fg.Name = ['Springworm ' ordr{ii}];
        dm = dmotor(dm, mopts(ii));
        dd = ddna(dd, dopts(ii));
    end
    pause(.5)
    drawnow
end

end

function [ax, fh] = modelfig(name)
fh = figure('Name', sprintf('Springworm %s', name));
ax = gca;
hold on
xlim([-5 5])
ylim([-5 5])
zlim([-5 5])
ax.CameraPosition = [0 -5 1];
ax.CameraTarget = [0 0 0];
axis square
end

function addlight(ax)
light(ax, 'Position', [5 -5 5])
material(ax, 'dull')
end

function setcmap(ax)
ax.CLim = [0 3];

col0 = [ 0 0 0];    %0: Black, for cel shading / etc.
col1 = [0 1 0];     %1: Green, for ATP-motor
col2 = [0 0 1];     %2: Blue, for DNA Pi
col3 = [.8 .8 0];   %3: Yellow, for ADP-motor


cspc = [col0; col1; col2; col3];
colormap(ax, cspc)
end