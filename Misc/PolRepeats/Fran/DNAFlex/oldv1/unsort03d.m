function out = unsort03d(incell, hgflag)

%In cell is a cell of data originating from 1, 2, 3, .... but sorted by string, so the order is 1, 10, 11, 12 ... 2, ...
% i.e., the order of sort( { '1' '2' '3' '4' ... })

if nargin < 2
    hgflag = 0;
end

%Eh write something to handle DcP data
if hgflag
    %For each cell in hgflag
    out = cell(1,4);
    for i = 1:4
        %Get data
        tmp = incell{i};
        
        %Skip empty
        if isempty(tmp)
           continue
        end
        
        %Split to 301e4 chunks
        wid = 301e4;
        nwrite = ceil(length(tmp)/301e4);
        yy = [wid*ones(1,nwrite-1) length(tmp) - (nwrite-1)*wid];
        
        tmp = mat2cell(tmp, 1,  yy );
        
        %And run unsort03d on this guy
        tmp = unsort03d(tmp);
        
        %Ungroup and resave
        out{i} = [tmp{:}];
    end
    
    return
end


len = length(incell);


ind = 1:len;

nam = arrayfun (@(x) sprintf('%02d', x), ind, 'Un', 0);

%Sort
[~, si] = sort(nam);

%And then undo this sorting on incell
out = cell(1,len);
for i = 1:len
    out(i) = incell( (si == i) );
    % Is there a more 'fun' way to invert the si permutation than this way?
end
