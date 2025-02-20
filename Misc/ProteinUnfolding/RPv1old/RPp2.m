function out = RPp2(inst, inOpts)
%Part 2: Finds the rip and when the pull and retract switches over
%V2: convert to contour (XWLC guess) and find one step

%Input: trace inst = struct('frc', {force_data}, 'ext', {ext_data}, 'tpos', {trap_pos_data}
%Output: adds rip, retraction indicies to the struct

%Rip detection options
opts.ripfil = 5; %Filtering amount (downsample)
opts.nrip = 1; %Detect this many rips. Unchecked: Should work for multiple rips by just fitting multiple steps?
opts.frng = [3 30]; %Only check for rips in this force range (removes issues with low force having higher noise)
opts.dwlcg = [50 900]; %DNA XWLC guess, [PL(nm) SM(pN)]

opts.debug = 0; %Debug: Plot output to check

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%For each pulling cycle...
len = length(inst);
for i = 1:len
    tmp = inst(i);
    
    %Divide pull and relax region by maximum tpos value
    [~, retind] = max(tmp.tpos); %retind = 'retract index'
    
    %Find rip by converting to contour (via a guess) and finding steps
    con = tmp.ext ./ XWLC(tmp.frc, opts.dwlcg(1), opts.dwlcg(2));
    % Crop to force range
    ki = find(tmp.frc > opts.frng(1), 1, 'first') : find(tmp.frc < opts.frng(2), 1, 'last');
    ki(ki > retind) = []; %Only consider pulling cycle
    %Crop and filter
    conf = windowFilter(@mean, con(ki), [], opts.ripfil);
    
    %Find one step
    ripind = AFindStepsV4(conf, 0, opts.nrip, 0);
    %ripind is [1 step_loc length(conf)], convert to original indicies.
    ripind = (ripind(2)-1) * opts.ripfil + ki(1);
    
    
    %Just save the locations of the rip and pull
    inst(i).ripind = ripind;
    inst(i).retind = retind;

    %Can extend to finding multiple rips probably by gaussian filtering df and taking best N @findpeaks results
end
out = inst;

if opts.debug
    %plot pre-rip and retraction regions
    figure Name Pre-Rip, hold on, cellfun(@(x,y,z)plot(windowFilter(@mean,x(1:z), opts.ripfil, 1), windowFilter(@mean, y(1:z), opts.ripfil, 1)), {inst.ext}, {inst.frc}, {inst.ripind})
    figure Name Retract, hold on, cellfun(@(x,y,z)plot(windowFilter(@mean,x(z:end), opts.ripfil, 1), windowFilter(@mean,y(z:end), opts.ripfil, 1)), {inst.ext}, {inst.frc}, {inst.retind})
end