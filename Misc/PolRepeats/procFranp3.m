function out = procFranp3(inst, rAopts)

%Check for crossers
bdys = [558 631 704]-16;
crx = bdys(end);

for i = 1:length(inst)
    tmp = inst(i);
    
    %Check for crossers
    tfc = cellfun(@(x) sum( x > crx ), tmp.drA);
    tfc = tfc > 10; %If more than say 10pts are above the crossing line, count it as 'crossed'
    inst(i).tfc = tfc;
    
    %Repeat RTH with only crossers
    if all(~tfc)
        rthc = [0 0];
    else
        [hy, hx] = sumNucHist(tmp.drA(tfc), rAopts);
        rthc = [hx(:) hy(:)];
    end
    inst(i).rthc = rthc;
    
end

out = inst;
    