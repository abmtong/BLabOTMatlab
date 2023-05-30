function out = findpeaks2d(data)



%From Matlab answers https://www.mathworks.com/matlabcentral/answers/399125-how-can-i-find-the-peaks-of-a-surface-i-e-2-d-data-instead-of-1-d
data2 = data';
[pks1, locs1, w1, p1] = findpeaks(double(data(:))); % peaks along x
[pks2, locs2, w2, p2] = findpeaks(double(data2(:))); % peaks along y

data_size = size(data); % Gets matrix dimensions
[col2, row2] = ind2sub(data_size, locs2); % Converts back to 2D indices
locs2 = sub2ind(data_size, row2, col2); % Swaps rows and columns and translates back to 1D indices
ind = intersect(locs1, locs2); % Finds common peak position
[row, column] = ind2sub(data_size, ind); % to 2D indices

out = [row(:), column(:)];