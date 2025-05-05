function inst = RP_hmmp1(inst, inOpts)

%HMM the conpro field

opts.dsamp = 10;
opts.filfcn = @median;
opts.maxiter = 2;
% opts.nst = 3;
% opts.mu0 = [1.3 10.5 37.4];
opts.nst = 4;
opts.mu0 = [1.3 10.5 25 36];
opts.trnsprb = 1e-2;
opts.verbose = 1;
if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
outraw1 = cell(1,len);
outraw2 = cell(1,len);
outraw3 = cell(1,len);
for i = 1:len %Can for or parfor here
    tmp = inst(i);
    y = windowFilter(opts.filfcn, tmp.conpro, [], opts.dsamp);
    if isempty(y)
        continue
    end
    
    a0 = ones(opts.nst)*opts.trnsprb + diag(ones(1,opts.nst) * (1-opts.nst*opts.trnsprb));
    st0 = struct('ns', opts.nst, 'mu', opts.mu0, 'a', a0, 'verbose', opts.verbose);
    rawhmm = cell(1,opts.maxiter);
    rawhmm{1} = stateHMMV2_sig(y, st0);
    for j = 2:opts.maxiter
        rawhmm{j} = stateHMMV2_sig(y, setfield(rawhmm{j-1}, 'verbose', opts.verbose) ); %#ok<SFLD>
    end
    rawhmm = [rawhmm{:}];
    
    %Choose winner
    [~, mi] = max( [rawhmm.logprob] );
    mdl = rawhmm(mi);
    tr = mdl.fit;
    mu = mdl.mu;
    
    if opts.verbose
        %Check
        figure Name CheckX
        hold on
        [~,x,~,p] = nhistc(y, 0.2);
        plot(x,p,'k')
        stds = zeros(1,opts.nst);
        for j = 1:opts.nst
            dat = y( tr == j );
            stds(j) = std(dat);
            [~,x,~,p] = nhistc(dat, 0.2);
            plot(x,p)
            line( mu(j) * [1 1], max(p) * [0 1], 'Color', 'k')
        end
        legend([{'Sum'} arrayfun(@(x,y) sprintf('State %d (std=%0.2f)', x,y), 1:opts.nst, stds, 'Un', 0)])
        
        figure Name CheckT
        hold on
        [in, me] = tra2ind(tr);
        dw = diff(in);
        for j = 1:opts.nst
            ccx = sort(dw( me == j), 'descend');
            ccy = (1:length(ccx))/length(ccx);
            plot(ccx, ccy)
        end
        set(gca, 'YScale', 'log')
        xlim([0 prctile(dw, 99)]);
        ylim( [2*opts.nst/length(dw) 1])
        legend( arrayfun(@(x,y) sprintf('State %d (mu=%0.2f)', x,y), 1:opts.nst, mu, 'Un', 0))
    end
    
    %Save
    outraw1{i} = tr;
    outraw2{i} = mu;
    outraw3{i} = mdl;
end

[inst.hmmfit] = deal(outraw1{:});
[inst.hmmmu] = deal(outraw2{:});
[inst.hmm] = deal(outraw3{:});