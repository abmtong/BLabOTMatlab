function out = pddomarp1(inst, inOpts)
%Pol dwelldist for a procFranp2 struct (post-ruler alignment)

opts.dir = 1; %Translocation direction: positive or negative
  % Probably handle this by just negating the OF traces instead

%fitVitterbi opts
opts.fvopts.dir = 0;
opts.fvopts.trnsprb = [1e-3 1e-100]; 
opts.fvopts.ssz = 1;

%For each struct
len = length(inst);
for i = 1:len
    %Get data, drA field
    dat = inst(i).drA;
    if isempty(dat)
        continue
    end
    
    %Some code copied from pol_dwelldist_p1
    
    %Fit to staircase
    [~, trs] = fitVitterbi_batch(dat, opts.fvopts);
    
    %Remove empty (failed traces)
    trs = trs(~cellfun(@isempty, trs));
    
    %Join backtracks
    [trs, isbt] = cellfun(@(x)removeTrBts(x, opts.dir), trs, 'Un', 0);
    
    %Convert staircases to ind, mea
    [dws, mes] = cellfun(@(x) tra2ind(x), trs, 'Un', 0);
    
    %Sanity check means. Use eps-thresholded equals
    if ~all(cellfun(@(x) all( abs(diff(x) * opts.dir - opts.fvopts.ssz) < 10*eps( max( max(abs(x)), opts.fvopts.ssz) )), mes))
        warning('Steps not uniform (stitching error?)');
    end
    
    %Add to struct
    inst(i).pdd = trs;
    inst(i).isbt = isbt;
end

out = inst;

