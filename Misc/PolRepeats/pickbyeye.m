function pickbyeye(dat, ind)
if nargin < 2
    ind = 1;
end

Fs=800;
align = 0;
%Align by crossing a pt
st = cellfun(@(x) find(x > align, 1, 'first'), dat, 'Un', 0);
dat = cellfun(@(x,y) x(y:end), dat, st, 'Un', 0);
len = length(dat);
fprintf('Picking %d traces by eye\n', len)

fg = figure;
hold on
uicontrol(fg, 'Units', 'normalized', 'Position', [0, 0, .05, .05], 'String', '[Output bool]', 'Callback', @outputtf);
trs = cellfun(@(x)plot((1:floor(length(x)/50))/Fs*50, windowFilter(@mean, x, [], 50)),dat, 'Un', 0);
function outputtf(~,~)
    %Assignin
    assignin('base', 'tfpbetmp', cellfun(@isvalid, trs))
    evalin('base', sprintf('tfpbe{%d} = tfpbetmp;', ind ) )
    fprintf('Picked %d out of %d traces\n', sum(cellfun(@isvalid, trs)), len)
end
end




