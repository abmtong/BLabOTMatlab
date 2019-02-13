function out = h5groupread(infp, instruct)
%Reads a Lumicks HDF5 file. Second paramter is only used for recursing.


if nargin < 2
    instruct = h5info(infp);
    instruct = instruct.Groups;
end


out = [];

%loop over all items in this struct
for struct = instruct'
    %check if there are groups in this group
    if isfield(struct, 'Groups')
        gr = struct.Groups;
        if ~isempty(gr)
            %if so, recurse
            h5fn0 = struct.Name;
            %format fieldname to something ok
            fn0 = formath5fn(h5fn0);
            recurse = h5groupread(infp, [struct.Groups]);
            if ~isempty(recurse)
                out.(fn0) = recurse;
            end
            continue
        end
    end
    %no groups, so fetch data from Datasets field
    h5fn1 = struct.Name;
    %check existence, non-emptiness of Datasets (otherwise, skip)
    if isfield(struct, 'Datasets')
        dss = [struct.Datasets]';
        if ~isempty(dss)
            for ds = dss
                h5fn2 = ds.Name;
                %format field names
                fn1 = formath5fn(h5fn1);
                fn2 = formath5fn(h5fn2);
                %finally, read data
                out.([fn1 '_' fn2]) = h5read(infp, [ h5fn1 '/' h5fn2 ]);
            end
        end
    end
end
end
