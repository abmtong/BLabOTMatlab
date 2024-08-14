function out = tpHMM(tps, varargin)

%Input: Output of RPp3bV2, a struct with field 'tpsr' containing transition paths


%Fit to HMM (nint+2 states, where n = num_intermediates)
opts.mu = [0 10 40]; %Mu guess for HMM, [F I U]
opts.sig = 2; %Set sig for HMM: since we're filtering
opts.nhmm = 3; %Number of iterations of HMM to converge
opts.trns = -1; %Transition to look for, 1 = folding or -1 = unfolding
opts.dsamp = 5; %Downsample for HMM

opts.kdfsd = 0.5; %KDF SD
%Does not work for multiple intermediates yet, too much work/weirdness...

opts.normmu = 1; %Normalize by mu: i.e., put U and F = 0 and 1

if nargin > 1
    if length(varargin)>1
        inOpts = struct(varargin{:});
    else
        inOpts = varargin{1};
    end
    opts = handleOpts(opts, inOpts);
end

nst = length(opts.mu);

len = length(tps);

%Create HMM index pattern search
switch opts.trns
    case 1 %Folding, so U>I>F
        trns = length(opts.mu):-1:1;
    case -1 %Unfolding, so F>I>U
        trns = 1:length(opts.mu);
        
end

%Create output matrix: cols [mus, lifetimes]
out = nan(len, 2*nst);
for i = 1:len
    tmp = tps{i};
    
    %Filter for HMM, if requested
    datFc = windowFilter(@median, tmp, [], opts.dsamp);
    %Do HMM
    hmmres = stateHMMV2(datFc, struct('mu', opts.mu, 'sig', opts.sig, 'verbose', 0));
    %Do a few times to converge
    for j = 2:opts.nhmm
        hmmres = stateHMMV2(datFc, setfield(hmmres, 'verbose', 0));
    end
    tra = hmmres.fit;
    [ind, mea] = tra2ind(tra);
    
    %Save means
    out(i, 1:nst) = hmmres.mu;
    
    %Find the last transisiton
    ii = strfind(mea, trns);
    if ii
        %Document duration
        dur = ind( ii(end) + (1:3) ) - ind( ii(end) + (0:2) );
        out(i, nst+1 :end) = dur;
    end

end

%And plot

%Let's scatter mu vs dur? separate into 3 colors?

if ~opts.normmu
    figure,
    ax1 = subplot(3,1,[2 3]);
    hold on
    for i = 1:nst
        scatter(out(:,i), out(:,i+3))
    end
    legend({'F' 'I' 'U'})
    xlabel('Position (nm)')
    ylabel('Lifetime (pts)')
    
    %Then kdf pos on top
    ax2 = subplot(3,1,1);
    hold on
    for i = 1:nst
        [y,x] = kdf(out(:,i),.1,opts.kdfsd);
        plot(x,y);
    end
    % legend({'F' 'I' 'U'})
    
    %And linkaxes
    linkaxes([ax1, ax2], 'x');
    
else
    figure,
    ax1 = subplot(3,1,[2 3]);
    hold on
    inorm = (out(:,2) - out(:,1))./( out(:,3)-out(:,1));
    scatter( inorm , out(:,nst+2))
    legend({'I normalized'})
    xlabel('Position (% unfolded)')
    ylabel('Lifetime (pts)')
    
    %Then kdf pos on top
    ax2 = subplot(3,1,1);
    hold on
    for i = 1:nst
        [y,x] = kdf(inorm,.1/50,opts.kdfsd/50);
        plot(x,y);
    end
    % legend({'F' 'I' 'U'})
    
    %And linkaxes
    linkaxes([ax1, ax2], 'x');
end























