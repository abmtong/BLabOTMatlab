function [out, labelsx, labelsy, reshaped] = getnrgfromfig(fg)
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
        [out{i}, labelsx, labelsy{i}] = getnrgfromfig(fg);
        close(fg)
    end
    if length(f) == 1
        out = out{:};
    else
        mns = cellfun(@(x) x(1,:),out,'Un',0);
        mns = reshape([mns{:}], 6, [])';
        sds = cellfun(@(x) x(2,:),out,'Un',0);
        sds = reshape([sds{:}], 6, [])';
        nns = cellfun(@(x) x(3,:),out,'Un',0);
        nns = reshape([nns{:}], 6, [])';
        hzs = cellfun(@(x) x(4,:),out,'Un',0);
        hzs = reshape([hzs{:}], 6, [])';
        %Gather hzs into one value
        hzs2= mean(hzs, 2, 'om'); 
        reshaped = {mns sds nns hzs hzs2};
        
        %Save means as csv
        tbl = [ 'Names' labelsx 'Hz'; ...
            labelsy' num2cell(reshaped{1}) num2cell(hzs2)];
        tbl2 = [ 'Names' labelsx 'Hz'; ...
            labelsy' num2cell(reshaped{2}) num2cell(hzs2)];
        tbl3 = [ 'Names' labelsx 'Hz'; ...
            labelsy' num2cell(reshaped{3}) num2cell(hzs2)];
        
        tbl0 = [tbl cell(size(tbl,1),1) tbl2 cell(size(tbl,1),1) tbl3];
        
        %R2019a has @writecell native, here use writetable(cell2table(cell_input)) instead
        % Will lead to an extra first row (of 'row names'), but whatever
        outnam = sprintf('%snrg%s.csv',p, labelsy{1}(1:10));
        writetable(cell2table(tbl0), outnam);
        
%         outnam = sprintf('%snrgmn%s.csv',p, labelsy{1}(1:10));
%         writetable(cell2table(tbl), outnam);
%         outnam2 = sprintf('%snrgsd%s.csv',p, labelsy{1}(1:10));
%         writetable(cell2table(tbl2), outnam2);
%         outnam3 = sprintf('%snrgnn%s.csv',p, labelsy{1}(1:10));
%         writetable(cell2table(tbl3), outnam3);
    end
    return
end

%get list of titles
axnms = cellfun(@(x) x.String, {fg.Children.Title}, 'Un', 0);
%Find those that match data ones
goodnames = {'Nai Syn' 'Nai Hyd' 'Opt Syn' 'Opt Hyd'};
labelsx = [goodnames {[goodnames{3} ' op']} {[goodnames{4} ' op']}];
labelsy = fg.Name;
isdes = [ 0 0 1 1];

out = NaN(4,6); %[mean; sd; n; Hz]
for i = 1:length(goodnames)
    ind = find(strcmp(axnms, goodnames{i}),1,'first');
    if isempty(ind)
        continue
    end
    
    %Get text string, get numbers from textscan
    if isdes(i)
        txtop = fg.Children(ind).Children(1).String;
        txt = fg.Children(ind).Children(2).String;
        ts = textscan(txt, 'W = %f +- %f, N=%f');
        out(1:3,i) = [ts{:}];
        tsop = textscan(txtop, 'Wop= %f +- %f, N=%f');
        out(1:3,i+2) = [tsop{:}];
        out(4,i) = 1/fg.Children(ind).Children(end).XData(end);
        out(4,i+2) = 1/fg.Children(ind).Children(end).XData(end);
    else
        txt = fg.Children(ind).Children(1).String;
        ts = textscan(txt, 'W = %f +- %f, N=%f');
        out(1:3,i) = [ts{:}];
        out(4,i) = 1/fg.Children(ind).Children(end).XData(end);
    end
end