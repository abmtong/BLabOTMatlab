function peakdata = findpeaks2d_loop(data, varargin)
%From Matlab answers https://www.mathworks.com/matlabcentral/answers/399125-how-can-i-find-the-peaks-of-a-surface-i-e-2-d-data-instead-of-1-d

data = double(data);
[x, y] = meshgrid( 1:size(data, 2), 1:size(data,1));

% Find dimensions to set up loop
xdim = size(data,1);
ydim = size(data,2);

% Loop through x dimension to find peaks of each row
xpeaks = zeros(size(data));
xwidths = NaN(size(data));
for i = 1:xdim
    [~,locs,w] = findpeaks(data(i,:), varargin{:});
    xpeaks(i,locs) = 1;
    xwidths(i,locs) = w;
end

% Loop through y dimension to find peaks of each row
ypeaks = zeros(size(data));
ywidths = NaN(size(data));
for i = 1:ydim
    [~,locs,w] = findpeaks(data(:,i), varargin{:});
    ypeaks(locs,i) = 1;
    ywidths(locs,i) = w;
end

% Find indices that were peaks in both x and y
peak_inds = xpeaks+ypeaks == 2;

% Save data to sruct
peakdata = struct;
peakdata.peakZ = data(peak_inds);
peakdata.peakX = x(peak_inds);
peakdata.peakY = y(peak_inds);
peakdata.peakXWidth = xwidths(peak_inds);
peakdata.peakYWidth = ywidths(peak_inds);

%
% relht = peakdata.peakZ ./ sqrt(peakdata.peakXWidth .^2 + peakdata.peakYWidth .^2 );
% minrelht = 

% % Plot
% figure
% surface( x, y, data , 'EdgeColor', 'none')
% hold on
% plot3(x(peak_inds),y(peak_inds),data(peak_inds),'r*','MarkerSize',24)




