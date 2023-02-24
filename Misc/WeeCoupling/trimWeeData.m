function out = trimWeeData(inst)

fthr = 5; %Should be a 10pN force hold, use f < this to count as a break
% fthrhi = 15; %Sometimes feedback freaks out, and this could count as a break. Flag these, too?
fpts = 10; %Crop from this many pts before the break

%inst: from getFCs_multi

offfil = 1000; %Filter to find position offset (zeroing)
offfilmax = 30*1e3; %Max points (time) to search

% Check if the tether breaks and crop to a few pts before the break, add metadata if it's a break or otherwise
len = length(inst);
for i = 1:len
    %Find if the tether broke by force cutoff
    tbrk = cellfun(@(x) [find( x < fthr, 1, 'first')-fpts length(x)], inst(i).frc, 'Un', 0);
    tfbrk = cellfun(@length, tbrk) == 2; %The tether broke if the above find found something
    
    %Add metadata
    inst(i).tfbreak = tfbrk;
    
    %Crop the data
    inst(i).con = cellfun(@(x,y) x(1:y(1)), inst(i).con, tbrk, 'Un', 0);
    inst(i).ext = cellfun(@(x,y) x(1:y(1)), inst(i).ext, tbrk, 'Un', 0);
    inst(i).frc = cellfun(@(x,y) x(1:y(1)), inst(i).frc, tbrk, 'Un', 0);
end

%Invert con for Opposing data
for i = 1:len
    isopp = strncmp(inst(i).name, 'Opp', 3);
    if isopp
        inst(i).con = cellfun(@(x) -x, inst(i).con, 'Un', 0);
    end
end

%Replace force trace with just avg force
for i = 1:len
    inst(i).frcavg = cellfun(@mean, inst(i).frc);
end

%Remove ext field, don't need it anymore? (keep frc field to check for tether break checking)
inst = rmfield(inst, 'ext');

% Zero based on the starting position (let's say, lowest pt over first 10s, heavy filter?)
%   Keep y offset as metadata

for i = 1:len
    miny = cellfun(@(x) min( windowFilter(@mean, x(1: min(offfilmax, length(x))), [], offfil) ) , inst(i).con);
    inst(i).yoff = miny;
    inst(i).con = cellfun(@(x,y) x - y, inst(i).con, num2cell(miny), 'Un', 0);
end



out = inst;
