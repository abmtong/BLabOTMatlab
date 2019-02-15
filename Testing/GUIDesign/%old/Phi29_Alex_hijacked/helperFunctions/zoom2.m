function zoom2(varargin)
%My zoom is broken, override until repair
fprintf('Built-in @zoom is broken, using override. Click two points to define a box. If left-to-right, zoom; else reset zoom\n')
a = ginput(2);
ax = gca;
x = a(:,1);
y = a(:,2);
xs = issorted(x);
%ys = issorted(y);
x = sort(x);
y = sort(y);

%Chosen bottom-left to top-right (zoom in)
if xs %&& ys
    ax.XLim = x;
    ax.YLim = y;
else %Zoom reset
    ax.XLim = [-inf inf];
    ax.YLim = [-inf inf];
end