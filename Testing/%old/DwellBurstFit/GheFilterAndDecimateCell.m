function out = GheFilterAndDecimateCell(xData, N)
% This function filters and decimates the data. 
% For Example: Z = FilterAndDecimate(z,20)
% The script bins the z-data in bins of 20 pts each, then averages over these
% bins and outputs a smaller vector Z, with the bin averages
%
% Gheorghe Chistol, 09 Feb 2012

out = cell(1,length(xData));
for i = 1:length(xData)
    xdata   = filter(ones(1, N), N, xData{i});
    ind = N:N:length(xdata);
    out{i}   = xdata(ind); 
end