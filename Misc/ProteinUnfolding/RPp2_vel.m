function out = RPp2_vel(inst, inOpts)
%Part 2: Finds the rip and when the pull and retract switches over
%V2: convert to contour (XWLC guess) and find one step
% vel: Uses velocity thresholding to find rip/zip sites

%Input: trace inst = struct('frc', {force_data}, 'ext', {ext_data}, 'tpos', {trap_pos_data}
%Output: adds rip, retraction indicies to the struct

%Rip detection options
opts.ripfil = 10; %Filtering amount
opts.fmin = 5; %Only check for rips in this force range (removes issues with low force having higher noise)
opts.dwlcg = [50 900]; %DNA XWLC guess, [PL(nm) SM(pN)]
opts.sgp = {1 301}; %sgolay params for differentiation. sgp{2} should be ~TP duration (pts)

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
    
    %Filter frc
    frcf = windowFilter(@mean, tmp.frc, opts.ripfil, 1);
    
    %Find rip by converting to contour (via a guess) and measuring velocity
    con = tmp.ext ./ XWLC(tmp.frc, opts.dwlcg(1), opts.dwlcg(2));
    % Use filtered force to remove some fluctuation ?
%     con = tmp.ext ./ XWLC(frcf, opts.dwlcg(1), opts.dwlcg(2));
    
    %Filter con first
    conf = windowFilter(@mean, con, opts.ripfil, 1);
    
    %Velocity filter
    convel = sgolaydiff(conf, opts.sgp);
    % Note that this crops by (sgp{2}-1) /2 on each side, so add back as NaN
    convel = [nan(1, (opts.sgp{2}-1)/2) convel nan(1, (opts.sgp{2}-1)/2)]; %#ok<AGROW>
    
   
    %Fudge: find the extrema of force * contour [to remove low force fluctuations]
    convel = convel .* frcf;
    % Weirdly (or not weirdly? this levels out the noise)
    
    % Crop to force range
    ki = find(frcf > opts.fmin, 1, 'first') : find(frcf < opts.fmin, 1, 'last');
%     ki(ki > retind) = []; %Only consider pulling cycle
    %Crop and filter
    convelc = windowFilter(@mean, convel(ki), [], opts.ripfil);
    
    
    
    %Find highest (rip) and lowest (zip) pt in this range
    [~, maxi] = max(convelc);
    [~, mini] = min(convelc);
    
    
    %Convert rip/zip pt to original indicies
    ripind = round( (maxi-1) * opts.ripfil + ki(1) ) ;
    refind = round( (mini-1) * opts.ripfil + ki(1) ) ;
    
    %Just save the locations of the rip and pull
    inst(i).ripind = ripind;
    inst(i).refind = refind;
    inst(i).retind = retind;

    %Can extend to finding multiple rips probably by gaussian filtering df and taking best N @findpeaks results
end
out = inst;

if opts.debug
    %plot pre-rip and retraction regions
    figure Name Pre-Rip, hold on, cellfun(@(x,y,z)plot(windowFilter(@mean,x(1:z), opts.ripfil, 1), windowFilter(@mean, y(1:z), opts.ripfil, 1)), {inst.ext}, {inst.frc}, {inst.ripind})
    figure Name Retract, hold on, cellfun(@(x,y,z)plot(windowFilter(@mean,x(z:end), opts.ripfil, 1), windowFilter(@mean,y(z:end), opts.ripfil, 1)), {inst.ext}, {inst.frc}, {inst.retind})
end