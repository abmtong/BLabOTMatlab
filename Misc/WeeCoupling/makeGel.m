function out = makeGel(inst)

%UNFINSHED

%Make what the 'gel' would look like
dt= 30; %30s timestep
maxt = 900;
dsamp = 1000;
Fs = 4000/3;

len = length(inst);

for i = 1:len
    %Get data
    dat = inst(i).con;
    ntr = length(dat);
    
    %Filter
    datF = cellfun(@(x) windowFilter(@mean, x, [], dsamp), dat, 'Un', 0);
    
    %Apply offset
    if isfield(inst, 'shift')
        datF = cellfun(@(x) x + inst(i).yoffmanual, datF, 'Un', 0);
    end
    
    %Extend pts to a minimum length
    maxnpts = maxt / dt * Fs / dsamp;
    
    %For each timestep
    for j = 1:nsteps
    
    %Get data
    % Create KDF
    
    end
    
    %Assemble to image (2d matrix)
    
    
    %Plot, with white-to-black colormap
    
    %Maybe plot distance as log 
    
    
end