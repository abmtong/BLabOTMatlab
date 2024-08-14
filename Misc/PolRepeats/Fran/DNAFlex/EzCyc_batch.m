function out = EzCyc_batch(inp, cyc)
%Batch wrapper for EzCyc
% This will open and close figures, 


%Warn that this will close all figures
ob = get(0, 'Children');
if ~isempty(ob)
    warning('Close your figures before running this.')
    return
end

if isempty(inp)
    inp = uigetdir();
end

%Get the *.nucleosome.DANPOSPeak.bed files
d = dir(fullfile(inp, '*.nucleosome.DANPOSPeak.bed'));
f = {d.name};
len = length(f);

out = [];
for i = 1:len
    close all
    stT = tic;
    
    %Pass to EzCyc
    [~, tmp, hasrna] = EzCyc(fullfile(inp, f{i}), cyc);
    
    %Format name. Name is like [Organism].[Samplename].nucleosome.DANPOSPeak.bed
    % So let's just take Samplename
    dt = find(f{i} == '.');
    outname = f{i}( dt(1)+1:dt(2)-1 );
    
    %Structure the output data
    dat = struct('name', outname, 'flex', tmp(1), 'rna', tmp(2), 'tss1', tmp(3), 'tss2', tmp(4)); 
    
    %Saveall. Name based on hasrna
    if hasrna
        outname = [outname '_RNA']; %#ok<AGROW>
    end
    
    folnam = saveall(outname, 2);
    
    %Save info
    save(fullfile(folnam, 'meta.mat'), 'dat')
    
    out = [out dat]; %#ok<AGROW>
    
    %Console message
    fprintf('EzCyc_batch finished %s in %0.1f min\n', outname, toc(stT)/60)
end

close all


