function pickbyeye(dat)


fg = figure;
hold on
uicontrol(fg, 'Units', 'normalized', 'Position', [0, 0, .05, .05], 'String', '[Output bool]', 'Callback', @outputtf);
trs = cellfun(@(x)plot(windowFilter(@mean, x, [], 50)),dat, 'Un', 0);
function outputtf(~,~)
    assignin('base', 'tfpbe', cellfun(@isvalid,trs))
end
end




