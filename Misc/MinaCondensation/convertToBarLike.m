function out = convertToBarLike(inax)

if nargin < 1
    inax = gca;
end


ch = inax.Children;

fg = figure;
ax = gca;
hold on
for i = length(ch):-1:1 %Match plot order
    xx = ch(i).XData;
    yy = ch(i).YData;
    dx = median(diff(xx));
    newx = [xx(:)' - dx/2 ; xx(:)' + dx/2];
    newx = newx(:)';
    newy = [yy(:)' ; yy(:)'];
    newy = newy(:)';
    plot(newx, newy)
end

%Out is a shifting function
out = @(x) set( gco, 'XData', get( gco, 'XData') + x );