function [out, outp] = procFran_PFVv2(inst, inOpts)
%Calculate pause-free velocity for nucleosome crossings
% Also calculate pause durations over certain ranges
%Method: Calculate RTH, then use it to calc PFV (median of dwelltimes < x seconds) & pause times (crossing times)
% Basically, the same as procFran_PFV , method = 3

%Basic options
opts.tfpick = 1; %Use tfpick traces only
opts.tfcross =0; %Use tfcross traces only
opts.Fs = 800; %Sampling frequency

%Regions of interest for PFV / pauses
opts.rois = {[0 64*8] [542 688]}; %ROIs: e.g. ladder region, nuc region
opts.paus = [4 28 40 56 64]+543; %Pause locations of major Nuc pauses

%Options for calculating RTH (@sumNucHist)
opts.snhopts.binsz = 1;
opts.snhopts.verbose = 0;
opts.snhopts.fil = 100;
opts.snhopts.filfcn = @median; %Filter function

%PFV calc opts
opts.maxdw = 0.5; %s, crossing time that is 'definitely a pause', usually ~1s
% To calc PFV, take the 1bp crossing times, then take the median of times less than this value

%Crossing time calc opts
opts.pauwid = 2; %Take +- this many bp per pause.
opts.crosswid = 10; %Only count a pause as 'crossed' if it has moved past this many BP. Or use onlycross?
%  About this width, we should have '1bp resolution' from the ruler, however:
%   Nuc positioning might be +/- a few bp
%   On average we might be correct, but the noise of the trace is >1bp

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Set Fs for sum nuc hist
opts.snhopts.Fs = 800;

len = length(inst);
out = cell(1,len);
outp = cell(1,len);
nr = length(opts.rois);
np = length(opts.paus);
for i = 1:len
    tmp = inst(i);
    
    hei = length(tmp.drA);
    
    outtmp = nan(nr,hei); %PFV for each (region, trace)
    outtmpp= nan(np,hei); %Crossing time for each (location, trace)
    for j = 1:hei
        %Skip trace if not picked, if asked
        if opts.tfpick
            if ~tmp.tfpick(j)
                continue
            end
        end
        
        %Skip trace if it doesn't cross, if asked
        if opts.tfcross
            if ~tmp.tfc(j)
                continue
            end
        end
        
        
        %Extract data
        dat = tmp.drA{j};
%         pdd = tmp.pdd{j};
        
        %Calc per-trace RTH
        [rthy, rthx] = sumNucHist( dat, opts.snhopts );
        
        %For each ROI
        for k = 1:nr
            %Get current ROI
            roi = opts.rois{k};
            
            %Crop to range
            ki = rthx >= roi(1) & rthx <= roi(2);
            dw = rthy(ki);
            
            %Remove long dwells. i.e., attempt to cut the tail (pauses)
            dw(dw > opts.maxdw ) = nan;
            mdw = median(dw, 'omitnan');
            
            %                     outtmp(k,j) = 1/ prctile(dw, 5); %Take 5th percentile dwell... ?
            outtmp(k,j) = 1/mdw;
            %                     outtmp(k,j) = 1/mdw/log(2); %log(2) to convert median (1exp) to the rate constant?
            
        end
        
        %For each pause site
        for k = 1:np
            %Sum over range, plus some 
            
            %Get range
            roi = opts.paus(k) + [-1 1] * opts.pauwid;
            
            %Check if this trace has crossed
            if ~any(rthx >= (opts.paus(k) + opts.crosswid) )
                continue
%                 break %Assume paus is sorted. ?
            end
            
            %And sum over this region
            ki = rthx >= roi(1) & rthx <= roi(2);
            pp = sum( rthy(ki) );
            
            outtmpp(k,j) = pp;
            
        end
        
    end
    out{i} = outtmp;
    outp{i} = outtmpp;
    
end

%And plot: PFVs
nams = {inst.nam};
procFran_PFVplot(out, nams)

%And plot: k_n vs k_p
procFran_PFVplotp(out, outp, opts.paus, nams)


