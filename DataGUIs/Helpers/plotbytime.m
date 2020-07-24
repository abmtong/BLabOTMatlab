function outax = plotbytime(varargin)
%Plots a x,y graph with time as color
%Inputs: (ax, x, y, surface NVPs)

if isgraphics(varargin{1}, 'axes')
    ax = varargin{1};
    va = varargin(2:end);
else
    ax = gca;
    va = varargin;
end

%Extract coords, make row vector
x = va{1};
y = va{2};
x = x(:)';
y = y(:)';

va = va(3:end);
len = length(x);

%Accompish by surf(x, y, z = zero, c = 1:length, 'EdgeColor', 'interp')
os = surface(ax, [x;x], [y;y], zeros(2,len), [1:len;1:len], 'EdgeColor', 'interp', va{:});

if nargout > 0
    outax = os;
end