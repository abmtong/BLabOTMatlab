function out = ppKVv3(data, fdata, inOpts)
%V3: Modular now
% This just sorts into tloc and non-tloc sections

if nargin < 2 || isempty(fdata)
    warning('Forces for %s not supplied, setting all forces to 10', inputname(1))
    fdata = cellfun(@(x) 10 * ones(size(x)), data, 'uni', 0);
end

%Troubleshooting verbose flag
opts.verbose.traces = 0; %plot every N traces, to show tl/bt sections
%Filter opts: {filter factor, decimation factor}; args 3 and 4 of @windowFilter
opts.filwid = {[] 5};
%K-V penalty factor
opts.kvpf = single(8);
%Sampling frequency, to convert pts to time
opts.Fs = 2500;

%Minimum dContour for an event to be a bt
opts.minlen = 5;
%Need N transloc. steps to become a non-bt again. Assumes bt events aren't clustered
opts.mintr = 3;
%Need N bt steps to be considered a bt
opts.minbt = 0;
    
if nargin >= 3
    opts = handleOpts(opts, inOpts);
end

% %Filter the inputs
dfil = cellfun(@(x)windowFilter(@mean, x, opts.filwid{:}), data, 'un', 0);
ffil = cellfun(@(x)windowFilter(@mean, x, opts.filwid{:}), fdata, 'un', 0);

%Do K-V stepfinding
[kvi, kvm, kvt] = BatchKV(dfil, opts.kvpf);
%kvi = index of step start, kvm = height of step i, kvt = fit staircase
ntr = length(kvi);
%Get step sizes by K-V
kvssz = cellfun(@diff, kvm, 'Un', 0);
%Define backtracks as positive steps
isbt = cellfun(@(x) x > 0, kvssz, 'Un', 0);
%Gather here
outtra = {};
outind = {};
outmea = {};
outfrc = [];
outtfbt = [];
for i = 1:ntr
    len = length(kvi{i});
    %start of backtracks is isbt 0 -> 1
    indSta = find(diff([0 isbt{i} 0]) == 1);
    %end of backtracks is isbt 1 -> 0
    indEnd = find(diff([0 isbt{i} 0]) == -1); 
    %Find number of tloc steps between backtrack events
    dws = indSta(2:end) - indEnd(1:end-1);
    tooshort = dws <= opts.mintr;
    %Join together bt events separated by too short a time
    indEnd([tooshort false]) = [];
    indSta([false tooshort]) = [];
    
    %Find length in steps of bt events
    nstp = indEnd - indSta;
    toofewsteps = nstp < opts.minbt;
    %And remove
    indEnd(toofewsteps) = [];
    indSta(toofewsteps) = [];
    
    %Rename K-V stuff 
    kin = kvi{i};
    kme = kvm{i};
    %Loop variables
    j = 1; %Index of K-V step
    ii = 0; %Index of ind sta/end [which we're currently on]
    tfbt = 0; %Whether we're currently in bt run or not
    while j < len-1 %Go until we run out of indSta or indEnd. Use while so we can 'skip ahead'
        %Find next indSta or indEnd, depending if we're bt or not
        ii = ii + ~tfbt; %Increment ii if we were tl (look for next indSta)
        %If there's no more indicies, set to end
        if ii > length(indEnd)
            nxt = len-1;
        elseif tfbt
            %In bt now, look for next indEnd
            nxt = indEnd(ii);
        else
            %In tloc now, look for next indSta
            nxt = indSta(ii);
        end
        %Collect info on this [j:nxt] section
        ind = kin(j:nxt+1);
        mea = kme(j:nxt);
        frc = median(ffil{i}(ind(1):ind(end)));
        
        %Apply length minimum here
        if tfbt && mea(end)-mea(1) < opts.minlen
            %This is not a bt, so set to tl
            tfbt = 0;
            continue
        end
        
        %Add to cell array. Adjust for decimation factor here
        ind = ind * opts.filwid{2};
        outtra = [outtra {data{i}(ind(1):ind(end))}]; %#ok<*AGROW>
        outind = [outind {ind-ind(1)+1}];
        outmea = [outmea {mea}];
        outfrc = [outfrc frc];
        outtfbt = [outtfbt tfbt];
        %Toggle whether we're in bt or tl zone
        tfbt = ~tfbt;
        %Now start where we last ended
        j = nxt;
        hold on, plot(outtra{end})
    end
    
    %Debug: Plot
    if mod(i,opts.verbose.traces) == 0
        figure
        plot(dfil{i}), hold on
        surface([1:length(kvt{i}); 1:length(kvt{i})],[kvt{i}; kvt{i}], zeros(2,length(kvt{i})), repmat(ind2tra(kvi{i}, [isbt{i} 0]), [2 1]) ,'edgecol', 'interp', 'LineWidth', 2)
    end
end

outtfbt = logical(outtfbt);
%Sorted backtrack things, make into struct array. Maybe easier to start as struct...
out.bt = struct('tra', (outtra(outtfbt)), ...
                'ind', (outind(outtfbt)), ...
                'mea', (outmea(outtfbt)), ...
                'frc', num2cell(outfrc(outtfbt)));
out.tl = struct('tra', (outtra(~outtfbt)), ...
                'ind', (outind(~outtfbt)), ...
                'mea', (outmea(~outtfbt)), ...
                'frc', num2cell(outfrc(~outtfbt)));
out.opts = opts; %Save options