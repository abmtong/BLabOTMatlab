function pickbyeye(dat)

Fs=1e3;
align = 0;
%Align by crossing a pt
st = cellfun(@(x) find(x > align, 1, 'first'), dat, 'Un', 0);
dat = cellfun(@(x,y) x(y:end), dat, st, 'Un', 0);

fg = figure;
hold on
uicontrol(fg, 'Units', 'normalized', 'Position', [0, 0, .05, .05], 'String', '[Output bool]', 'Callback', @outputtf);
trs = cellfun(@(x)plot((1:floor(length(x)/50))/Fs*50, windowFilter(@mean, x, [], 50)),dat, 'Un', 0);
function outputtf(~,~)
    assignin('base', 'tfpbe', cellfun(@isvalid,trs))
end
end




