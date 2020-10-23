function oldOpts = handleOpts(oldOpts, newOpts)
%More careful version of options handler (normally, just end after the first else) that checks for fieldname vailidity.

if isempty(newOpts)
    return
end

if isempty(oldOpts)
%     oldOpts = newOpts;
    return
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