function [bar_pos, DWT_hist, Err, DWT_array] = DWT_analysis(x_array, t_array, Ts, Nw, Ti,bins_per_decade,number_of_decades,correction, nboot)

x_array = double(x_array);

% t0 is the time resolution
t0 = mean(diff(t_array));

xs_array = sgolayfilt(x_array,0,Ts);

[Tc_array]=find_crossing_time(t_array, xs_array,Nw);

DWT_array = diff(Tc_array);

[bar_pos, bins]=make_bins(Ti,bins_per_decade,number_of_decades,t0,correction);

[DWT_hist] = DwellTimeHist_v3(DWT_array, t0, bins);

bootstat = bootstrp(nboot,@ (DWT_array) DwellTimeHist_v3(DWT_array, t0, bins),DWT_array);

Err=zeros([1, length(DWT_hist)]);

for i=1:length(DWT_hist)

    Err(:,i)=std(bootstat(:,i));

end


