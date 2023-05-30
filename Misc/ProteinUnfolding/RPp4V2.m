function out = RPp4V2(inst, inOpts)
%Find refolding point

%Rough rip detection opts
% Algorithm: Filter, then find first crossing of a point 
opts.ripfil = 200; %Filter for rough KV, should be >> opts.fil

% opts.ripwid = [200 200]; %Pts to take on each side of the rip, to refine rip loc?

opts.pwlcc = 0.38*127; %Protein size (nm)
opts.pwlccmult = 0.2; %Look for rip as first crossing of pwlcc * pwlccmult

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
% tpcrp = cell(1,len);
for i = 1:len
    %Get protein contour
    tmp = inst(i);
    %Extract retracting part of cycle
    yy = tmp.conpro( tmp.retind:end );
    
    %Filter
    yf = windowFilter(@mean, yy, opts.ripfil, 1);
    
    %Find first crossing
    ind = find(yf < opts.pwlcc * opts.pwlccmult , 1, 'first');
    
    %Refine guess by KV?
    
%     
%     %Find refolding using KV
%     %First get a guess by downsampling
%     
%     in0 = AFindStepsV4(yf, 1, 1, 0); %in0 is [1 step_loc length(yf)]

    %Convert to original index
     refind = ind + tmp.retind -1; 
    
%     %Get a neighborhood around this point...
%     
%     %And redo with smoothing
%     yy2 = tmp.conpro( refind0 + (-5*opts.ripfil : 5*opts.ripfil));
%     %Crop edge ripfil points
%     yy2 = yy2(opts.ripfil+1:end-opts.ripfil);
%     yf2 = windowFilter(@mean, yy2, ceil(opts.ripfil/2), 1);
%     in1 = AFindStepsV4(yf2, 1, 1, 0); %in0 is [1 step_loc length(yf)]
%     refind = in1(2) + refind0 - 4* opts.ripfil;
    
    %Save
    inst(i).refind = refind;
end

out = inst;