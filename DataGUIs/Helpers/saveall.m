function saveall(name)

if nargin < 1
    name = '';
end

fprintf('Saving...')

folnam = [name '_' datestr(now, 'yymmdd_HHMMSS')];

mkdir(folnam);

%save wkspc
evalin('base', sprintf('save([''%s'' filesep ''wkspc.mat''])', folnam))

%save figs
gr = groot;
fgs=gr.Children;

for i = 1:length(fgs)
    fnam = [folnam filesep 'fig' sprintf('%02d_%s',i, matlab.lang.makeValidName(fgs(i).Name))];
    savefig(fgs(i), [fnam '.fig']);
    print(fgs(i), [fnam '.png'], '-dpng', '-r192');
end

fprintf(' Done.\n')