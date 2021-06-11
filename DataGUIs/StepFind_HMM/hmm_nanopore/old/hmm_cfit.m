function out = hmm_cfit(tr, seq, mugu, tofit)
%Try a curvefitting approach to hmm?

%tofit determines what gets optimized: dwells and means (0) or just dwells (1). Just means is ind2mea(ind, tra);

% lsqopts = optimoptions('lsqnonlin', 

if tofit == 0 %Both
    nlen = length(tr);
    if ischar(seq)
        seq =seq2st(seq);
    end
    [tmp, ~, muref] = unique(seq);
    ndw = length(muref);
    mugucrp = mugu(tmp);
    %Fitting parameters is x0 = [dwell_lengths, mus];
    % dwell_lengths is relative
    % mus is only the ones in the trace, unique'd (see above) : the mus in sequence order is mus(muref)
    %muref translates mu list to mu's in trace order
    xg = [ones(1,ndw) mugucrp];
    lb = [zeros(1,ndw) zeros(size(mugucrp))];
    ub = [inf(1,ndw), 100*ones(size(mugucrp))];
    trafcn = @(x0) ind2tra( [1 round(cumsum(x0(1:ndw))/sum(x0(1:ndw))*nlen )], x0(ndw+muref) );
    fitfcn = @(x0) (trafcn(x0) - tr);
    fit = lsqnonlin(fitfcn, xg, lb, ub);
elseif tofit == 1 %Just dwells
    nlen = length(tr);
    if ischar(seq)
        mus = seq2st(seq, mugu);
    else
        mus = mugu(seq);
    end
    ndw = length(mus);
    trafcn = @(x0) ind2tra( [1 (1+ceil(cumsum(x0(1:ndw))/sum(x0(1:ndw))*(nlen-1)) )], mus );
    fitfcn = @(x0) (trafcn(x0) - tr);
    %Generate guess by monte carlo
    scr = inf;
    for i = 1:1e6
        %Generate a random set of dw's
        g = exprnd(1, 1, ndw);
        newscr = sum(fitfcn(g).^2);
        if newscr < scr
            scr = newscr;
            xg = g;
        end
    end
    lb = zeros(1,ndw);
    ub = inf(1,ndw);
    fit = lsqnonlin(fitfcn, xg, lb, ub);
else
    error('Invalid tofit %d', tofit)
end
out = trafcn(fit);
%Plot fit
figure, plot(tr, 'Color', [.7 .7 .7]); hold on, plot(trafcn(fit))