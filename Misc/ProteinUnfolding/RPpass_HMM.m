function out = RP_pass_HMM(inst, varargin)


opts.mu = [1 9.5 39.5]; %initial mu. Use 'known' values, from e.g. pass p3
opts.sig = 2; %SD noise
opts.fil = 20; %Filter amt for collecting TPs
opts.dsamp = 10; %Downsample amount for HMM
opts.pad = 200; %Pts to pad TPs by
opts.nhmm = 3; %Times to run HMM to converge

%Plotting options
opts.Fs = 25e3;
opts.binsz = 0.1; %binsz

if nargin > 1
    if length(varargin)>1
        inOpts = struct(varargin{:});
    else
        inOpts=varargin{1};
    end
    opts = handleOpts(opts, inOpts);
end

%Handle mu: sort and get ns
opts.mu = sort(opts.mu);
ns = length(opts.mu);
% So mu(1) is F, mu(end) is U

len = length(inst);
outraw = cell(4,len);
for i = 1:len
    %Take this data's conpro
    dat = inst(i).conpro;
    
    %Crop if it's from RP_hop
    if isfield(inst, 'retind');
        dat = dat( inst(i).retind+ round(opts.Fs*.02):end - round(opts.Fs*.02));
        % ^hardcoded mirror movement removal of ~20ms
        
    end
    
    %Filter. Filter data for HMM and collecting separately
    datF = windowFilter(@median, dat, opts.fil, 1);
    datFc = windowFilter(@median, dat, [], opts.dsamp);
%     datFc =datF(opts.dsamp:opts.dsamp:end);
    
    %Create HMM transition matrix. Only allow adjacent state jumps?
    
    %HMM
    hmmres = stateHMMV2(datFc, struct('mu', opts.mu, 'sig', opts.sig, 'verbose', 0));
    %Do a few times to converge
    for j = 2:opts.nhmm
        hmmres = stateHMMV2(datFc, setfield(hmmres, 'verbose', 0));
    end
    
    %Get state vector, tmp.fit
    tra = hmmres.fit;
    
    %Combine intermediate states together
    tra(tra >1 & tra < ns) = 2;
    %And set mu to state == 3
    tra(tra == ns) = 3;
    
    %Convert to trace index
    [ind, mea] = tra2ind(tra);
    
    %Un-downsample ind
    ind = ind * opts.dsamp; %Downsampling is done by dsamp:dsamp:end, so just mult by downsamp
    
    %Find transitions: UF FU FF UU
    strs = {[3 2 1] [1 2 3] [1 2 1] [3 2 3]};
    % I guess this only finds things with a visible intermediate. Ok?
    for j = 1:4
        %Find the transition that matches
        ii = strfind(mea, strs{j});
        
        %And extract them. Do hmm = when state==2 + pad
        hei = length(ii);
        tmp = cell(1, hei);
        for k = 1:hei
            %Get this region. Remember that ii is 
            ki = max(ind( ii(k) + 1 ) - opts.pad, 1) : min( ind( ii(k) + 2 ) + opts.pad, length(dat) );
            
            %Extract. Use the filtered version
            tmp{k} = datF(ki);
        end
        %Save
        outraw{j,i} = tmp;
    end
end
%Concatenate cell-of-cells of TPs to just one cell per type
out = cell(1,4);
for i = 1:4
    out{i} = [outraw{i,:}];
end


%And plot
fg = figure;
nams = {'Folding' 'Unfolding' 'Partial Unfolding' 'Partial Folding'};
%Create bottom graph for hist.s
ax2 = subplot(2,1,2);
hold(ax2, 'on')
lgn = cell(1,4);
for i = 1:4
    %Get data
    tmp = out{i};
    
    %Plot TPs on top
    ax = subplot(2,4, i );
    title(ax, nams{i})
    hold(ax,'on')
    cellfun(@(x) plot( ax, (1:length(x))/opts.Fs, x), tmp);
    
    %And plot hist on bottom
    [p, x] = nhistc([tmp{:}], opts.binsz);
    plot(ax2, x,p)
    lgn{i} = sprintf('%s, N=%d', nams{i}, length(tmp));
end
legend(ax2, lgn);