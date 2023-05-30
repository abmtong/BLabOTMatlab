function out = cropEzDro(inst, frrng)
%Crop to inst, rename frames
% Code doesn't handle frames not starting from 1 that well

frs = [inst.frame];
ki = frs >= frrng(1) & frs <= frrng(2);

%Adjust frame #s so frrng(1) is frame 1
frs = frs - frrng(1) + 1;
frcell = num2cell(frs);
[inst.frame] = deal(frcell{:});

%Remove other frames
out = inst(ki);
