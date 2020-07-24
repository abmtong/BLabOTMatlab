function Dwells = AL_BurstSize_SIC_FindSteps(T,Y,F,NumDwells)
% Find steps by iteratively picking partitions that maximally improve the SIC.
%
% USE: Dwells = BurstSize_SIC_FindSteps(T,Y,F,NumDwells)
%
% See note below on picking the penalty for overfitting.
%
% Antony Lee, 04/03/2014 -- complete rewrite of Gheorghe Chistol's code.

    csy = [0, cumsum(Y')];
    csy2 = [0, cumsum(Y' .^ 2)];

    function v_ = v(start, stop)
    % Compute the total squared deviation in Y(start:stop).
        v_ = (csy2(stop + 1) - csy2(start)) - ...
            (csy(stop + 1) - csy(start)) ^2 / (stop - start + 1);
    end

    function [dsv, idx] = best_cut(start, stop)
    % Intra-step total squared deviation decrease and position of best
    % partition in Y(start:stop).
        if stop > start + 1
            vs = arrayfun(@(i) v(start, i - 1) + v(i, stop),...
                (start + 1) : (stop - 1));
            [bsv, idx] = min(vs);
            dsv = v(start, stop) - bsv;
            idx = idx + start;
        else
            dsv = 0;
            idx = -1;
        end
    end

    n = numel(Y);
    % Replace 1/n by a larger penalty (Gheorghe suggests 3-4/n) to penalize
    % overfitting more.
    cutoff = 1 - n ^ (- 1 / n);
    starts = [1, n];
    sv = v(1, n);
    [dsv_, idx_] = best_cut(1, n);
    % Total squared variation decreases and indexes of the best partition points
    % for each step.
    dsvs = [dsv_];
    idxs = [idx_];

    while true
        % Find the step for which partitioning improves the SIC the most.
        [dsv, j] = max(dsvs);
        if dsv / sv < cutoff
            % Stop because overfitting penalty is now larger than the SIC gain.
            break
        end
        % Accept the step.
        % Update total squared variation and indices.
        sv = sv - dsv;
        s_this = idxs(j);
        starts = [starts(1:j), s_this, starts(j+1:end)];
        if size(starts) > NumDwells
            % Stop because requested number of dwells has been reached.
            break
        end
        % Find the best cutting points for the newly created steps.
        [dsv_, idx_] = best_cut(starts(j), s_this - 1);
        dsvs(j) = dsv_;
        idxs(j) = idx_;
        [dsv_, idx_] = best_cut(s_this, starts(j + 2));
        dsvs = [dsvs(1:j), dsv_, dsvs(j+1:end)];
        idxs = [idxs(1:j), idx_, idxs(j+1:end)];
    end
    
    DwellInd = arrayfun(@(i) ...
        struct('StartInd', starts(i), ...
               'FinishInd', starts(i + 1) - 1, ...
               'Mean', (csy(starts(i + 1)) - csy(starts(i))) / ...
                       (starts(i + 1) - starts(i))), ...
        1 : (numel(starts) - 1));
    Dwells = BurstSize_SIC_FindSteps_OrganizeResults(T,Y,F,DwellInd);
end
