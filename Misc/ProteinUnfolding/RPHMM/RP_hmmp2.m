function out = RP_hmmp2(inst, trns, inOpts)
%Grab certain transitions from HMM and 

%input: trns is the transition to look for, e.g. state 2>3>4 would be trns = [2 3 4]
%If you want multiple, supply as cell. Also supply as cell to plot

opts.dsamp = 10; %Need this to un-downsample the HMM. Use the same value as in p1

opts.fil = 20; %Filtering for the un-downsampled HMM
opts.filfcn = @median;
opts.binsz = 0.2;

opts.rmedge = 1; %Remove the edges of the transition, e.g. for 2-3-4 just take the 3 from this
opts.pad = 50; %Pad edges by this much

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

if iscell(trns)
    outraw = cellfun(@(x) RP_hmmp2(inst, x, opts), trns, 'Un', 0);
    len = length(trns);
    
    figure Name RPhmmp2, hold on
    
    nt = zeros(1,len);
    for i = 1:length(trns)
        tmp = [outraw{i}{:}];
        nt(i) = length(tmp);
        [p, x, ~, n] = nhistc( [tmp{:}], opts.binsz );
        
        %Either plot prob or N... maybe do N
        plot(x,n)
%         plot(x,p)
    end
    legend( cellfun(@(x,y) sprintf('Transition: %s (%d instances)', num2str(x), y), trns, num2cell(nt), 'Un', 0) )
    
    
    return
end


len = length(inst);
out = cell(1,len);
for i = 1:len
    %Get data
    tmp = inst(i);
    
    %Filter
    datF = windowFilter(@median, tmp.conpro, opts.fil, 1);
    
    %Search for this transition
    tr = tmp.hmmfit;
    [in, me] = tra2ind(tr);
    ist = strfind(me, trns);
    
    
    %Get boundaries, un-downsample too
    if opts.rmedge
        st = (in(ist+1)-1) * opts.dsamp + 1 - opts.pad;
        en = (in(ist+length(trns)-1)) * opts.dsamp - 1 + opts.pad;
    else    
        st = (in(ist)-1) * opts.dsamp + 1 - opts.pad;
        en = (in(ist+length(trns))) * opts.dsamp - 1 + opts.pad;
    end
    
    %Coerce
    st = max(st,1);
    en = min(en, length(datF));
    
    %Grab range
    out{i} = arrayfun(@(x,y) datF(x:y), st, en, 'Un', 0);
end

