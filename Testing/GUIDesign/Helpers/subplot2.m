function ax = subplot2(infg, dims, num)
%'better' subplot (less whitespace), warning: without sanity checks
%Imported from Elro

%if infg is not supplied, use gcf instead
if nargin == 2 && isnumeric(infg)
    num = dims;
    dims = infg;
    infg = gcf;
end

if ~isequal(size(dims), [1 2])
    error('dims must be a 1x2 array')
end
if num > prod(dims)
    error('num must be <= prod(dims)')
end

%Plots are a grid with wid between them
wid = 0.05;
widx = (1 - wid*dims(2)-wid) / dims(2);
widy = (1 - wid*dims(1)-wid) / dims(1);

posxs = wid + (0:dims(2)-1) * (widx+wid);
posys = wid + (0:dims(1)-1) * (widy+wid);
posys = fliplr(posys); %matrix numbering starts up-left, position numbering starts bottom-left

[coy, cox] = ind2sub(dims, num);

ax = axes(infg, 'Units', 'normalized', 'Position', [posxs(cox) posys(coy) widx widy]);