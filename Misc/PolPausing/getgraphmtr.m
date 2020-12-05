function out = getgraphmtr(dims)

[f, p] = uigetfile('*.fig', 'Mu', 'on');
if ~p
    return
end

fg = figure('Name', 'Fig Matrix');

%Check dims is ok, otherwise use 1xn
if nargin < 1
    dims = [length(f) 1];
end

for i = 1:length(f)
    pf = fullfile(p, f{i});
    %Load fig
    infg = open(pf);
    ax = infg.Children(1);
    
    %Get axis coords
    sp = subplot2(fg, dims, i);
    pos = sp.Position;
    delete(sp);
    
    %Copy over, set new position
    axnew = copyobj(ax, fg);
    axnew.Position = pos;
    title(axnew, f{i}(1:end-4), 'Interpreter', 'none');
    
    %Deal with x labels
    if mod(i, dims(1))
        xlabel(axnew, '')
    end
    
    %Clean up
    delete(infg)
end
