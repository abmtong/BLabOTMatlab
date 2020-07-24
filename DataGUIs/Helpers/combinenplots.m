function out = combinenplots(axs, dims)

%Takes a group of plots AXS and arranges them in an array DIMS
%Assumes the same x/y lims, so only plot the final x ticks

%Put a border along the edge
wid = .1;

%check there's enough plots
np = numel(axs);
assert(np <= prod(dims))

%Taken with modification from @subplot2
%Plots are a grid with wid between them
widx = (1 -2*wid) / dims(2);
widy = (1 -2*wid) / dims(1);
%Get lower-left corner [posxs, posys] of each plot
posxs = wid + (0:dims(2)-1) * widx;
posys = wid + (0:dims(1)-1) * widy;
posys = fliplr(posys); %matrix numbering starts up-left, position numbering starts bottom-left. Dims uses matrix numbering

%Get x,y position of each value of ind (ind array = larger graph, like in @subplot)
[coy, cox] = arrayfun(@(x)ind2sub(dims, x), 1:np);

%Plot the graphs by copying the objects, 

fg = figure('Name' , 'CombineNPlots');
for i = 1:np
    %Make a copy
    newax = copyobj(axs(i), fg);
    %Resize
    newax.Position = [posxs(cox(i)), posys(coy(i)), widx, widy];
    %Delete X tick labels unless it's the last graph
    if i ~= length(axs)
        newax.XTickLabel = {};
    end
    
    %Append to array, to linkaxes later
    newaxs(i) = newax; %#ok<AGROW>
end

linkaxes(newaxs, 'xy')