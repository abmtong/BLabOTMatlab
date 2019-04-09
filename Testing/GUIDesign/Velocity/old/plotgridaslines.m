function plotgridaslines(x, y, z)
if nargin == 1
    z = x;
    x = 1:size(z,1);
    y = 1:size(z,2);
end
figure, hold on
for i = 1:length(y)
    plot3(x, y(i) * ones(size(x)), z(:, i));
end
