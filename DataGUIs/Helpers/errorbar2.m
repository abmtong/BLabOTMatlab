function out = errorbar2(xx, yy, ee, wid, varargin)
%Errorbar but with controllable errorbar widths
% To mark the datapt itself, do a separate plot over it
% wid is the width of the bars (in x-units), varargin is passed to plot(..., varargin{:}) (so, line properties)

if nargin < 4 || isempty(wid)
    wid = median( diff( sort(xx) ))/3;
end

%Plot errorbar as three line segments

%Check inputs
if ~(numel(xx) == numel(yy) && numel(yy) == numel(ee))
    error('Size of inputs xx, yy, ee are wrong')
end


%Hold needs to be on
ish = ishold;
%Replicate hold off behavior with cla
if ~ish
    cla
end

hold on

%Preserve current ColorOrderIndex
coi = get(gca, 'ColorOrderIndex');

len = length(xx);
outraw = cell(3, len);
for i = 1:length(xx)
    %Let's define the six points that make up the I shape
    
    %The |
    x1 = xx(i) * [1 1];
    y1 = yy(i) + [-ee(i) ee(i)];
    
    %The upper -
    x2 = xx(i) + [-wid +wid];
    y2 = (yy(i) + ee(i)) * [1 1];
    
    %The lower -
    x3 = xx(i) + [-wid +wid];
    y3 = (yy(i) - ee(i)) * [1 1];
    
    outraw{1, i} = plot(x1, y1, varargin{:});
    set(gca, 'ColorOrderIndex', coi);
    outraw{2, i} = plot(x2, y2, varargin{:});
    set(gca, 'ColorOrderIndex', coi);
    outraw{3, i} = plot(x3, y3, varargin{:});
    set(gca, 'ColorOrderIndex', coi);
end
set(gca, 'ColorOrderIndex', coi+1);
%Revert hold if it was hold off
if ~ish
    hold off
end

%Reshape out if nargout
if nargout
    out = cell2mat(outraw);
end