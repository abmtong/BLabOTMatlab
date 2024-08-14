function TxPull_plot(inst)

%Plots F-X and C-F data separated by type

fg1 = figure( 'Name', 'TxPullPlot-ForExt' );
fg2 = figure( 'Name', 'TxPullPlot-ConFor' );


%Create subplots
ax1 = arrayfun(@(x) subplot2(fg1, [1 4], x), 1:4, 'Un', 0);
ax1 = [ax1{:}];
ax2 = arrayfun(@(x) subplot2(fg2, [4 1], x), 1:4, 'Un', 0);
ax2 = [ax2{:}];

arrayfun(@(x) hold(x, 'on'), [ax1 ax2]);

%Options
fil = 100;
xwlc = [48 1340];
fcen = 7;

tits = {'Bare' 'Tet' 'Hex' 'Nuc'};

%Loop through data
len = length(inst);
for i = 1:len
    id = 1 + inst(i).tfpbe1 + 2 * inst(i).tfpbe2;
    
    if isnan(id)
        continue
    end
    
    %Calculate force, ext
    frc = windowFilter(@mean, inst(i).frc, [], fil);
    ext = windowFilter(@mean, inst(i).ext, [], fil);
    con = ext ./ XWLC( frc, xwlc(1), xwlc(2) );
    
    %Zero to fcen
    ki = find(frc > fcen, 1, 'first');
    if isempty(ki)
        continue
    end
    ext = ext - ext( ki );
    con = con - con( ki );
    
    
    %Plot on ax(id)
    plot( ax1(id), ext, frc )
    plot( ax2(id), frc, con )
end

linkaxes(ax1, 'xy')
linkaxes(ax2, 'xy')

for i = 1:4
    title(ax1(i), tits{i})
    title(ax2(i), tits{i})
end

%Set lims. Should be fine since we're zeroing
xlim(ax1(1), [-150 150])
ylim(ax1(1), [0 45])

xlim(ax2(1), [0 45])
ylim(ax2(1), [-35 35])


