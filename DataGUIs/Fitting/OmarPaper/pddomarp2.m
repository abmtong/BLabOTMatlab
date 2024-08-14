function out = pddomarp2(inst, inOpts)
%Now fit to a sum of exponentials

%Collect the steps you want to use
% Crop start/end with ezCropGUI
% ROI: have a few different ROI switches for per-trace ROIs (slow / super slow regions)

%And fit to a sum of 1exps with fitnexp

opts.Fs = 1000;
% opts.roi = [0 58*8]; %Default ROI is just the repeats region
opts.roi = [-inf inf];
opts.edgetrim = 5; %Throw away this many steps on the start/end. Use at least a few, to remove arrest pause (if any).
opts.minsz = 2; %Minimum step duration, pts (remove shorter)
opts.cropstr = []; %Crop to use, as the fieldname (e.g. 'crop' or 'cropslow')

%fitnexp options
opts.fneopts.prcmax = 100; %Trim longest ?
opts.fneopts.verbose = 1;
opts.fneopts.n = 3;
opts.fneopts.xrange = [0 inf] ;
opts.fneopts.fitlast = 0;
opts.fneopts.fitlastxmin = 3;

opts.ncrop = 5; %Crop the longest N pts? If mle doesn't behave

%Plots n such
opts.verbose = 1; %Plot traces, too

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


%Handle batch
if length(inst) > 1
    out = arrayfun(@(x) pddomarp2(x, opts), inst);
    return
end

len = length(inst.drA);
dws = cell(1,len);
datraw = cell(1,len);
for i = 1:len
    %Crop fit trace from pdd
    tra = inst.pdd{i};
    
    %Skip empty?
    
    %Crop if asked
    if ~isempty(opts.cropstr)
        %Crop if it exists
        if isfield(inst, opts.cropstr) && ~isempty(inst.(opts.cropstr)) && ~isempty(inst.(opts.cropstr){i})
            tra = tra(inst.(opts.cropstr){i}(1):inst.(opts.cropstr){i}(2));
        else
            %If there's no crop, skip
            continue
        end
    end
    
    
    %Crop extra if asked
    
    %Convert to ind/mea
    [ind, mea] = tra2ind(tra);
    
    %Calculate dwell time
    dw = diff(ind);
    
    %Throw away a few edge steps
    dw =  dw(1+opts.edgetrim : end-opts.edgetrim);
    mea = mea(1+opts.edgetrim : end-opts.edgetrim);
    ind = ind(1+opts.edgetrim : end-opts.edgetrim);
    ind = ind - ind(1)+1; %Shift back to zero
    
    %Apply ROI
    ki = mea >= opts.roi(1) & mea <= opts.roi(2);
    dw = dw(ki);
%     mea = mea(ki);
    
    %Save variables
    datraw{i} = ind2tra(ind, mea);
    dws{i} = dw;
end

%Combine
dws = [dws{:}];

%Junk certain tiny steps
dws( dws < opts.minsz ) = [];

%Crop longest few steps
if opts.ncrop > 0
    dws = sort(dws, 'descend');
    dws = dws(opts.ncrop+1:end);
end

%Apply Fsamp
dws = dws/opts.Fs;

%Fit to exp
[ft, ftraw] = fitnexp_hybridV3(dws, opts.fneopts);

%Get sum of a_i's
asum = sum(ft(1:2:end));

%Grab the CIs from the ft
ft = [ft; ftraw.mfcis{length(ft)/2}];

%Apply a normalization
ft(:,1:2:end) = ft(:,1:2:end) / asum;

%Sort by k
ft = reshape(ft, 4, []);
[~, si] = sort(ft(3,:), 'descend');
ft = ft(:,si);
ft = reshape(ft, 2, []);

%And just take the answer and save. Maybe reshape, but eh.
inst.(['exp' opts.cropstr]) = ft;
inst.(['exp' opts.cropstr 'raw']) = ftraw;

%Plot if asked
if opts.verbose
    figure('Name', sprintf('pddomarp2, data: %s, crop: %s', inst.nam, opts.cropstr));
    title(sprintf('Data: %s, Crop: %s', inst.nam, opts.cropstr))
    hold on
    cellfun(@(x) plot( (1:length(x))/opts.Fs, x ), datraw)
    dsampFig([],100)
end

out = inst;













