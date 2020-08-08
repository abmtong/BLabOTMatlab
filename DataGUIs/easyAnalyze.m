function inOpts = easyAnalyze(data, inOpts)

if nargin < 2
    inOpts = easyAnalyzeOpts;
end

%Make data a cell
if ~iscell(data)
    data = {data};
end

%Filter data
dataF = cellfun(@(x) windowFilter(@mean, x, inOpts.fwid, inOpts.fdec), data, 'Un', 0);

switch inOpts.Method
    case 'Pairwise'
        fils  = [3 5 10 25];
        binsz = inOpts.binsz;
        pfils = [1 5 10] * .1/binsz;
        pfils = round(pfils);
        %Plot PWD
        sumPWDV1bmatrix(data, fils, pfils, binsz)
    case 'Stepfinding: K-V'
        BatchKV(dataF, inOpts.kvpf)
    case 'Stepfinding: KDF'
        %kdfsfind uses inputParser instead of opts, welp. Should just pick one
        kdfsfind(data, 'fpre', {inOpts.fwid, inOpts.fdec}, 'binsz', inOpts.binsz, 'kdfsd', inOpts.ksd, 'kdfmpp', inOpts.mpp);
    case 'Stepfinding: HMM'
        len = length(data);
        hmm = cell(1,len);
        %Do stepfinding: use parfor if requested
        bsz = inOpts.binsz;
        if inOpts.parpool
            parfor i = 1:len
                hmm{i} = findStepHMMv2(struct('tr', data{i}, 'binsz', bsz));
            end
        else
            hmm = cellfun(@(x)findStepHMMv2(struct('tr', x, 'binsz',inOpts.binsz)), data, 'Un', 0);
        end
        %Collect a's and plot them together
        aa = cellfun(@(x) x.a, hmm, 'Un',0);
        %Pad aa to make them equal length
        alen = cellfun(@length, aa);
        amax = max(alen);
        aa = cellfun(@(x,y) [zeros(1,(amax-y)/2)  x  zeros(1,(amax-y)/2)], aa, num2cell(alen), 'Un', 0);
        %When summing aa, weight by n pts
        tlen = cellfun(@length, data);
        %Convert a to matrix, weight with bsxfun, sum to add
        asum = sum(bsxfun(@times, reshape([aa{:}], amax, []), tlen), 2)';
        asum((amax+1)/2) = 0;
        xx = ((1:amax)-(amax-1)/2)*inOpts.binsz;
        figure, plot(xx, asum);
    case 'N-state HMM'
        hmm = cellfun(@(x)stateHMMV2(x, struct('ns',inOpts.ns)), data, 'Un', 0);
        %Collect a's and plot them together
        aa = cellfun(@(x) x.finish.a, hmm, 'Un',0);
        %Pad aa to make them equal length
        alen = cellfun(@length, aa);
        amax = max(alen);
        aa = cellfun(@(x) [zeros(1,(amax-alen)/2)  x  zeros(1,(amax-alen)/2)], 'Un', 0);
        %When summing aa, weight by n pts
        tlen = cellfun(@length, data);
        %Convert a to matrix, weight with bsxfun, sum to add
        asum = sum(bsxfun(@times, reshape([aa{:}], amax, []), tlen), 2)';
        asum((amax+1)/2) = 0;
        xx = ((1:amax)-(amax-1)/2)*inOpts.binsz;
        figure, plot(xx, asum);
    case 'Velocity distribution'
        vdist(data, inOpts);
    otherwise
        warning('Loaded inOpts method %d is invalid', src.Value)
end



