function drawLine(opt)
if nargin < 1
    opt = 0;
end

g = ginput(2);

%Draw line in X
if ~opt
    x = g(:,1);
    y = mean(g(:,2));
    line(x, [y y])
    text(mean(x),y,num2str(abs(diff(x))))
end
%Draw line in Y
if opt
    x = mean(g(:,1));
    y = g(:,2);
    line([x x], y)
    text(x,mean(y),num2str(abs(diff(y))))    
end