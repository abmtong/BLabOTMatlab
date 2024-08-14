function pickbyeye(dat, ind, ki)
if nargin < 2
    ind = 1;
end
if nargin < 3
    ki = true(size(dat));
end

Fs=800;
% Fs = 4000/3;
align = 0;
dsamp = 100;
dt = 0;

%Guide lines
yy = 59 + 64 * (0:7);

%Align by crossing a pt
st = cellfun(@(x) find(x > align, 1, 'first'), dat, 'Un', 0);
dat = cellfun(@(x,y) x(y:end), dat, st, 'Un', 0);
len = length(dat);
fprintf('Picking %d traces by eye\n', len)

fg = figure;
hold on
uicontrol(fg, 'Units', 'normalized', 'Position', [0, 0, .05, .05], 'String', '[Output bool]', 'Callback', @outputtf);
trs = cellfun(@(x,y)plot((1:floor(length(x)/dsamp))/Fs*dsamp + y, windowFilter(@mean, x, [], dsamp)),dat,num2cell(dt * (0:length(dat)-1)  ), 'Un', 0);

%Pre-delete ~ki, for picking again
cellfun(@delete, (trs(~ki)))

%Draw lines
xx =[0 max(cellfun(@length, dat)) / Fs];
for i = 1:length(yy);
    plot(xx, yy(i) * [1 1], 'k');
end

function outputtf(~,~)
    %Assignin
    assignin('base', 'tfpbetmp', cellfun(@isvalid, trs))
    evalin('base', sprintf('tfpbe{%d} = tfpbetmp;', ind ) )
    fprintf('Picked %d out of %d traces\n', sum(cellfun(@isvalid, trs)), len)
end
end




