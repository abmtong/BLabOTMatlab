function out = vdist_batch(datacell, inOpts)

%Opts are same as vdist's

%Define default options
opts.sgp = {1 301}; %"Savitzky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling
% Options for plotting, if requested
opts.verbose = 1;
opts.velmult = 1; %Velocity conversion, e.g. from bp to nm
opts.vfitlim = [0 100]; %Velocity to fit over
opts.fitmethod = 1;
opts.xlim = [-100 100];

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

fg = figure('Name', sprintf('vdst_b, SGP {%d %d}', opts.sgp{1}, opts.sgp{2}));

len = length(datacell);

xlims = [.05 .95];
ylims = .05 + .9 * (0:len)/len ;

out = zeros(5,len);

%Does vdist to datacell{i} and plots them stacked
for i = 1:len
    vdist(datacell{i}, opts);
    drawnow
    tfg = gcf;
    ax = gca;
    axc(i) = copyobj(ax, fg); %#ok<*AGROW>
    axc(i).Position = [xlims(1) ylims(i) diff(xlims) ylims(i+1)-ylims(i)];
    tmp = textscan(tfg.Name, 'vdist : Speed %f +- %f (%f SEM) nm/s, (%f,%f) pct (tloc,paused)');
    out(:,i) = [tmp{:}];
    delete(tfg);
end

linkaxes(axc, 'xy')

%Clear x-axis text on plots
for i = 2:len
    axc(i).XTickLabel = {};
end

%Reshape to fit graph order
%Columns Velocity SD SEM %Tloc %Paused
out = flipud(out');