function out = procRandNucMap(gendat)
%Makes a random assortment of nucleosomes, la the output of procNucMap

opts.nucdens = 400; %Density for nucleosomes, one per N bps (has to be at least 300, given the placing algorithm)
opts.nucfootprint = 200;
%Sanity check> nucdens minimum 400 (footprint *2, because algo is greedy)
opts.nucdens = max( opts.nucdens, opts.nucfootprint*2 );

%For each genome in the file...
len = length(gendat);
for i = len:-1:1
    nbp = length(gendat(i).seq);
    
    nnuc = floor( nbp / opts.nucdens );
    nucplaced = 0;
    nuclocs = nan(1, nnuc);
    while nucplaced < nnuc
        %Try to place a nucleosome...
        tmploc = randi(nbp);
        %Check if it's okay: 75bp away from any other point
        if min( abs( tmploc - nuclocs ) ) > opts.nucfootprint/2 || nucplaced == 0
            %If okay, update values
            nucplaced = nucplaced + 1;
            nuclocs(nucplaced) = tmploc;
        end
        
        
    end
    out(i).chr = gendat(i).chr;
    out(i).nucpos = [nuclocs' nuclocs'+opts.nucfootprint/2];
    out(i).name = struct('Name', 'Simulated', 'Organism', [], 'AnalysisProgram', '');
end