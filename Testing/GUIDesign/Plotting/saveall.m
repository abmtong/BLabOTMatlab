function saveall

folnam = datestr(now, 'yymmdd_HHMMSS');

mkdir(folnam);

%save wkspc
evalin('base', sprintf('save([''%s'' filesep ''wkspc.mat''])', folnam))

%save figs
gr = groot;
gr=gr.Children;

for i = 1:length(gr)
    savefig(gr(i), [folnam filesep 'fig' sprintf('%02d',i) '.fig'])
end
