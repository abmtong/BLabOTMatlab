function out = alignTraces(xwid)
%ginputs, aligns traces nearby (within ginput(x)+xwid) to ginput(y) crossing

if nargin < 1
    xwid = [1 1]; %1 x units. kinda asssume that plot x's are monotonic ish
end

ax = gca;
a = ginput(1);

xlo = a(1) - xwid(1);
xhi = a(1) + xwid(2);
ycr = a(2);

%get children
ch = ax.Children;

%sort through children

for i = 1:length(ch)
    tmp =  ch(i);
    %Check if it has long XData/YData
    try ch(i).XData;
    catch
        continue
    end
    xx = ch(i).XData;
    yy = ch(i).YData;
    
    %Crop data
    ki = find( xx > xlo, 1, 'first'): find( xx > xhi, 1, 'first' );
    xx = xx(ki);
    yy = yy(ki);
    if length(xx) < 2
        continue
    end
    
    %Find first crossing within this crop
    ind = find( yy > ycr, 1, 'first');
    if isempty(ind)
        continue
    end
    
    %And shift x
    tmp.XData = tmp.XData - xx(ind) + a(1);
    
end








