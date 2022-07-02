function out = procFranp2_realign(inst, inrAop)
%Rerun rulerAlign on trace struct made by p2

len = length(inst);

%Do two rounds of rulerAlign, second round is more 'precise'
inrAop2 = inrAop;
%New start will be at zero
inrAop2.start = 0;
% %Change filtering and search params?
% inrAop2.perschd = inrAop2.perschd/2;
% inrAop2.filwid = inrAop2.filwid*2;
% inrAop2.binsm = inrAop2.binsm/2;

for i = 1:len
    %RulerAlign again, twice
    inst(i).drA = rulerAlignV2(inst(i).drA, inrAop2);
    %SumNucHist
    [hy, hx] = sumNucHist(inst(i).drA, inrAop);
    inst(i).rth = [hx(:) hy(:)];
end

out = inst;