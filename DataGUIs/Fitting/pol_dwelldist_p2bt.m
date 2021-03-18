function out = pol_dwelldist_p2bt(indw, inbt, inOpts)
%Analyzes just the dwells
%Also adds stats of nbt/ntot

%Fitting options (same as p2)
opts.xrng = [2e-3 inf]; %Crop some of the shorter dwells, because fitting is wonk
opts.prcmax = 99.9; %Crop the few superlong dwells by percentile - may cause pdf to underflow during search (esp. during mle, as it tries to fit that pt)
opts.nmax = 5; %max exponentials to fit

opts.btmin = 10; %Minimum points to fit

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

if isstruct(indw)
    %Do batch if struct, assume the fields of indw are the same as inbt
    fns = fieldnames(indw);
    %Get backtracks
    for i = 1:length(fns)
        tmp = cellfun(@(x,y)x(y), indw.(fns{i}), inbt.(fns{i}), 'Un', 0);
        tmp = [tmp{:}];
        %Only add to analysis 'stack' if longer than btmin
        if opts.btmin <= length(tmp)
            bts.(fns{i}) = {tmp};
        end
    end
    %Do pddp2
    out = pol_dwelldist_p2(bts, opts);
    return
end

bts = cellfun(@(x,y)x(y), indw, inbt, 'Un', 0);
nbt = sum(cellfun(@length, inbt));

if opts.btmin <= nbt
    out.fit = pol_dwelldist_p2({[bts{:}]}, opts);
else
    out.fit = [];
end
% out.bts = bts;
% out.n = sum(cellfun(@length, indw));
% out.nbt = sum(cellfun(@length, inbt));
% out.btprb = out.nbt/out.n;
