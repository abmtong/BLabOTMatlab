
function [bar_pos, bins]=make_bins(Ti,bins_per_decade,number_of_decades,t0,correction)

% arguments:

% DWT_array: an array contaning all the dwell times (i.e.the time
% difference between successive crossings)

% Ti: gives the position of the left edge of the first bin.

% bins_per_decade: number of logarithmic bins per decade.

% number_of_decades: indicates the range of the histigram. 
% The total number of the bins is given by 
% number_of_decades*bins_per_decade+1. 

% t0: time resolution (inverse of camera frequency).

% correction: if correction = 1, I correct the bin positions.

% output:

% bar_pos: an aray containing bin centers (in log space).

% hist: an aray containing the dwell time histogram.

% bins: an aray containing the bin edges.

% sum: The total integral of the histogram. Just to be sure that it is equal to one. 



% here I just construct the usual binning in log space (exactly as you do).
alpha=exp(log(10)/bins_per_decade);

% Nbins is the total number of bin edges.
Nbins=number_of_decades*bins_per_decade+1;

bins=zeros([1,Nbins]);

% I store the bin edges in the array "bins".

for n=1:Nbins
    bins(n)=Ti*alpha^(n-1);
end

% now comes the importnt part: to correct the bin sizes I do the following:
if correction == 1
    
    bin_space=zeros([1,Nbins-1]);
% I calculate the width of each bin and store in in an array called "bin_space".     
    for n=1:(Nbins-1)
        bin_space(n)=bins(n+1)-bins(n);
        
% Then I round each bin width to the closest multiple of t0.
% (the function "ceil" always rounds toward the larger integer).
    
        bin_space(n)=ceil(bin_space(n)/t0)*t0;
    end
    
% Similarly I correct the edge of the first bin.
    
    bins(1)=ceil(bins(1)/t0)*t0;
    
% Then I reconstruct the bin edges:
    
    for n=2:Nbins
        bins(n)=bins(n-1)+bin_space(n-1);
    end
end

% Finally I calculae the center of each bin.
% Since we are in log space, the bin center is the geometrical average of
% the two bins.

bar_pos=zeros([1,Nbins-1]);

for i=1:Nbins-1
    
    bar_pos(i)=sqrt(bins(i)*bins(i+1));
    
end
