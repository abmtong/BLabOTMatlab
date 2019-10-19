function [out, outraw] = sfkk(con, inOpts, verbose)

%combine kdfsfind and kvxfit
%keep steps that were good by kvxfit and match to one from kdfsfind

%if con is a cell, change to batch ver.
if iscell(con)
    if nargin == 1
        [out, outraw] = cellfun(@(x) sfkk(x), con, 'Un', 0);
    elseif nargin == 2
        [out, outraw] = cellfun(@(x) sfkk(x, inOpts), con, 'Un', 0);
    elseif nargin == 3
        [out, outraw] = cellfun(@(x) sfkk(x, inOpts, verbose), con, 'Un', 0);
    end
    
    %Xform out into one matrix
    out = cellfun(@(x) x', out, 'Un', 0);
    out = [out{:}]';    
    return
end


%Options
opts.fil = {[], 5}; %Params for @windowFilter
opts.kvopts = {single(5)}; %K-V params {pf, nsteps, verbose}
opts.kdfopts = {.1, 1}; %kdf params {dy, ysd}
opts.maxdist = 2.5; %Maximum distance betwen kdf and kv steps
opts.Fs = 2500; %Sampling frequency, i.e. conversion from pts to time

if nargin > 1 && ~isempty(inOpts)
    opts = handleOpts(opts, inOpts);
end

if nargin < 3
    verbose = 0;
end

%Filter
conF = windowFilter(@mean, con, opts.fil{:});

%do K-V
[in, me, tr] = AFindStepsV5(conF, opts.kvopts{:});

%do K-V counterfit
kvxtf = kvxfit(in, me, conF);
%Also, make negative steps fail the criterion
% Define the 'owner' of the neg. step as the second dwell
kvxtf = kvxtf & -diff([inf me]) < 0;

%do kdf fit
kdfpos = kdfsfind(con, opts.kdfopts{:});

%kdfpos is sorted, but we want reverse sort
kdfpos = fliplr(kdfpos);

%Find nearest index in me for every value in kdfpos
nkdf = length(kdfpos);
kdind = zeros(1,nkdf);
mindist = zeros(1,nkdf);
for i = 1:nkdf
   [mindist(i), kdind(i)] = min( abs( kdfpos(i) - me ) );
end

%Below is useful if we sort thru kv steps, but we sort thru kdf steps
% %Convert this array of indicies to logical, so we can & with kvxtf
% kdtf(kdind) = true;
% %Validate dwells as those that pass both judgments
% ok = kdtf & kvxtf & mindist < opts.mindist;
% ok2 = ok(1:end-1) & ok(2:end);

distok = mindist < opts.maxdist;

%Collect for intact dwelltimes, bursttimes, step sizes
len=length(kdfpos)-1;
dwts = nan(1,len); %Real KV dwell
dwtfs = nan(1,len); %'Full dwell', distance between burst ends (time of dw + bu)
burkv = nan(1,len); %Burst size K-V
burkdf = nan(1,len); %Burst size kdf

%Extract the indicies from kv that match kdf, for ease
inkdf = in(kdind);
mekdf = me(kdind);

%For each step found in kdf, check if kv was ok too and extract
for i = 1:len
    %Check that the two steps in question are close to KV steps
    if distok(i) && distok(i+1)
        %And that those are ok in the kv frame
        if kvxtf(kdind(i)) && kvxtf(kdind(i+1))
            %If so, collect stats
            dw = in(kdind(i)+1) - inkdf(i);
            dwf = inkdf(i+1) - inkdf(i);
            bukv = mekdf(i+1) - mekdf(i);
            bukdf = kdfpos(i+1) - kdfpos(i);
            
            dwts(i) = dw/opts.Fs;
            dwtfs(i) = dwf/opts.Fs;
            burkv(i) = bukv;
            burkdf(i) = bukdf;
        end
    end
end

isn = isnan(dwts);
dwts = dwts(~isn);
dwtfs = dwtfs(~isn);
burkv = burkv(~isn);
burkdf = burkdf(~isn);

outraw.isn = isn;
outraw.opts = opts;
outraw.kv = {in me tr};
outraw.kdf = kdfpos;
outraw.dwts = dwts;
outraw.dwtfs = dwtfs;
outraw.burkv = burkv;
outraw.burkdf = burkdf;

out = [outraw.dwts; outraw.dwtfs; outraw.burkv; outraw.burkdf]';

if verbose
%Plot trace and fit, coloring by if step is good or not
    figure Name KVxfit
    plot(con), hold on
    [xx,yy] = ind2lin(in,me);
%     cc = repmat(outraw, [2 1]);
    cc = cc(:)';
    cc = double(cc);
    surface([xx;xx],[yy;yy],zeros(2,length(xx)),[cc;cc], 'Edgecol', 'interp', 'LineWidth',1)
    colormap([1 0 0; 0 1 0]);
    for i = 1:nstep-1
        text(in(i+1), mean(me(i:i+1)), sprintf('%0.3f', diff(me(i:i+1))))
    end
end


