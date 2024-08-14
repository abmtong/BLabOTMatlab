function out = procFran_pdd(inst, pddopts)
%Run pol_dwelldist_p1 on traces

% Analyze RTH (with the pdd crossing times instead of RTH) with _pddp2

roi = [0 780]; %Range of interest
roi = [-inf inf]; %Range of interest
% fil = 5; %Downsample amount? eh skip

if nargin < 2
    pddopts.dir = 1; %Translocation direction: positive or negative
    %fitVitterbi options don't really matter, but they're here
    pddopts.fvopts.dir = 0;
    pddopts.fvopts.trnsprb = [1e-3 1e-10]; %If max stepping rate ~ 20/s. Doesn't really change results
    %Comparing a forced monotonic vs. backtrack-okay trace for one that is mostly monotonic doesn't make much of a difference - good
    pddopts.fvopts.ssz = 1;
end


%Run fitVitterbi on traces. Deal with backtracks later (p2)
len = length(inst);
for i = 1:len
%     try
        tmpdat = inst(i).drA;
%         %Filter
%         tmpdatF = cellfun(@(x) windowFilter(@mean, x, [], fil), tmpdat, 'Un', 0);
        
        %Crop to roi
        st = cellfun(@(x) find(x>roi(1), 1, 'first'), tmpdat, 'Un', 0);
        en = cellfun(@(x) find(x<roi(2), 1, 'last'), tmpdat, 'Un', 0);
        lens = cellfun(@length, tmpdat, 'Un', 0);
        tmpdat = cellfun(@(x,y,z) x( y:z ), tmpdat, st, en, 'Un', 0);
        [~, trs] = fitVitterbi_batch(tmpdat, pddopts);
        
%         %Expand to un-downsample
%         [in, me] = cellfun(@tra2ind, trs, 'Un', 0);
%         trs = cellfun(@(x,y) ind2tra([1 x(2:end)*fil],y), in, me, 'Un', 0);
%         tlen = cellfun(@length, trs, 'Un', 0);
        
        %Pad with NaNs to match length of data
        trs = cellfun(@(x,y,z,a) [ nan(1, y-1) x nan(1, a-z) ] , trs, st, en, lens, 'Un', 0);
%         trs = cellfun(@(x,y,z,a) [ nan(1, y*fil-1) x nan(1, a-z-y*fil-2) ] , trs, st, tlen, lens, 'Un', 0);
        
        inst(i).pdd = trs;
%         inst(i).isbt = bt;
%     catch
%     end
end

out = inst;
