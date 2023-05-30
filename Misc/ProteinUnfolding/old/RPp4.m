function out = RPp4(inst, inOpts)
%Calc refolding transition path histogram

%Rough rip detection opts
opts.ripfil = 200; %Filter for rough KV, should be >> opts.fil
opts.frng = [3 30];

% opts.fil = 20; %Filter (smooth, dont downsample)
% opts.meth = 1; %TP method
opts.wid = [200 200]; %Pts to take on each side of the rip

opts.pwlcc = 0.38*127; %Protein size (nm)
% opts.pwlcfudge = 1; %Protein size offset, nm

opts.verbose = 1; %Debug plots

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Will detect transition by fitting a monotonic trace with 3 intermediates
%Create model
mdl.mu = linspace(opts.pwlcc(1), 0, 5);
mdl.sig = 10; %How to deal with differing noise? . Sig doesn't really matter, so let's just choose one, big so no underflow
mdl.dir = 1;
mdl.trnsprb = [0 1e-10];

len = length(inst);
tpcrp = cell(1,len);
for i = 1:len
    %Get protein contour
    tmp = inst(i);
    %Extract trace, just retracting part
    yy = tmp.conpro( tmp.retind:end );
%     ff = tmp.frc( tmp.retind:end );
    %Could crop further (e.g. by force) for runtime
    
    %Filter
%     yf = forcefilter(yy, ff, opts.fil);
    
    %Find refolding using KV
    %First get a guess by downsampling
    yf = windowFilter(@mean, yy, [], opts.ripfil); %Lets just filter and decimate
    in0 = AFindStepsV4(yf, 1, 1, 0); %in0 is [1 step_loc length(yf)]
    %Convert to original index
    refind0 = in0(2)*opts.ripfil + tmp.retind -1; 
    
    %Get a neighborhood around this point...
    
    %And redo with smoothing
    yy2 = tmp.conpro( refind0 + (-5*opts.ripfil : 5*opts.ripfil));
    %Crop edge ripfil points
    yy2 = yy2(opts.ripfil+1:end-opts.ripfil);
    yf2 = windowFilter(@mean, yy2, ceil(opts.ripfil/2), 1);
    in1 = AFindStepsV4(yf2, 1, 1, 0); %in0 is [1 step_loc length(yf)]
    refind = in1(2) + refind0 - 4* opts.ripfil;
    
    
    
    %Save
    inst(i).refind = refind;
    
    %Fit use Viterbi algorithm
%     tr = fitVitterbiV3(yf, mdl);
    
    %
    
    
    
    %KV doesnt seem to work: noise too strong
%     % Crop to force range
%     ki = find( (1:length(tmp.frc)) > tmp.retind & tmp.frc < opts.frng(2), 1, 'first') :  find((1:length(tmp.frc)) > tmp.retind & tmp.frc > opts.frng(1), 1, 'last');
%     ki(ki < tmp.retind) = []; %Only consider retraction cycle cycle
%     % and filter
%     conf = windowFilter(@mean, yy(ki), [], opts.ripfil);
%     %Find one step
%     refind = AFindStepsV4(conf, 0, 1, 0);
%     %ripind is [1 step_loc length(conf)], convert to original indicies.
%     refind = (refind(2)-1) * opts.ripfil + ki(1);
    
    
end

out = inst;