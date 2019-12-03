function [out, labelsx, labelsy, reshaped] = getrsdfromfig(fg)
%Gets the energies ('nrg') from figures
%Run with no input to get fig file picker
%Labels is always {'Co Sy' 'Co Hy' 'De Sy' 'De Hy' 'De Sy op' 'De Hy op'}

%if nargin < 1, get fg from filepicker [batch]
if nargin < 1
    [f, p] = uigetfile('E*.fig','Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    len = length(f);
    out = cell(1,len);
    labelsy = cell(1,len);
    for i = 1:len
        fg = openfig(fullfile(p, f{i}), 'invisible');
        [out{i}, labelsx, labelsy{i}] = getrsdfromfig(fg);
        close(fg)
    end

    reshaped = reshape([out{:}], 9, [])';

    %Save as csv
    tbl = [ 'Names' labelsx 'Hz'; ...
        labelsy' num2cell(reshaped)];
    outnam = sprintf('%srsd%s.csv',p, labelsy{1}(1:10));
    writetable(cell2table(tbl), outnam);
    return
end

%get list of titles
axnms = cellfun(@(x) x.String, {fg.Children.Title}, 'Un', 0);
%Find those that match data ones
goodnames = {'Nai Syn' 'Nai Hyd' 'Opt Syn' 'Opt Hyd'};
labelsx = [goodnames cellfun(@(x) [x ' op'], goodnames, 'Un', 0) ];
labelsy = fg.Name;
isdes = [ 0 0 1 1];

out = NaN(1,9); %[rsd rsdop hz]
for i = 1:length(goodnames)
    ind = find(strcmp(axnms, goodnames{i}),1,'first');
    if isempty(ind)
        continue
    end
    
    if isdes(ind)
        ln = fg.Children(ind).Children(3);
        lnop = fg.Children(ind).Children(4);
    else
        ln = fg.Children(ind).Children(2);
        lnop = fg.Children(ind).Children(3);
    end
    

    %calcResid if non-NaN
    if isa(ln, 'matlab.graphics.chart.primitive.Line') && ~any(isnan(ln.YData))
        out(i) = calcResid(ln.XData, ln.YData);
    end
    if isa(lnop, 'matlab.graphics.chart.primitive.Line') && ~any(isnan(lnop.YData))
        out(i+4) = calcResid(lnop.XData, lnop.YData);
    end
    
    %Get Hz
    out(9) = 1/fg.Children(ind).Children(end).XData(end);

end