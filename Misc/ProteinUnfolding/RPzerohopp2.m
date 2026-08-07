function out = RPzerohopp2(inst, inOpts)
%RP zero hop p2: Find transition paths, to try to filter for no folding vs. good events

opts.tpfil = 3; %Smooth for TP calc, half-width
opts.tpwid = [0 30]; %Transition path bounds: Get time from first crossing of tpwid(1) to first crossing of tpwid(2)

opts.tpint = [-4 4 12.5 26.3 36]; %Sub-TPs (i.e. per intermediate)

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


len = length(inst);
for i = 1:len
    hei = length(inst(i).conpro);
    for j = hei:-1:1
        %Get conpro
        tmp = inst(i).conpro{j};
        %Filter
        tmp = windowFilter(@median, tmp, opts.tpfil, 1);
        
        %Calc singular TP
        t1 = find( tmp > opts.tpwid(1), 1, 'first' ); 
        t2 = find( tmp > opts.tpwid(2), 1, 'first' );
        %Handle empty: If it crosses t1 but not t2, this is a slow unfolder (time = inf), else NaN
        if isempty(t2) && ~isempty(t1)
            tt = length(tmp)+1; %Inf, or just length of data? +1?
        elseif isempty(t2) || isempty(t1)
            tt = nan;
        else
            tt = t2 - t1;
        end
        inst(i).ttp(j) = tt;
        
        %Calc intermediate TPs
        if isempty(opts.tpint)
            continue
        end
        
        nn = length(opts.tpint);
        traw = nan(1,nn);
        for k = 1:nn
            ttmp = find( tmp > opts.tpint(k), 1, 'first' ); 
            %If crosses this value, set number, else skip
            if ~isempty(ttmp)
                traw(k) = ttmp;
            end
        end
        tpraw = diff(traw);
        %Replace NaNs with inf, or leave them if it's all NaN
        if ~all(isnan(tpraw))
            tpraw(isnan(tpraw)) = inf;
        end
        
        inst(i).ttpint(j,:) = tpraw;
        inst(i).ttpintraw(j,:) = traw;
        
        
        
    end
end

out = inst;











