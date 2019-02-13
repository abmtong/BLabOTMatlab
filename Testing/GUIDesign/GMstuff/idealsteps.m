function out = idealsteps(subsz, stepsz)

subsz = abs(subsz);
stepsz = abs(stepsz);

dw = 100; %pts
bu = 10; %pts, each

out = ones(1,dw)*stepsz;

pos = stepsz - subsz;
while pos > 0
    out = [out ones(1,bu)*pos]; %#ok<AGROW>
    pos = pos - subsz;
end

out = [out zeros(1,bu)];