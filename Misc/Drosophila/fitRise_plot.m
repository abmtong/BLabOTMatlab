function fitRise_plot(inst, inOpts)
%Plots fitRise dt's
%Input: inst is either the struct output of fitRise or just dt's


% opts.minsnr = 1; %Minimum 'snr' : Peak height divided by 
opts.unit = 1; %1: frame, 2: bp/s ; actually conversion isn't good rn bc of discreteness of values
opts.unitconv = 4300/15;%Conversion from frame to bp/s, to multiply 1/fr
                        %PP7+LacZ/12xNuc is 4300bp , each frame is 15s, so bp/s = 4300 / 15 / fr

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

%Convert unit
switch opts.unit
    case 2 %bp/s
        x = opts.unitconv./x;
        x(x<0) = nan;
end



figure('Name', sprintf( 'fitRise: N=%d, mean %0.2f, median %0.2f; pos N=%d, mean %0.2f, median %0.2f', sum(~isnan(dt)), mean(dt, 'omitnan'),median(dt, 'omitnan'), sum(dt > 0), mean(dt(dt>0), 'omitnan'), median(dt(dt>0), 'omitnan')  ))
plot(x,p)
ylabel('Count')

%Display label
switch opts.unit
    case 1
        xlabel('Frames')
    case 2
        xlabel('bp/s')
end


% %Convert unit, and handle plotting differently depending on unit
% switch opts.unit
%     case 1
% 
%     case 2
%         dt = opts.unitconv./dt;
%         [~, x, ~, p] = nhistc( dt, 2);
%         figure('Name', sprintf( 'fitRise: N=%d, median %0.2f; pos N=%d, median %0.2f', sum(~isnan(dt)), median(dt, 'omitnan'), sum(dt > 0), median(dt(dt>0), 'omitnan')  ))
%         plot(x,p)
%         xlabel('Frames')
%         ylabel('Count')
% end




