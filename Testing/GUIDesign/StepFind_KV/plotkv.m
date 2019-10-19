function out = plotkv(ax,x,y,varargin)

if nargin == 1 %passed just y
    ax = gca;
    y=ax;
    x=1:length(y);
end

if nargin == 2
    if isnumeric(ax) %passed x,y
        y = x;
        x = ax;
        ax = gca;
    else
        y = x;
        x = 1:length(y);
    end
end

%plot k-v trace as a staircase
%So when y changes, add an extra pt.

for i = length(y):-1:2
    if y(i) ~= y(i-1)
        y = [y(1:i-1) y(i-1) y(i:end)];
        x = [x(1:i-1) x(i) x(i:end)];
    end
end

%And plot
if nargin > 3
    tmp = plot(ax,x,y, varargin{:});
else
    tmp = plot(ax,x,y);
end
if nargout
    out = tmp;
end