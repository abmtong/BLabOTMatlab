function out = analyzeMutants(inst, inOpts)

%Input: a struct from getFCs_multi
%For plotting, can add a field 'color' to inst

opts.Fs = 2500;
opts.kdfopts.fil = {10 1};
opts.dwmax = 0.5; %Max dwell time for fitting
len = length(inst);

%Do kdfsfindV2, or load from 'tra' field
% And fit dwells to gamma + 1exp
tras = cell(1,len);
dws = cell(1,len);
sts = cell(1,len);
for i = 1:len
    %Either fetch from tras field or calc with kdfsfind
    if isfield(inst, 'tra')
        tras{i} = inst(i).tra;
        [in, me] = cellfun(@tra2ind, tras{i}, 'Un', 0);
        st = cellfun(@diff, me, 'Un', 0);
        sts{i} = -[st{:}];
        dw = cellfun(@diff, in, 'Un', 0);
        dws{i} = [dw{:}] / opts.Fs;
    else
        [~, sts{i}, ~, dws{i}, tras{i}] = kdfsfindV2(inst(i).con);
    end
end

%% Plot Dwells

for i = len:-1:1
    gamfits(i) = phage_dwelldist(dws{i} (dws{i} < opts.dwmax) , 1, 0);
end

%Compose to one figure. Maybe just replot? Yeah just replot
fggam = figure('Name', 'Gamma fits', 'Color', [1 1 1]);
ypad = 0.1;
xpad = 0.1;
dy = ( 1 - ypad*2 ) / len;
binsz = .01;
for i = 1:len
    %Plot top-down, so axis go 1>len and data goes len>1
    %Create axis
    axgam(i) = axes(fggam, 'Position', [ xpad, ypad + dy * (i-1), 1-xpad*2, dy ]); %#ok<AGROW>
    hold on
    %Plot raw data as bar
    [hy, hx] = nhistc( dws{len-i+1}, binsz );
    fty = gamfits(len-i+1).fh( gamfits(len-i+1).ft , hx);
    bar (axgam(i), hx, hy,'FaceColor', inst(len-i+1).color, 'EdgeColor', 'none');
    plot(axgam(i), hx, fty, 'Color', 'k', 'LineWidth', 1)
    legend( inst(len-i+1).name )
end

%Linkaxes and kill ticks on non-bottom graph
linkaxes(axgam, 'x');
arrayfun(@(x) set(x, 'FontSize', 18), axgam)
arrayfun(@(x) set(x, 'XTickLabel', []), axgam(2:end))
arrayfun(@(x) set(x, 'YTickLabel', []), axgam)

arrayfun(@(x)axis(x, 'tight'), axgam)
xmx = max( cellfun(@(x)prctile(x, 98), dws) );
xlim([0 xmx])
xlabel(axgam(1), 'Dwell Time (s)')
% out.nmin = cellfun(@(x)mean(x(x<1)), dws).^2 ./ cellfun(@(x)var(x(x<1)), dws);
out.dwfit = reshape([ gamfits.ft ], [], len)';

%% Plot Step Sizes
fgsts = figure('Name', 'Step sizes', 'Color', [1 1 1]);
ypad = 0.1;
xpad = 0.1;
dy = ( 1 - ypad*2 ) / len;
binsz = .2;
for i = 1:len
    %Plot top-down, so axis go 1>len and data goes len>1
    %Create axis
    axsts(i) = axes(fgsts, 'Position', [ xpad, ypad + dy * (i-1), 1-xpad*2, dy ]); %#ok<AGROW>
    hold on
    %Plot raw data as bar
    [hy, hx] = nhistc( sts{len-i+1}, binsz );
%     fty = gamfits(len-i+1).fh( gamfits(len-i+1).ft , hx);
    bar (axsts(i), hx, hy,'FaceColor', inst(len-i+1).color, 'EdgeColor', 'none');
%     plot(axsts(i), hx, fty, 'Color', 'k', 'LineWidth', 1)
    legend( inst(len-i+1).name )
end
linkaxes(axsts, 'x')
arrayfun(@(x) set(x, 'FontSize', 18), axsts)
arrayfun(@(x) set(x, 'XTickLabel', []), axsts(2:end))
arrayfun(@(x) set(x, 'YTickLabel', []), axsts)

arrayfun(@(x)axis(x, 'tight'), axsts)

xlim([0 20])
xlabel(axsts(1), 'Step Size (bp)')

out.ssz = cellfun(@mean, sts);
out.sszmd = cellfun(@median, sts);
out.sszsd = cellfun(@std, sts);


%% Velocity Distribution
%Do vdist (just do vdist_mult?)
vraw = cell(1,len);
vfit = cell(1,len);
for i = 1:len
    [~, ~, velraw, ~, ~, vfit{i}] = vdist(inst(i).con, struct('sgp', {{1 301}}, 'velmult', -1, 'vfitlim', [-50 250], 'verbose', 0));
    vraw{i} = -[velraw{:}];
end
%And then plot em together

fgvel = figure('Name', 'Velocity distribution', 'Color', [1 1 1]);
ypad = 0.1;
xpad = 0.1;
dy = ( 1 - ypad*2 ) / len;
binsz = .5;
bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
for i = 1:len
    %Plot top-down, so axis go 1>len and data goes len>1
    %Create axis
    axvel(i) = axes(fgvel, 'Position', [ xpad, ypad + dy * (i-1), 1-xpad*2, dy ]); %#ok<AGROW>
    hold on
    %Plot raw data as bar
    [hy, hx] = nhistc( vraw{len-i+1}, binsz );
    fty = bigauss( vfit{ len-i+1 }, hx );
    bar (axvel(i), hx, hy,'FaceColor', inst(len-i+1).color, 'EdgeColor', 'none');
    plot(axvel(i), hx, fty, 'Color', 'k', 'LineWidth', 1)
    legend( inst(len-i+1).name )
end
linkaxes(axvel, 'x')
arrayfun(@(x) set(x, 'FontSize', 18), axvel)
arrayfun(@(x) set(x, 'XTickLabel', []), axvel(2:end))
arrayfun(@(x) set(x, 'YTickLabel', []), axvel)

arrayfun(@(x)axis(x, 'tight'), axvel)

xlim([-50 250])
xlabel(axvel(1), 'Velocity (bp/s)')

out.vels = reshape( [vfit{:}], [], len)';




