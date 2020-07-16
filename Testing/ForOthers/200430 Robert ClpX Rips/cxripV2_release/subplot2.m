function ax = subplot2(infg, dims, num, wid)
%Tighter subplot (less whitespace, tunable)

if nargin < 4
    wid = 0.05;
end

%Min nargin = 2
%If infg is not supplied, use gcf instead
if nargin == 2 && isnumeric(infg)
    num = dims;
    dims = infg;
    infg = gcf;
elseif nargin == 3 && isnumeric(infg)
    wid = num;
    num = dims;
    dims = infg;
    infg = gcf;
end

if ~isequal(numel(dims), 2)
    error('dims must be a 1x2 array')
end
if max(num) > prod(dims)
    error('num must be <= prod(dims)')
end

%Plots are a grid with wid between them
widx = (1 - wid*dims(2)-wid) / dims(2);
widy = (1 - wid*dims(1)-wid) / dims(1);

%If there are too many plots in one direction and wid is large enough, we could run out of space
if widx<=0 || widy<=0
    error('Width %f between plots is too large, reduce');
end

%Get lower-left corner [posxs, posys] of each plot
posxs = wid + (0:dims(2)-1) * (widx+wid);
posys = wid + (0:dims(1)-1) * (widy+wid);
posys = fliplr(posys); %matrix numbering starts up-left, position numbering starts bottom-left. Dims uses matrix numbering

%Get x,y position of each value of ind (ind array = larger graph, like in @subplot)
[coy, cox] = arrayfun(@(x)ind2sub(dims, x), num);
%Lower-left corners of all chosen graphs
llx = posxs(cox);
lly = posys(coy);
%Upper-right corners of all chosen graphs
urx = llx + widx;
ury = lly + widy;
%Take largest box that contains all graphs
ll = [min(llx) min(lly)];
ur = [max(urx) max(ury)];
%Make axis with this position
ax = axes(infg, 'Units', 'normalized', 'Position', [ll ur-ll]);





