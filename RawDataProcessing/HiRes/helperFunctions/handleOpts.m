function oldOpts = handleOpts(oldOpts, newOpts)
%More careful version of options handler (normally, just end after the first else) that checks for fieldname vailidity.

if isempty(newOpts)
    return
end

if isempty(oldOpts)
    oldOpts = newOpts;
    return
end

%Check if newOpts is a struct (like oldOpts) or a cell (varargin, so sent as NVPs)
if iscell(newOpts)
    %if newOpts is a cell, could be a cell array of NVPs or a struct sent thru varargin
    if isstruct(newOpts{1})
        %newOpts is a struct passed as varargin, so a {struct}, unwrap and set as newOpts
        newOpts = newOpts{1};
    else
        %Failsafe: Could be that this is a cell of NVPs, not the NVPs themselves, e.g. { {'foo', 12, 'bar', 35} }, unwrap
        if length(newOpts) == 1 && iscell(newOpts{1})
            newOpts = newOpts{1};
        end
        %newOpts is name-value pairs
        tmp = [];
        for i = 1:length(newOpts)/2
            ind = (i-1)*2+1;
            tmp.(newOpts{ind}) = newOpts{ind+1};
        end
        newOpts = tmp;
    end
end


fnNew = fieldnames(newOpts);
fnOld = fieldnames(oldOpts);

for i = 1:length(fnNew)
    fn = fnNew{i};
    if any(strcmp(fn, fnOld))
        %For structs-of-structs, recurse
        if isstruct(newOpts.(fn))
            %Make sure oldOpts has a valid struct
            if ~isfield(oldOpts, fn) || ~isstruct(oldOpts.(fn))
                oldOpts.(fn) = [];
            end
            oldOpts.(fn) = handleOpts(oldOpts.(fn), newOpts.(fn));
        else
            oldOpts.(fn) = newOpts.(fn);
        end
    else
        tf = strcmpi(fn, fnOld);
        if any(tf)
            fn2 = fnOld{tf};
            %Warn if input fname is miscapitalized
            warning('''%s'' might not be a valid options fieldname, using non-case sensitive match ''%s'' instead.',fn, fn2)
            oldOpts.(fn2) = newOpts.(fn);
        else
%             warning('''%s'' might not be a valid options fieldname (did not exist in oldOpts).',fn)
            oldOpts.(fn) = newOpts.(fn);
        end
    end
end