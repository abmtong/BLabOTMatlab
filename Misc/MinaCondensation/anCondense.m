function out = anCondense(trs, inOpts)

opts.ycut = 1500; %bp, cut traces once they cross here. To remove end pausing?
opts.tcut = 10; %s, cut traces after this length of time

%Define vdist options
opts.sgp = {1 201}; %"Savitzky Golay Params"
opts.vbinsz = 10; %Velocity BIN SiZe
opts.Fs = 1e3; %Frequency of Sampling
opts.velmult = -1;%Set decreasing to positive
opts.vfitlim = [-inf inf]; %Velocity to fit over
opts.verbose = 0;

%Method two: subtract negative gaussian
opts.m2vfitlim = [-1e3 0];

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(trs);

%Cut some traces ... somewhere
for i = 1:len
    %Time cutoff
    trs{i} = cellfun(@(x) x(1:min(length(x), round(opts.tcut*opts.Fs))), trs{i}, 'Un', 0);
    %Length cutoff
    iend = cellfun(@(x) find( x < opts.ycut, 1, 'first'), trs{i}, 'Un', 0);
    lens = cellfun(@length, trs{i}, 'Un', 0);
    iend( cellfun(@isempty, iend) ) = lens( cellfun(@isempty, iend) );
    trs{i} = cellfun(@(x,y) x(1:y), trs{i}, iend, 'Un', 0);
end


[vy, vx] = cellfun(@(x) vdist(x, opts), trs, 'Un', 0);

figure('Name', 'anCondense', 'Color', [1 1 1])
hold on
cols = arrayfun(@(x) squeeze(hsv2rgb(x, 1, .7)), (0:length(vx)-1)/length(vx), 'Un', 0);
cols = reshape( [cols{:}], 3, [] )';
set(gca, 'ColorOrder', cols)
cellfun(@(x,y) plot(x,y), vx, vy  )

[~, out] = vdist_batch(trs, opts);

%Get height at 0vel
zwid = 50; %Use zero height as average over -zwid:zwid
hts = cellfun(@(x,v) mean( v( x <=zwid & x >=-zwid ) ) , out.x, out.v);

%Use second as 'noise baseline' and subtract away
indbase = 2;
vsub = cell(1,len);
for i = 1:len
    %Assume x values are aligned
    lox = max( min( out.x{i}), min( out.x{indbase} ) );
    hix = min( max( out.x{i}), max( out.x{indbase} ) );
    %Get indicies in both x-coords
    ind1 = find(out.x{i} == lox, 1, 'first') : find(out.x{i} == hix, 1, 'first'); %might need to use eps-compare?
    ind2 = find(out.x{indbase} == lox, 1, 'first') : find(out.x{indbase} == hix, 1, 'first');
    %And subtract
    vsub{i} = out.v{i};
    vsub{i}(ind1) = vsub{i}(ind1) - out.v{indbase}(ind2) / hts(indbase) * hts(i);
end
out.vsub = vsub;

figure Name SubMATP, hold on, set(gca, 'ColorOrder', cols), cellfun(@plot, out.x, out.vsub)
figure Name Normalized, hold on, set(gca, 'ColorOrder', cols), cellfun(@(x,y,z)plot(x,y/z), out.x, out.v, num2cell(hts))

%Method two: fit half-gaussian to negative data, subtract from both ends
cengauft = cell(1,len);
for i = 1:len
    ki = out.x{i} <= opts.m2vfitlim(2) & out.x{i} > opts.m2vfitlim(1);
    gau0 = @(x0,x) x0(1)* normpdf(x, 0, x0(2));
    cengauft{i} = lsqcurvefit(gau0, [1 100], out.x{i}(ki), out.v{i}(ki));
end
%Plot data and fit
figure Name CenterGaussFit, hold on, set(gca, 'ColorOrder', cols), cellfun(@plot, out.x, out.v), 
set(gca, 'ColorOrderIndex', 1)
cellfun(@(x,y)plot (x, gau0(y,x)) , out.x, cengauft)
%Plot subtracted
figure Name CenterGaussSubtracted, hold on, set(gca, 'ColorOrder', cols), cellfun(@(x,y, z)plot (x, z-gau0(y,x)) , out.x, cengauft, out.v)

%Method 3: Subtract negative data
figure Name NegSubtracted, hold on, set(gca, 'ColorOrder', cols), 
for i = 1:len
    ki = out.x{i} <= 0;
    tmpv = out.v{i};
    tmpv = windowFilter(@mean, tmpv, 20, 1);
    tmpv = tmpv - interp1( [1e9 -out.x{i}(ki)], [0 tmpv(ki)], abs(out.x{i}) ); %Interp minus values against positive values
%     plot(out.x{i}, tmpv/ out.v{i}(find(ki, 1, 'last')))
    plot(out.x{i}, tmpv)
end

% %BatchKV
% bkv = cell(1,len);
% figure Name BatchKV, hold on
% for i = 1:len
%     [~, ~, ~, bkv{i}] = BatchKV(cellfun(@(x) windowFilter(@mean, x, [], 5), trs{i}, 'Un', 0), single(10), 500, 0);
%     [ty, tx] = nhistc(bkv{i}, 10);
%     plot(tx, ty);
% end


% %Trigauss -- Nah, too many df's / too much zero pop.
% trig = @(x0,x) x0(1) * normpdf(x, x0(2), x0(3)) + x0(4) * normpdf(x, x0(5), x0(6)) + x0(7) * normpdf(x, x0(8), x0(9));
% %amp mean sd
% lb = [0 -inf 0 0 0 0 0 0 0];
% ub = [inf 0 inf inf 0 inf inf inf inf];
% ampg = 1e-1;
% mng = 500;
% sdg = 1e3;
% xg = [ampg -mng sdg ampg 0 sdg ampg mng sdg];
% trigfts = cell(1,len);
% gau = @(x0,x) x0(1) * normpdf(x, x0(2), x0(3));
% figure Name TrigaussFit
% xfitlim = [-2e3 2e3];
% oop = optimoptions('lsqcurvefit', 'FunctionTolerance', 1e-10);
% for i = 1:len
%     ax = subplot2(gcf, [5 1], i, 0);
%     hold(ax, 'on')
%     ki = out.x{i} >= xfitlim(1) & out.x{i} <= xfitlim(2);
%     trigfts{i} = lsqcurvefit(trig, xg, out.x{i}(ki), out.v{i}(ki), lb, ub, oop);
%     %Data
%     plot(out.x{i}, out.v{i}, 'Color', cols(i,:));
%     %Total fit
%     plot(out.x{i}, trig( trigfts{i}, out.x{i}), 'Color', 'k');
%     %Individual gaussians
%     plot(out.x{i}, gau( trigfts{i}(1:3), out.x{i}), 'Color', 'k');
%     plot(out.x{i}, gau( trigfts{i}(4:6), out.x{i}), 'Color', 'k');
%     plot(out.x{i}, gau( trigfts{i}(7:9), out.x{i}), 'Color', 'k');
% end
% linkaxes( get(gcf, 'Children'), 'xy' )
% reshape( [trigfts{:}], 9, [] )'

