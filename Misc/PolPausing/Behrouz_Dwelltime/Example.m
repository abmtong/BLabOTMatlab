data_name = 'Data180913_076.mat';

data = load(data_name, '-mat');

t_array = data.tsdata.time;

x_array = data.tsdata.extension;

x_array = x_array(t_array<300);

t_array = t_array(t_array<300);

Ts = 1001;

Nw = 1;

bins_per_decade=7;

Ti=0.001;

number_of_decades=6;

correction=1;

nboot = 100;

[bar_pos, DWT_hist, Err, dt] = DWT_analysis(x_array, t_array, Ts, Nw, Ti,bins_per_decade,number_of_decades,correction, nboot);

figure()

ax = axes();

PL = errorbar(bar_pos,DWT_hist,Err,'kO','MarkerSize',6, 'MarkerFaceColor', 'k');

set(ax,'XScale','log','YScale','log')

xlabel('Dwell Time (s)')

ylabel('PDF')
