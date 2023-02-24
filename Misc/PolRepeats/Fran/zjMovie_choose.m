function out = zjMovie_choose(inst)

tfkeep = 1;
tfpick = 1;

fil = 10; %As long as the movie filters stronger than this, its ok [wont downsample]
x0 = 558-16;


len = length(inst);
for i = 1:len
    %Get data
    tmpst = inst(i);
    tmp = tmpst.drA( tmpst.tfc & tmpst.tfpick );
    
    %Downsample
    tmpF = cellfun(@(x)windowFilter(@mean, x, fil, 1), tmp, 'Un', 0);
    
    %Find starting points (nucleosome entry)
    t0s = cellfun(@(x) find(x>x0, 1, 'first'), tmpF, 'Un', 0);
    
    %Crop. Remove last few pts too..
    tmpFC = cellfun(@(x,y) x(y:end-fil*2-5), tmpF, t0s, 'Un', 0);
    
    %Extend to similar length
    maxlen = max(cellfun(@length, tmpFC));
    tmpFC = cellfun(@(x) [x x(end) * ones(1, maxlen - length(x))], tmpFC, 'Un', 0);
    
    %Plot
    figure('Name', tmpst.nam)
    hold on
    cellfun(@plot, tmpFC)
    
    %Plot median trace bold
    medtr = median( reshape( [tmpFC{:}], maxlen, []), 2 );
    plot(medtr, 'k', 'LineWidth', 2)
    
    %So we can find a real data that 'looks' like the median data [and just pick by gco]
end