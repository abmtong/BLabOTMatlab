function saveall(name, whattosave)
%whattosave: wkspc (1), figs(2), or both (0)


if nargin < 2
    whattosave = 0;
end

if nargin < 1
    name = '';
end

%Add '_' after name if supplied
if ~isempty(name)
    name = [name '_'];
end

%If called in command form, change e.g. '2' -> 2
if isa(whattosave, 'char')
    whattosave = str2double(whattosave);
end

fprintf('Saving...')

folnam = [name datestr(now, 'yymmdd_HHMMSS')];

mkdir(folnam);

%save wkspc
if whattosave == 0 || whattosave == 1
    evalin('base', sprintf('save([''%s'' filesep ''wkspc.mat''])', folnam))
end

%save figs
if whattosave == 0 || whattosave == 2
    gr = groot;
    fgs=gr.Children;
    fgs = fgs(end:-1:1); %Reverse list, to preserve figure numbering order (not exact numbering)
    
    for i = 1:length(fgs)
        %Try to save figure name the best we can
        fnam = [folnam filesep 'fig' sprintf('%02d_%s',i, matlab.lang.makeValidName(fgs(i).Name))];
        savefig(fgs(i), [fnam '.fig']);
        print(fgs(i), [fnam '.png'], '-dpng', '-r192');
        print(fgs(i), [fnam '.eps'], '-depsc', '-r192');
    end
end

fprintf(' Done.\n')