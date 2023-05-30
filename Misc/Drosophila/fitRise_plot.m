function fitRise_plot(inst, inOpts)
%Plots fitRise dt's
%Input: inst is either the struct output of fitRise or just dt's


opts.minsnr = 1; %Minimum 'snr' : Peak height divided by 


%Handle if the input is just dt's
if ~isstruct(inst)
    dt = inst;
else
    %Get dt's from struct
    if isfield(inst, 'fr2')
        tmp = reshape([inst.fr2], 2, []);
        dt = -diff(tmp, 1);
    elseif isfield(inst, 'fr')
        tmp = reshape([inst.fr], 2, []);
        dt = -diff(tmp, 1);
    else
        warning('No times in this struct, run fitRise first; exiting')
        return
    end
    
    %Apply some filtering based on heuristics? TBD
    
end


[~, x, ~, p] = nhistc( dt, 1);

figure('Name', sprintf( 'fitRise: N=%d, median %0.2f; pos N=%d, median %0.2f', sum(~isnan(dt)), median(dt, 'omitnan'), sum(dt > 0), median(dt(dt>0), 'omitnan')  ))
plot(x,p)
xlabel('Frames')
ylabel('Count')