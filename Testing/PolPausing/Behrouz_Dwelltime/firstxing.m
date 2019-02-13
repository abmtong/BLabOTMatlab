function outind = firstxing(intr, stsz)
%finds the first crossings of the points of intr a grid of spacing stsz

if nargin < 2
    stsz = 2;
end

%Create grid of step bdys, from min to max in increments of stsz. Maybe swap to intr(1) to max(intr)?
grid = (floor(min(intr/stsz)):floor(max(intr)/stsz))*stsz;
len = length(grid);
outind = zeros(1,len);
for i = 1:length(grid)
    outind(i) = find(intr > grid(i), 1);
end

% %debug: draw grid of states and grid of crossings
% figure, plot(intr), hold on
% x = [1 length(intr)];
% for i = 1:length(grid)
%     line(x, grid(i)*[1 1])
%     line(outind(i)*[1 1], [grid(1) intr(outind(i))])
% end