function out = multibar(xdata, ydata, colcell)

%Acts like @bar but with no spacing between groups of bars.

ax = gca;

xdata = xdata(:)';
%Ydata should be a matrix (column = data)

binsz = mean(diff(xdata)); %Assumedly dx is evenly spaced

nn = size(ydata, 2);
len = size(ydata, 1);

if nargin < 3
    colcell = lines(nn);
    colcell = mat2cell(colcell, ones(1,nn));
end

for i = 1:nn
    %Make a patch that is the bars we want
    y = ydata(:,i);
    
    %For each pt in ydata, it needs to be a bar with 
    
    off = -binsz/2 + (i-1) * binsz /nn;
    
    %Assemble this comb shape: 4pts per bar
    xx = [xdata+off; xdata+off; xdata+off+binsz/nn; xdata+off+binsz/nn ];
    xx = xx(:)';
    
    yy = [zeros(1,len); y'; y'; zeros(1,len)];
    yy = yy(:)';
    
    
    out(i) = patch(ax, xx, yy, colcell{i}, 'EdgeColor', [1 1 1]); %#ok<AGROW>
end