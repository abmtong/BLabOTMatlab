function out = tpKdfTest(inst, inOpts)
%Input: output of RPp3bV2

opts.kdfsd = 2; %SD for kdf
opts.fil = 10; %Filter amount
opts.fmin = 8; %Minimum force
opts.kdfbinsz = .1; %KDF bin size
opts.kdfsdout = 1.5; %SD for kdf in output graph
opts.verbose = 0; %Show findpeaks output

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if opts.verbose
    figure
    ax = gca;
    hold (ax, 'on')
    plotind = 0;
    plotmax = 7;
end

%Lets just combine all traces together
tpsr = [inst.tpsr];
frip = [inst.frip];

len = length(tpsr);

outraw = cell(1,len);


for i = 1:len
    %Rejection criteria:
    %Force
    if opts.fmin > frip(i)
        continue
    end
    
    
    %Get this guy's tpsr
    yy = tpsr{i};
    
    %Filter
    yf = windowFilter(@median, yy, opts.fil, 1);
    
    %Trim NaN
    yf(isnan(yf)) = [];
    
    %Check for too short traces
    if length(yf) < 10
        continue
    end
    
    %Create kdf
    [ky, kx] = kdf( yf, opts.kdfbinsz, opts.kdfsd );
    
    %Find peaks
    [pks, lcs] = findpeaks(ky, kx);
    
    %Verbose: Show findpeaks
    if opts.verbose
        findpeaks(ky, kx)
        pause(0.5)
        plotind = plotind + 1;
        if plotind > plotmax
            plotind = 0;
            delete(ax.Children);
        end
    end
    
    
    %May need to accept/reject some peaks here
    
    outraw{i} = lcs;
    
end

%Then just bin outraw

alldat = [outraw{:}];
[hp, hx] = kdf(alldat, opts.kdfbinsz, opts.kdfsdout);

%Normalize to number of traces
nn = sum( ~cellfun(@isempty,outraw) );
hp = hp / nn;

% [hp, hx] = nhistc(alldat, 0.1); %Maybe kdf this too to make it look nice
figure, plot(hx, hp);

out = alldat;

