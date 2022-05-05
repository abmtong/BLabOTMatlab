function thesisExample4p2
%Code that generates Figure 4.2: Velocity Filtering

%Generate an example ensemble of low-force p29 traces.
Fs=2500;
ntr = 10;
simtraceopts.Fs = Fs;
tr = arrayfun(@(x) simp29trace(3, simtraceopts), 1:ntr, 'Un', 0);

%@vdist does everything, really
%Set some vdist options
vdistopts1.Fs = Fs; %Tell vdist the Fsamp of this data
vdistopts1.sgp = {1 501}; %Choose a savitsky-golay filter order, width (pts). 501pts @ 2500Hz = 0.2s.
vdistopts1.velmult = -1; %Tell vdist that this trace is decreasing
vdistopts1.verbose = 0; %Suppress graphic output from @vdist

[vbiny1, vbinx1, ~, trf1, trc] = vdist(tr, vdistopts1);

%Change sgp width: Wider
vdistopts2 = vdistopts1;
vdistopts2.sgp = {1 1001}; %1001pts/2500Hz = 0.4s

[vbiny2, vbinx2, ~, trf2] = vdist(tr, vdistopts2);

%Change sgp width: Narrower

vdistopts3 = vdistopts1;
vdistopts3.sgp = {1 251}; %250pts/2500Hz = 0.1s

[vbiny3, vbinx3, ~, trf3] = vdist(tr, vdistopts3);

%Figure 4.2a: Plot first trace with filter
figure('Name', 'Figure 4.2a: Filtered trace')
xx = (1:length(trc{1}))/Fs;
plot(xx, trc{1}, 'Color', [.7 .7 .7]);
hold on
set(gca, 'ColorOrderIndex', 1);
pl = @(n, x) plot( n/Fs+(1:length(x))/Fs, x, 'LineWidth', 1 ); %Need to shift times because of differing widths
pl(0,trf1{1})
pl(500/2,trf2{1})
pl(-250/2,trf3{1})
legend({'Raw Data', 'Filter 0.2s', 'Filter 0.4s', 'Filter 0.1s'})
%Zoom to a small slice
axis tight
xl = xlim;
xlim( xl(1) + [1 2] * range(xl)/10);

%Figure 4.2b: Output
%This is just what vdist does, so repeat with verbose on
vdistopts4 = vdistopts2;
vdistopts4.verbose = 1;
vdist(tr, vdistopts4);
set(gcf, 'Name', 'Figure 4.2b: Binning and Fitting')

%Figure 4.2c: Effect of filter width
figure('Name', 'Figure 4.2c: Effect of filter width')
plot(vbinx1, vbiny1, 'LineWidth', 1);
hold on
plot(vbinx2, vbiny2, 'LineWidth', 1);
plot(vbinx3, vbiny3, 'LineWidth', 1);
legend({'Filter 0.2s', 'Filter 0.4s', 'Filter 0.1s'})



