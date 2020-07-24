function plot2( inRaw, inFilter, figName, inOption )
%Plot inRaw's columns and its filtered data
%Normalizes columns of inRaw so mean=0, var=1 so it fits

window = floor((inFilter)-1/2);

if (nargin < 4)
    inOption = 1; %median filter
end
if (nargin < 3)
    figName = 'plot2';
end
filt = [];

sz = size(inRaw);
len = sz(2);
ax = [];
figure('Name',figName)
for i = 1:len
    inRaw(:,i) = (inRaw(:,i) - mean(inRaw(:,i))) ;%/std(inRaw(:,i));
    
    switch inOption
    case 2
        filt = meanFilter(inRaw(:,i), inFilter);
    otherwise
        filt = medianFilter(inRaw(:,i), inFilter);
    end
    ax = [ax subplot(2,len,i)];
    plot(inRaw(window+1:end,i))
    ax = [ax subplot(2,len,i+len)];
    plot(filt)
end

linkaxes(ax,'xy');

end